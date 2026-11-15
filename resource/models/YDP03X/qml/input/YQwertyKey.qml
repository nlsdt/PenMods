import QtQuick 2.12

import "../common"

// PenMods3 QWERTY 键盘按键
// 用法:
//   YQwertyKey { text: "q"; onKeyPressed: ... }
//   YQwertyKey { text: "⇧"; accent: true; isChecked: shiftOn; onKeyLongPressed: togglePinyin() }
YMouseArea {
    id: id_key
    objectName: "YQwertyKey.qml_YMouseArea"
    width: 74
    height: 34

    property string text: ""      // 按键显示的字符 / 点击后插入的字符
    property string icon: ""      // 非空时用图标代替文字（image://icons 名，如 "input/ic_delete"）
    property bool accent: false   // 特殊键（shift/功能键）深色底
    property bool isChecked: false // 激活态（shift 大写、拼音模式等）绿色底

    signal keyPressed(string text)
    signal keyLongPressed()

    property bool _longHeld: false
    readonly property bool highlighted: enabled && visible && (pressed || highlightTimer.running)

    Timer {
        id: highlightTimer
        interval: 150
    }

    onPressed: {
        _longHeld = false
        highlightTimer.restart()
    }
    onPressAndHold: {
        _longHeld = true
        keyLongPressed()
    }
    onReleased: {
        if (enabled && !_longHeld) {
            keyPressed(id_key.text)
        }
        _longHeld = false
    }
    onCanceled: {
        _longHeld = false
        highlightTimer.stop()
    }
    onEnabledChanged: if (!enabled) highlightTimer.stop()
    onVisibleChanged: if (!visible) highlightTimer.stop()

    Item {
        anchors.fill: parent
        scale: id_key.pressed ? 0.99 : 1
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

        // 按键底
        Rectangle {
            id: id_key_bg
            anchors.fill: parent
            radius: 10
            color: id_key.isChecked ? YColors.green
                                   : (id_key.accent ? YColors.buttonNormal : YColors.grayNormal)
        }

        // 按下高亮
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#4A4B52"
            visible: id_key.highlighted
        }

        // 键面图标
        YImage {
            id: id_key_icon
            anchors.centerIn: parent
            sourceSize: Qt.size(28, 28)
            imageName: id_key.icon
            visible: id_key.icon.length > 0
        }

        // 键面文字
        YTextMedium {
            anchors.centerIn: parent
            font.pixelSize: 22
            color: YColors.white
            text: id_key.text
            visible: id_key.icon.length === 0
        }
    }
}
