import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    id: root

    property var chatModel: null
    property var blurSource: null
    property var fontFamily: fontManager.fontFamily

    signal editRequested(int index)
    signal regenerateRequested(int index)
    signal deleteSingleRequested(int index)
    signal deleteSubsequentRequested(int index)

    visible: opacity > 0
    z: 2000
    anchors.fill: parent
    opacity: 0

    property int targetIndex: -1
    property real menuScale: 0.8
    property bool _isShowing: false

    states: [
        State {
            name: "show"
            when: root._isShowing
            PropertyChanges { target: root; opacity: 1 }
            PropertyChanges { target: root; menuScale: 1.0 }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "show"
            ParallelAnimation {
                NumberAnimation { properties: "opacity"; duration: 150; easing.type: Easing.OutCubic }
                NumberAnimation { target: root; property: "menuScale"; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
        },
        Transition {
            from: "show"; to: ""
            ParallelAnimation {
                NumberAnimation { properties: "opacity"; duration: 150; easing.type: Easing.InCubic }
                NumberAnimation { target: root; property: "menuScale"; duration: 150; easing.type: Easing.InCubic }
            }
        }
    ]

    function showMenu(x, y, index) {
        if (!root.chatModel || index < 0 || index >= root.chatModel.count) return;

        targetIndex = index;
        var isUserMsg = root.chatModel.get(index).isUser;

        var menuWidth = 140;
        var buttonCount = 2;
        if (isUserMsg) buttonCount++;
        if (!isUserMsg) buttonCount++;
        var menuHeight = buttonCount * 44 + (buttonCount - 1) * 0.5;

        var safeMargin = 20;
        var targetX = Math.max(0, x);
        var targetY = Math.max(0, y);
        if (targetX + menuWidth > parent.width - safeMargin)
            targetX = Math.max(0, parent.width - menuWidth - safeMargin);
        if (targetY + menuHeight > parent.height - safeMargin)
            targetY = Math.max(0, parent.height - menuHeight - safeMargin);

        contentRect.x = targetX;
        contentRect.y = targetY;
        contentRect.height = menuHeight;

        _isShowing = true;
    }

    function hideMenu() {
        _isShowing = false;
    }

    FastBlur {
        anchors.fill: parent
        source: root.blurSource
        radius: 40
        opacity: root.opacity
        visible: opacity > 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.hideMenu()
    }

    Rectangle {
        id: contentRect
        width: 140
        height: {
            if (!root.chatModel || root.targetIndex < 0 || root.targetIndex >= root.chatModel.count) return 0;
            var isUserMsg = root.chatModel.get(root.targetIndex).isUser;
            var buttonCount = 2;
            if (isUserMsg) buttonCount++;
            if (!isUserMsg) buttonCount++;
            return buttonCount * 44 + (buttonCount > 1 ? (buttonCount - 1) * 0.5 : 0);
        }
        radius: 14
        color: "#CC1C1C1E"
        scale: root.menuScale
        clip: true
        border.color: "#3A3A3C"
        border.width: 0.5

        Behavior on height {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Column {
            anchors.fill: parent

            Item {
                width: parent.width
                height: 44
                visible: root.chatModel && root.targetIndex >= 0 && root.targetIndex < root.chatModel.count && root.chatModel.get(root.targetIndex).isUser

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: editMouse.pressed ? "#3A3A3C" : "transparent"
                    Behavior on color { ColorAnimation { duration: 50 } }
                }

                Text {
                    text: "编辑"
                    color: "white"
                    font.pixelSize: 16
                    font.family: root.fontFamily || fontManager.fontFamily
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: editMouse
                    anchors.fill: parent
                    onClicked: { root.hideMenu(); root.editRequested(root.targetIndex); }
                }
            }

            Rectangle {
                width: parent.width; height: 0.5
                color: "#444446"
                visible: root.chatModel && root.targetIndex >= 0 && root.targetIndex < root.chatModel.count && root.chatModel.get(root.targetIndex).isUser
            }

            Item {
                width: parent.width
                height: 44
                visible: root.chatModel && root.targetIndex >= 0 && root.targetIndex < root.chatModel.count && !root.chatModel.get(root.targetIndex).isUser

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: regenerateMouse.pressed ? "#3A3A3C" : "transparent"
                    Behavior on color { ColorAnimation { duration: 50 } }
                }

                Text {
                    text: "重新生成"
                    color: "#007AFF"
                    font.pixelSize: 16
                    font.family: root.fontFamily || fontManager.fontFamily
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: regenerateMouse
                    anchors.fill: parent
                    onClicked: { root.hideMenu(); root.regenerateRequested(root.targetIndex); }
                }
            }

            Rectangle {
                width: parent.width; height: 0.5
                color: "#444446"
                visible: root.chatModel && root.targetIndex >= 0 && root.targetIndex < root.chatModel.count && !root.chatModel.get(root.targetIndex).isUser
            }

            Item {
                width: parent.width
                height: 44

                Rectangle {
                    anchors.fill: parent
                    color: deleteSingleMouse.pressed ? "#3A3A3C" : "transparent"
                    Behavior on color { ColorAnimation { duration: 50 } }
                }

                Text {
                    text: "删除本条"
                    color: "#FF453A"
                    font.pixelSize: 16
                    font.family: root.fontFamily || fontManager.fontFamily
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: deleteSingleMouse
                    anchors.fill: parent
                    onClicked: { root.hideMenu(); root.deleteSingleRequested(root.targetIndex); }
                }
            }

            Item {
                width: parent.width
                height: 44

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: deleteMouse.pressed ? "#3A3A3C" : "transparent"
                    Behavior on color { ColorAnimation { duration: 50 } }
                }

                Text {
                    text: "删除本条及后续"
                    color: "#FF453A"
                    font.pixelSize: 16
                    font.family: root.fontFamily || fontManager.fontFamily
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: deleteMouse
                    anchors.fill: parent
                    onClicked: { root.hideMenu(); root.deleteSubsequentRequested(root.targetIndex); }
                }
            }
        }
    }
}
