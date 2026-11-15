import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_index_widget
    objectName: "YArticleIndexWidget.qml"
    anchors.fill: parent

    signal requestHistory()

    YText {
        id: id_empty_tip
        font.pixelSize: 30
        textFormat: Text.RichText
        text: YTranslateText.articleEmptyTip.arg(YColors.red)
        anchors.left: parent.left
        anchors.leftMargin: 160
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        color: YColors.grayNormal
        implicitWidth: 228
        implicitHeight: 134
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50
        radius: 16
        opacity: id_history_button.pressed ? 0.6 : 1

        Row {
            height: 34
            anchors.centerIn: parent
            spacing: 11

            YImage {
                imageName: "article/history"
                sourceSize: Qt.size(30, 30)
                anchors.verticalCenter: parent.verticalCenter
                asynchronous: false
            }

            YText {
                font.pixelSize: 28
                text: YTranslateText.articleHistory
                anchors.verticalCenter: parent.verticalCenter
            }

            YImage {
                imageName: "article/history_clickable"
                sourceSize: Qt.size(24, 24)
                anchors.verticalCenter: parent.verticalCenter
                asynchronous: false
            }
        }

        YButtonBaseMouseArea {
            id: id_history_button
            anchors.fill: parent
            onValidClicked: {
                logManager.sendHttpLog("action=essay_history")
                requestHistory()
            }
        }
    }
}
