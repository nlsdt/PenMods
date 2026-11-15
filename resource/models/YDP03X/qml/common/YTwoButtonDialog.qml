import QtQuick 2.12

import "../i18n"

YDialog {
    id: id_two_button_dialog
    readonly property alias buttonItemConfirm: id_button_confirm
    readonly property alias buttonItemCancel: id_button_cancel
    readonly property alias tipItem: id_tip

    signal clickedConfirm()
    signal clickedCancel()

    Item {
        anchors.fill: parent

        YText {
            id: id_tip
            font.pixelSize: 28
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.top: parent.top
            anchors.topMargin: 30
            height: 110
            horizontalAlignment: YText.AlignHCenter
            verticalAlignment: YText.AlignVCenter
            wrapMode: YText.Wrap
        }

        Item {
            anchors.top: id_tip.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            height: 80
            width: id_button_row.width

            Row {
                id: id_button_row
                spacing: 16
                height: parent.height

                YButton {
                    id: id_button_cancel
                    implicitWidth: 240
                    color: YColors.grayNormal
                    text: YBaseTranslateText.cancel
                    onClicked: {
                        id_two_button_dialog.clickedCancel()
                    }
                }

                YButton {
                    id: id_button_confirm
                    implicitWidth: 240
                    color: YColors.red
                    text: YBaseTranslateText.confirm
                    onClicked: {
                        id_two_button_dialog.clickedConfirm()
                    }
                }
            }
        }

        YIconButton {
            id: id_close_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height/2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "commons/close"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            onClicked: {
                close()
                closed()
            }
        }
    }
}
