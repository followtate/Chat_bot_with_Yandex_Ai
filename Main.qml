import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 540
    height: 960
    title: qsTr("My AI app")
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "ConversationPage.qml"
    }
}
