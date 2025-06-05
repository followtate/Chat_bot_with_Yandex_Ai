import QtQuick 2.15
import QtQuick.Controls 2.15
Page {
    width: 540
        height: 960
        visible: true
         ListView {
                  id: listView
                  anchors.fill: parent
                  topMargin: 48
                  leftMargin: 48
                  bottomMargin: 48
                  rightMargin: 48
                  spacing: 20
                  model: ["Yandex GPT lite", "Yandex GPT"]
                  delegate: ItemDelegate {
                      width: 420
                      height: 70
                      background: Rectangle {
                          color: "#B8B8B8"
                          radius: 4
                      }onClicked: {
                           //открытие окна диалога
                              stackView.push("SecondPage.qml", {
                              inConversationWith: modelData
                              })

                      }required property string modelData
                           Row {
                          spacing: 20
                          anchors.verticalCenter: parent.verticalCenter
                           Image {
                                      id: avatar
                                      width: 60
                                      height: 60
                                      source: "images/" + modelData.replace(" ", "_") + ".png"
                           }Label {
                              text: modelData
                              font.pixelSize: 16
                              anchors.verticalCenter: parent.verticalCenter
                          }
                      }
                  }
              }
         }
