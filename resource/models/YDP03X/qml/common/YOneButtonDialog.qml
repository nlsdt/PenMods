import QtQuick 2.12

YDialog {
    id: id_one_button_dialog
    readonly property alias buttonItem: id_button
    readonly property alias tipItem: id_tip

    signal clicked()

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

        YButton {
            id: id_button
            implicitWidth: 320
            anchors.top: id_tip.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: YColors.red
            onClicked: {
                id_one_button_dialog.clicked()
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


