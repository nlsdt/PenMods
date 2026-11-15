import QtQuick 2.12

YBackgroundIgnoreMouseEvent {
    id: id_animation_tip_dialog
    anchors.fill: parent
    visible: false

    readonly property alias dialogAnimationItem: id_dialog_animation
    readonly property alias tipsItem: id_tips

    property alias text: id_tips.text

    signal closed()

    function show() {
        visible = true
        id_dialog_animation.play()
    }

    function close() {
        id_dialog_animation.stopPlay()
        visible = false
        id_animation_tip_dialog.closed()
    }

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
            id_animation_tip_dialog.close()
        }
    }

    YTextMedium {
        id: id_tips
        width: paintedWidth
        height: 44
        font.pixelSize: 18
        font.weight: Font.Bold
        horizontalAlignment: YTextMedium.AlignHCenter
        verticalAlignment: YTextMedium.AlignVCenter
        font.family: fontManager.fontFamilyZhCn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    YAnimatedImagesView {
        id: id_dialog_animation
        objectName: "YAnimationTipDialog.qml"
    }
}
