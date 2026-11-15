import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../commons"

YBackgroundIgnoreMouseEvent {
    id: id_qwe_text_input
    objectName: ""
    implicitWidth: YEnum.Screen.Width
    implicitHeight: YEnum.Screen.Height
    visible: false

    property string text: ""
    property int length: 0
    readonly property int editAreaWidthLimit: 588

    signal editFinished(int cursorPosition)
    signal editClear()
    signal quitEdit()
    signal requestEnteredTooLongTip()

    function show(cursorPosition) {
        id_input_core.cursorPosition = cursorPosition
        id_input_core.forceActiveFocus()
        visible = true
    }

    Flickable {
        id: id_input_core_area
        anchors.left: parent.left
        anchors.leftMargin: 90
        width: Math.min(editAreaWidthLimit, contentWidth)
        height: 72
        contentWidth: id_input_core.width
        pressDelay: 800
        TextInput {
            id: id_input_core
            width: Math.max(editAreaWidthLimit, contentWidth)
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: TextInput.AlignVCenter
            font.family: qmlGlobal.fontFamilyEnUs
            font.pixelSize: 30
            color: YColors.white
            selectedTextColor: YColors.transparent
            cursorDelegate: id_cursor_delegate
            text: id_qwe_text_input.text
            onCursorPositionChanged: {
                const currentPosX = cursorRectangle.x + 5 - id_input_core_area.contentX
                if ((currentPosX < 0) || (currentPosX > editAreaWidthLimit)) {
                    id_input_core_area.contentX = Math.min(Math.max(cursorRectangle.x + 5 - editAreaWidthLimit, 0),
                                                           width - editAreaWidthLimit)
                }
            }

            function del() {
                if (cursorPosition > 0) {
                    remove(cursorPosition, cursorPosition - 1)
                }
            }

            function delToStart() {
                if (cursorPosition > 0) {
                    remove(cursorPosition, 0)
                }
            }

            function inputText(newText) {
                insert(cursorPosition, newText)
            }

            readonly property int maximumLength: id_qwe_text_input.text.length + articleManager.maximumTextLength - id_qwe_text_input.length
            function checkTooLong() {
                if(maximumLength > 0 && length >= maximumLength) {
                    if(length > maximumLength){
                        requestEnteredTooLongTip()
                        remove(cursorPosition, cursorPosition - length + maximumLength)
                    }
                }
            }

            onLengthChanged: {
                checkTooLong()
            }
        }
    }

    Rectangle {
        id: id_text_edit_left_clip
        implicitWidth: 72
        implicitHeight: 72
        color: YColors.black
    }

    YRectangle {
        implicitHeight: 72
        implicitWidth: 18
        anchors.left: id_text_edit_left_clip.right
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: YColors.black }
            GradientStop { position: 1.0; color: YColors.transparent }
        }

        YButtonBaseMouseArea {
            anchors.fill: parent
            onValidClicked: {
                id_input_core.cursorPosition = 0
            }
        }
    }

    YBackButton {
        id: id_back_button
        iconButtonBackgroundItem.anchors.verticalCenter:
            iconButtonBackgroundItem.parent.verticalCenter
        width: 76
        height: 68
        onClicked: {
            quitEdit()
        }
    }

    Rectangle {
        id: id_text_edit_right_clip
        implicitWidth: 104
        implicitHeight: 72
        anchors.right: parent.right
        color: YColors.black
    }

    YRectangle {
        implicitHeight: 72
        implicitWidth: 18
        anchors.right: id_text_edit_right_clip.left
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: YColors.transparent }
            GradientStop { position: 1.0; color: YColors.black }
        }

        YButtonBaseMouseArea {
            anchors.fill: parent
            onValidClicked: {
                id_input_core.positionAt(id_input_core_area.width, 18)
            }
        }
    }

    YIconButton {
        id: id_ok_button
        radius: 16
        implicitWidth: 82
        implicitHeight: 50
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 11
        sourceSize: Qt.size(36, 36)
        imageName: "input/ic_selected_qwe"
        onValidClicked: {
            if (text !== id_input_core.text) {
                if (id_input_core.length > 0) {
                    const cursorPosition = id_input_core.cursorPosition
                    id_input_core.selectAll()
                    id_input_core.copy()
                    editFinished(cursorPosition)
                } else {
                    editClear()
                }
            }
            quitEdit()
        }
    }

    YQweTextInputKeyboard {
        id: id_qwe_text_input_keyboard
        anchors.fill: parent
        anchors.topMargin: 76
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        onKeyPressed: {
            id_input_core.inputText(text)
        }
        onDelPressed: {
            id_input_core.del()
        }
        onDelToStart: {
            id_input_core.delToStart()
        }
    }

    YRectangle {
        anchors.top: id_input_core_area.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: 20
        visible: 0 < id_qwe_text_input_keyboard.contentY
        gradient: Gradient {
            GradientStop { position: 0.0; color: YColors.black }
            GradientStop { position: 1.0; color: YColors.transparent }
        }
    }

    Component {
        id: id_cursor_delegate
        YCursorDelegateItem {
            implicitHeight: 36
            color: YColors.red
            running: !id_input_core.readOnly && id_input_core.activeFocus
        }
    }

    Component.onCompleted: {
        qmlGlobal.qweInputWidgetShowing = true
    }

    Component.onDestruction: {
        qmlGlobal.qweInputWidgetShowing = false
    }
}
