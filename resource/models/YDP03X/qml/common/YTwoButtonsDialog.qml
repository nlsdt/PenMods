import QtQuick 2.12

YButtonDialogBase {
    id: id_two_buttons_dialog

    readonly property alias leftButtonItem: id_button_left
    readonly property alias rightButtonItem: id_button_right

    signal leftClicked()
    signal rightClicked()

    YButton {
        id: id_button_left
        implicitWidth: 141
        color: YColors.buttonDisabled
        onClicked: {
            id_two_buttons_dialog.leftClicked()
        }
    }

    YButton {
        id: id_button_right
        implicitWidth: 141
        anchors.right: parent.right
        color: YColors.yellow
        onClicked: {
            id_two_buttons_dialog.rightClicked()
        }
    }
}


