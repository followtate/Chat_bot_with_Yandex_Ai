import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import AI 1.0

Page {
    id: chatPage
    property string inConversationWith
    property string textToCopy: ""

    // Функция для копирования текста в буфер обмена
    function copyToClipboard(text) {
        // Создаем временный TextArea для выполнения операции копирования
        Qt.callLater(() => {
            const tempTextArea = Qt.createQmlObject(`
                import QtQuick 2.15
                import QtQuick.Controls 2.15
                TextArea {
                    visible: false
                    text: "${text.replace(/"/g, '\\"').replace(/\n/g, "\\n")}"
                }
            `, chatPage)

            tempTextArea.selectAll()
            tempTextArea.copy()
            tempTextArea.destroy()
        })
    }

    ListModel {
        id: messageModel
    }

    // Контекстное меню для копирования
    Menu {
        id: copyMenu
        MenuItem {
            text: qsTr("Копировать")
            onTriggered: copyToClipboard(chatPage.textToCopy)
        }
    }

    property ApiClient apiClient: ApiClient {}
    header: ToolBar {
        ToolButton {
            text: qsTr("← Назад")
            onClicked: stackView.pop()
        }
        Label {
            text: inConversationWith
            anchors.centerIn: parent
        }
    }

    Component.onCompleted: {
        if(messageModel.count === 0) {
            messageModel.append({
                "text": "Здравствуйте, это искусственный интеллект. Напишите мне ваш запрос, и я постараюсь ответить на него",
                "sender": "ai"
            })
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: messageModel
            spacing: 15
            clip: true

            delegate: Row {
                spacing: 10
                anchors {
                    left: isUser ? undefined : parent.left
                    right: isUser ? parent.right : undefined
                    margins: 10
                }

                readonly property bool isUser: model.sender === "user"

                Rectangle { // Аватар
                    width: 40
                    height: 40
                    radius: 20
                    color: isUser ? "#0084FF" : "#EAEAEA"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: isUser ? "Я" : "ИИ"
                        anchors.centerIn: parent
                        color: isUser ? "white" : "black"
                    }
                }

                Rectangle { // Сообщение
                    width: Math.min(content.implicitWidth + 30, listView.width * 0.7)
                    height: content.implicitHeight + 20
                    color: isUser ? "#0084FF" : "#FFFFFF"
                    radius: 10
                    border.color: isUser ? "#0066CC" : "#E0E0E0"
                    anchors.verticalCenter: parent.verticalCenter

                    TextEdit { 
                        id: content
                        width: parent.width - 20
                        height: parent.height - 20
                        anchors.centerIn: parent
                        text: model.text
                        wrapMode: TextEdit.Wrap
                        padding: 10
                        color: isUser ? "white" : "black"
                        horizontalAlignment: Text.AlignLeft
                        readOnly: true // Запрещаем редактирование
                        selectByMouse: true // Разрешаем выделение текста мышью
                        selectedTextColor: isUser ? "black" : "white"
                        selectionColor: isUser ? "#00A2FF" : "#CCCCCC"

                        // Добавляем возможность копирования для ВСЕХ сообщений
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton

                            onClicked: {
                                if (mouse.button === Qt.RightButton) {
                                    // Копируем либо выделенный текст, либо весь текст
                                    chatPage.textToCopy = content.selectedText ? content.selectedText : content.text
                                    copyMenu.popup()
                                }
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: messageInput
                Layout.fillWidth: true
                placeholderText: qsTr("Введите сообщение...")
                onAccepted: sendButton.clicked()
            }

            Button {
                id: sendButton
                text: qsTr("Отправить")

                onClicked: {
                    if(messageInput.text.trim() === "") return;
                    messageModel.append({
                        "text": messageInput.text,
                        "sender": "user"
                    });
                    apiClient.sendRequest(messageInput.text,inConversationWith);
                    messageInput.text = "";
                }
            }
        }
    }

    Connections {
        target: apiClient

        function onResponseReceived(answer) {
            messageModel.append({
                "text": answer,
                "sender": "ai"
            });
            listView.positionViewAtEnd();
        }

        function onErrorOccurred(message) {
            messageModel.append({
                "text": "Ошибка: " + message,
                "sender": "system"
            });
        }
    }
}
