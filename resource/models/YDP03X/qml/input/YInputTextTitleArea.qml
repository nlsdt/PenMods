import QtQuick 2.12

import "../i18n"
import "../common"

// PenMods3 输入区 — 多行编辑，高度随内容增长：
//   height = max(110, TextEdit.contentHeight + 20)
//   配合输入页整页纵向滚动：行数变多时输入区变高，键盘保持在内容底部。
Item {
    id: id_title_area_root
    anchors.left: parent.left
    anchors.right: parent.right
    height: Math.max(110, editor.contentHeight + 20)

    property bool secret: false
    property bool allowEmpty: false
    readonly property var editor: secret ? id_password_input : id_input_core
    readonly property bool acceptabled: allowEmpty || editor.length > 0
    readonly property string text: editor.text
    property alias placeHolderText: id_placeholder_text.text

    signal backed()
    signal accepted()
    signal textEdited()

    function delChar() {
        editor.remove(Math.max(0, editor.cursorPosition - 1),
                      editor.cursorPosition)
        if (!editor.activeFocus) {
            editor.forceActiveFocus()
        }
    }

    function delToStart() {
        if (editor.cursorPosition > 0) {
            editor.remove(editor.cursorPosition, 0)
        }
    }

    function enterSpacing() {
        editor.insert(editor.cursorPosition, " ")
        if (!editor.activeFocus) {
            editor.forceActiveFocus()
        }
    }

    function enterChar(text) {
        editor.insert(editor.cursorPosition, text)
        if (!editor.activeFocus) {
            editor.forceActiveFocus()
        }
    }

    function clear() {
        editor.clear()
    }

    // 预填初始文本并把光标放到末尾（重命名等场景直接接着编辑）
    function setInitialText(newText) {
        editor.text = newText
        editor.cursorPosition = newText.length
        if (!editor.activeFocus) {
            editor.forceActiveFocus()
        }
    }

    // 扫描（OCR）结果拼接到已有内容末尾（由 keyBoard.scanFinished 触发）
    function appendScanText(content) {
        if (content.length === 0) {
            return
        }
        editor.insert(editor.text.length, content)
        editor.cursorPosition = editor.text.length
        if (!editor.activeFocus) {
            editor.forceActiveFocus()
        }
    }

    // 文本编辑区（左侧，占满剩余宽度；右缘让给按钮列）
    TextEdit {
        id: id_input_core
        visible: !id_title_area_root.secret
        textFormat: TextEdit.PlainText
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: id_buttons_column.left
        anchors.rightMargin: 8
        font.family: fontManager.fontFamily
        font.pixelSize: 26
        color: YColors.white
        cursorDelegate: id_cursor_delegate
        wrapMode: TextEdit.WrapAnywhere
        selectByMouse: false
        onTextChanged: {
            id_title_area_root.textEdited()
        }

        YTextBase {
            id: id_placeholder_text
            anchors.fill: parent
            verticalAlignment: YText.AlignTop
            opacity: !id_input_core.length && !id_input_core.inputMethodComposing ? 1 : 0
            color: YColors.grayText
            font: id_input_core.font
            wrapMode: YText.Wrap
            text: YBaseTranslateText.inputTip
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    TextInput {
        id: id_password_input
        visible: id_title_area_root.secret
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: id_buttons_column.left
        anchors.rightMargin: 8
        font: id_input_core.font
        color: YColors.white
        cursorDelegate: id_cursor_delegate
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhHiddenText | Qt.ImhNoPredictiveText
        selectByMouse: false
        onTextChanged: id_title_area_root.textEdited()

        YTextBase {
            anchors.fill: parent
            verticalAlignment: YText.AlignTop
            opacity: !id_password_input.length && !id_password_input.inputMethodComposing ? 1 : 0
            color: YColors.grayText
            font: id_input_core.font
            wrapMode: YText.Wrap
            text: id_placeholder_text.text
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    // 右侧按钮列：返回 + 完成
    Column {
        id: id_buttons_column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 56
        spacing: 4

        YIconButton {
            id: id_back_button_bg
            width: 44
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 22
            icon: "ic_back"
            iconSourceSize: Qt.size(32, 32)

            YBackButtonBase {
                anchors.fill: parent
                anchors.margins: -14
                onTriggered: {
                    backed()
                }
            }
        }

        Item {
            width: 44
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter

            YIconButton {
                id: id_accepted_button_background
                anchors.fill: parent
                radius: 22
                color: YColors.grayNormal
                enabled: id_title_area_root.acceptabled
                imageName: "input/ic_selected"
                sourceSize: Qt.size(32, 32)
                onClicked: {
                    accepted()
                }
            }
        }
    }

    // 扫描（OCR）结果拦截：输入页显示时，按压笔头扫描的内容拼接进来
    Connections {
        target: keyBoard
        ignoreUnknownSignals: true
        function onScanFinished(content) {
            if (id_title_area_root.visible) id_title_area_root.appendScanText(content)
        }
    }

    Component {
        id: id_cursor_delegate
        YCursorDelegateItem {
            implicitHeight: 30
            color: YColors.red
            running: !id_title_area_root.editor.readOnly && id_title_area_root.editor.activeFocus
        }
    }
}
