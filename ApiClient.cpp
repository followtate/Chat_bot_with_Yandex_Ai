#include "ApiClient.h"
#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>

const QString ApiClient::API_KEY = "Your_Api"; //you can create one with yandex console
const QString ApiClient::FOLDER_ID = "Your_folder_id";
const QString ApiClient::MODEL_URI_1 = "gpt://" + FOLDER_ID + "/yandexgpt";
const QString ApiClient::MODEL_URI_2 = "gpt://" + FOLDER_ID + "/yandexgpt-lite";


ApiClient::ApiClient(QObject *parent) : QObject(parent), m_process(new QProcess(this))
{
    connect(m_process, &QProcess::finished, this,
            [this](int exitCode, QProcess::ExitStatus) {
                processFinished(exitCode);
            });

}

void ApiClient::sendRequest(const QString &prompt,QString messagemodel)
{
    m_currentPrompt = prompt;

    QJsonObject messageObj;
    messageObj["role"] = "user";
    messageObj["text"] = prompt;

    QJsonArray messages;
    messages.append(messageObj);

    QJsonObject requestBody;
    if(messagemodel=="Yandex GPT lite"){
    requestBody["modelUri"] = MODEL_URI_2; //нужно переключение для выбора модели
    requestBody["messages"] = messages;
    }
    else if(messagemodel=="Yandex GPT"){
        requestBody["modelUri"] = MODEL_URI_1;
        requestBody["messages"] = messages;
    }

    m_process->start("curl", {
                                 "-s",
                                 "-X", "POST",
                                 "-H", QString("Authorization: Api-Key %1").arg(API_KEY).toUtf8(),
                                 "-H", "Content-Type: application/json",
                                 "--data-binary", "@-",
                                 "https://llm.api.cloud.yandex.net/foundationModels/v1/completion"
                             });

    if(m_process->state() == QProcess::Starting || m_process->state() == QProcess::Running) {
        m_process->write(QJsonDocument(requestBody).toJson());
        m_process->closeWriteChannel();
    }
}

void ApiClient::processFinished(int exitCode)
{
    if(exitCode != 0) {
        emit errorOccurred(tr("Ошибка выполнения запроса: %1").arg(m_process->errorString()));
        return;
    }

    QByteArray response = m_process->readAllStandardOutput();
    QString result = parseResponse(response);

    if(!result.isEmpty()) {
        emit responseReceived(result);
    } else {
        emit errorOccurred(tr("Неверный формат ответа API"));
    }
}

QString ApiClient::parseResponse(const QByteArray &response) const
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(response, &parseError);

    if(parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON Parse Error:" << parseError.errorString();
        return "";
    }

    QJsonObject root = doc.object();
    QJsonValue result = root.value("result");

    if(result.isUndefined()) {
        qWarning() << "Missing 'result' field";
        return "";
    }

    QJsonArray alternatives = result.toObject().value("alternatives").toArray();
    if(alternatives.isEmpty()) return "";

    QString text = alternatives[0].toObject().value("message").toObject().value("text").toString();
    return text.replace("\\\"", "\"")
        .replace("\\n", "\n");
}
