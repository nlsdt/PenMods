import QtQuick 2.12

YDialog {
    anchors.fill: parent
    animationEnabled: false
    default property alias buttonsConetnt: id_button_content.data

    readonly property alias tipItem: id_tip
    readonly property alias tipWrapItem: id_tip_wrap

    property alias topSpacing: id_top_spacing.height
    property alias wrapSpacing: id_wrap_spacing.height
    property alias buttonSpacing: id_button_spacing.height

    Rectangle {
        anchors.fill: parent
        color: "#CD000000"
    }

    Flickable {
        id: id_switch_item_view
        anchors.fill: parent
        contentHeight: id_column.height
        boundsBehavior: (contentHeight < height) ? ListView.StopAtBounds : ListView.DragAndOvershootBounds

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right

            YSpacingForColumn {
                id: id_top_spacing
                implicitHeight: 50

                YIconButton {
                    id: id_close_button
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: height/2
                    color: YColors.yellow
                    mouseAreaMargins: -22
                    imageName: "commons/close"
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    sourceSize: Qt.size(20,20)
                    onClicked: {
                        close()
                        closed()
                    }
                }
            }

            YText {
                id: id_tip
                font.pixelSize: 18
                anchors.left: parent.left
                anchors.leftMargin: 42
                anchors.right: parent.right
                anchors.rightMargin: 42
                horizontalAlignment: YText.AlignHCenter
                wrapMode: YText.Wrap
            }

            YSpacingForColumn {
                id: id_wrap_spacing
                implicitHeight: 6
                visible: id_tip_wrap.visible
            }

            YText {
                id: id_tip_wrap
                font.pixelSize: 16
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 40
                horizontalAlignment: YText.AlignHCenter
                wrapMode: YText.Wrap
                visible: text.length > 0
            }

            YSpacingForColumn {
                id: id_button_spacing
                implicitHeight: 12
            }

            YSpacingForColumn {
                id: id_button_content
                implicitHeight: 50
                anchors.leftMargin: 16
                anchors.rightMargin: 16
            }
        }
    }
}


