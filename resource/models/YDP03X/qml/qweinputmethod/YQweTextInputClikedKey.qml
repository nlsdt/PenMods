import QtQuick 2.12

import BaseQml 1.0

YButtonBase {
    visible: id_key_text.text.length > 0
    implicitWidth: visible ? 62 : 0
    implicitHeight: visible ? 62 : 0
    radius: 14
    opacityOnPressed: false

    enum KeyMode {
        Lower,
        Upper,
        Symbol
    }

    property int keyMode: currentKeyMode

    property var textArray: null

    Rectangle {
        implicitWidth: 68
        implicitHeight: 68
        radius: 14
        color: YColors.buttonNormal
        anchors.centerIn: parent
        visible: mouseAreaItem.pressed
    }

    YText {
        id: id_key_text
        anchors.centerIn: parent
        font.pixelSize: mouseAreaItem.pressed ? 40 : 30
        text: null === textArray ? "" : textArray[keyMode]
    }

    onValidClicked: {
        keyPressed(id_key_text.text)
    }
}
