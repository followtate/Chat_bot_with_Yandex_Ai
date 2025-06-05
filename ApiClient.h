#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>
#include <QString>
#include <QProcess>
#include <QJsonDocument>

class ApiClient : public QObject
{
    Q_OBJECT
public:
    explicit ApiClient(QObject *parent = nullptr);

    Q_INVOKABLE void sendRequest(const QString &prompt,QString messagemodel);

signals:
    void responseReceived(const QString &answer);
    void errorOccurred(const QString &message);

private slots:
    void processFinished(int exitCode);

private:
    QProcess *m_process;
    QString m_currentPrompt;
    static const QString API_KEY;
    static const QString FOLDER_ID;
    static const QString MODEL_URI_1;
    static const QString MODEL_URI_2;
    QString MODEL_IS;

    QString buildCommand() const;
    QString parseResponse(const QByteArray &response) const;
};

#endif // APICLIENT_H
