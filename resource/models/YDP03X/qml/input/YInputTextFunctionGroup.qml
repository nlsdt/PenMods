import QtQuick 2.12
import com.youdao.pen 1.0
import "../common"

Item {
    id: id_functions_group_root
    implicitWidth: 208
    implicitHeight: 232

    readonly property int spacing: 8
    signal delChar()
    signal enterSpace()
    signal requestClear()

    YInputTextFunctionButton {
        id: id_lower_chars_button
        checkedIndicatorScale: YEnum.InputStatus.Lower === YInputProperty.currentInputStatus
        onClicked: {
            YInputProperty.currentInputStatus = YEnum.InputStatus.Lower
        }
        imageName: "input/char_lower"
    }
    YInputTextFunctionButton {
        id: id_del_char_button
        anchors.left: id_lower_chars_button.right
        anchors.leftMargin: spacing
        onClicked: {
            delChar()
        }
        onPressAndHold: {
            requestClear()
        }
        imageName: pressed ? "input/ic_delete_clicked"
                           : "input/ic_delete"
    }
    YInputTextFunctionButton {
        id: id_upper_chars_button
        anchors.top: id_lower_chars_button.bottom
        anchors.topMargin: spacing
        checkedIndicatorScale: YEnum.InputStatus.Upper === YInputProperty.currentInputStatus
        onClicked: {
            YInputProperty.currentInputStatus = YEnum.InputStatus.Upper
        }
        imageName: "input/char_upper"
    }
    YInputTextFunctionButton {
        id: id_number_chars_button
        anchors.left: id_del_char_button.left
        anchors.top: id_upper_chars_button.top
        checkedIndicatorScale: YEnum.InputStatus.Number === YInputProperty.currentInputStatus
        onClicked: {
            YInputProperty.currentInputStatus = YEnum.InputStatus.Number
        }
        imageName: "input/char_digital"
    }
    YInputTextFunctionButton {
        id: id_symbol_chars_button
        anchors.top: id_upper_chars_button.bottom
        anchors.topMargin: spacing
        checkedIndicatorScale: YEnum.InputStatus.Symbol === YInputProperty.currentInputStatus
        onClicked: {
            YInputProperty.currentInputStatus = YEnum.InputStatus.Symbol
        }
        imageName: "input/char_punctuation"
    }
    YInputTextFunctionButton {
        id: id_space_char_button
        anchors.left: id_del_char_button.left
        anchors.top: id_symbol_chars_button.top
        onClicked: {
            enterSpace()
        }
        imageName: "input/ic_space"
    }

    Component.onCompleted: {
        console.log("ZDS=====YInputProperty.currentInputStatus: ", YInputProperty.currentInputStatus)
    }
}
