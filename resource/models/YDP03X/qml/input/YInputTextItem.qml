import QtQuick 2.12

import "../common"

YMouseArea {
    id: id_input_text_item
    width: 72
    height: 72
    objectName: "YInputTextItem.qml_YMouseArea"

    property string text: ""

    onPressed: {
        id_text_item.text = text
        const pos = id_input_text_item.mapToItem(containerItem, 0, 0)
        const posX = pos.x + 36
        const posY = pos.y + 36
        charPressed(id_text_item.text, posX, posY)
    }
    onPressAndHold: {
        switch (YInputProperty.currentInputStatus) {
        case YBaseEnum.InputStatus.Lower:
            id_text_item.text = text.toUpperCase()
            break
        case YBaseEnum.InputStatus.Upper:
            id_text_item.text = text.toLowerCase()
            break
        case YBaseEnum.InputStatus.Number:
        case YBaseEnum.InputStatus.Symbol:
        default:
            id_text_item.text = text
            break
        }
    }
    onReleased: {
        charRelessed()
        charTriggered(id_text_item.text)
        id_text_item.text = text
    }
    onCanceled: {
        charRelessed()
        id_text_item.text = text
    }

    Rectangle {
        id: id_normal_area
        anchors.fill: parent
        radius: 16
        color: YColors.grayNormal
    }

    YTextMedium {
        id: id_text_item
        font.pixelSize: 32
        anchors.centerIn: parent
        text: id_input_text_item.text
    }

}
