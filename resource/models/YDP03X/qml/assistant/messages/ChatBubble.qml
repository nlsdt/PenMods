import QtQuick 2.12
import com.youdao.pen 1.0

Rectangle {
    id: root

    property string text: ""
    property bool isUser: false
    property bool isComplete: false
    property real maxBubbleWidth: 400
    property real containerWidth: YBaseEnum.Screen.Width
    property var fontFamily: fontManager.fontFamily

    signal pressAndHold(real mouseX, real mouseY)

    readonly property real targetWidth: Math.min(Math.max(Math.ceil(contentText.implicitWidth) + 26, 40), maxBubbleWidth)
    readonly property real targetHeight: Math.max(contentText.implicitHeight + 18, 36)

    width: targetWidth
    height: targetHeight
    x: isUser ? (containerWidth - width - 8) : 8

    radius: 16
    color: isUser ? "#2C2C2E" : "transparent"
    clip: true

    Behavior on width {
        enabled: !root.isComplete
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on height {
        enabled: !root.isComplete
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Text {
        id: contentText
        text: root.text
        anchors.fill: parent
        anchors.leftMargin: 13
        anchors.rightMargin: 13
        anchors.topMargin: 9
        anchors.bottomMargin: 9
        wrapMode: Text.WrapAnywhere
        color: "#FFFFFF"
        font.pixelSize: 14
        font.family: root.fontFamily || fontManager.fontFamily
        lineHeight: 1.3
        horizontalAlignment: Text.AlignLeft
        textFormat: (root.isUser || !root.isComplete) ? Text.PlainText : Text.RichText
        linkColor: "#62A8EA"
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        onPressAndHold: root.pressAndHold(mouseX, mouseY)
    }
}
