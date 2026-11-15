import QtQuick 2.12
import QtQml 2.12

import BaseQml 1.0
import com.youdao.pen 1.0
import com.youdao.input 1.0

import "../common"
import "../i18n"

// =====================================================================
// PenMods3 键盘输入页 — 参照 2 代 PenMods 的 rime 拼音思路复刻到 3 代：
//   * QWERTY 键盘（3 代屏幕更宽，不再用 2 代的 ABCD 布局）
//   * 水平可滑动键盘行（数字/符号行超宽时横向滑动）
//   * 上方为多行输入编辑区：高度随行数增长，整页可上下滚动，
//     键盘位于内容底部（滑下去用键盘，滑上来扩大显示区）
//   * 点 [中/EN] 切换 rime 拼音模式，带候选词条
// =====================================================================
YPage {
    id: id_input_page
    visible: true
    objectName: "YPage===YInputPage.qml"

    property alias placeHolderText: id_input_text_title_area.placeHolderText

    // 打开时预填的文本（如文件重命名的原文件名），光标自动放到末尾
    property string initialText: ""
    property bool secret: false
    property bool allowEmpty: false
    property bool closeOnAccept: true

    signal inputFinished(string text)

    // ---------- 键盘状态 ----------
    property int currentInputStatus: YBaseEnum.InputStatus.Lower

    readonly property bool isLetterMode: currentInputStatus === YBaseEnum.InputStatus.Lower
                                         || currentInputStatus === YBaseEnum.InputStatus.Upper
    readonly property bool isNumberMode: currentInputStatus === YBaseEnum.InputStatus.Number
    readonly property bool isSymbolMode: currentInputStatus === YBaseEnum.InputStatus.Symbol

    // ---------- rime 拼音状态 ----------
    property bool isPinyinMode: false
    property int currentPinyinLen: 0

    // ---------- 几何 ----------
    readonly property int keyH: 42
    readonly property int keyW: 74
    readonly property int keySpacing: 4

    // ---------- rime 后端 ----------
    RimeWrapper {
        id: id_rime_backend

        onCommitText: {

            for (var i = 0; i < currentPinyinLen; i++) {
                id_input_text_title_area.delChar();
            }

            id_input_text_title_area.enterChar(text);

            var remaining = id_rime_backend.preeditText;
            if (remaining.length > 0) {
                id_input_text_title_area.enterChar(remaining);
                currentPinyinLen = remaining.length;
            } else {
                currentPinyinLen = 0;
                id_candidate_model.clear();
            }
        }

        onCandidatesChanged: {
            id_candidate_model.clear();
            var list = id_rime_backend.candidates;
            for (var i = 0; i < list.length; i++) {
                id_candidate_model.append({ "text": list[i] });
            }
        }
    }

    ListModel {
        id: id_candidate_model
    }

    // ---------- 输入逻辑 ----------
    function togglePinyinMode() {
        if (secret) return;
        isPinyinMode = !isPinyinMode;
        id_rime_backend.clear();
        id_candidate_model.clear();
        currentPinyinLen = 0;
        console.log("=== 切换拼音模式: " + isPinyinMode + " ===");
    }

    function enterText(text) {

        if (isPinyinMode) {
            var lowerText = text.toLowerCase();
            id_input_text_title_area.enterChar(text);
            currentPinyinLen += text.length;
            id_rime_backend.processKey(lowerText);
        } else {
            id_input_text_title_area.enterChar(text);
        }
    }

    function selectCandidate(index, text) {
        id_rime_backend.selectCandidate(index);
    }

    function resetInput(text) {
        isPinyinMode = false;
        id_rime_backend.clear();
        id_candidate_model.clear();
        currentPinyinLen = 0;
        id_input_text_title_area.clear();
        if (text && text.length > 0)
            id_input_text_title_area.enterChar(text);
    }

    function delChar() {
        if (isPinyinMode && currentPinyinLen > 0) {
            id_input_text_title_area.delChar();
            currentPinyinLen = Math.max(0, currentPinyinLen - 1);
            id_rime_backend.processKey("BackSpace");
        } else {
            id_input_text_title_area.delChar();
        }
    }

    function clearAll() {
        id_rime_backend.clear();
        id_candidate_model.clear();
        currentPinyinLen = 0;
        id_input_text_title_area.clear();
    }

    function newLine() {
        if (secret) return;
        if (currentPinyinLen > 0) {
            id_rime_backend.clear();
            currentPinyinLen = 0;
        }
        id_input_text_title_area.enterChar('\n');
    }

    function spaceKey() {
        if (isPinyinMode && id_candidate_model.count > 0) {
            selectCandidate(0);
        } else {
            id_input_text_title_area.enterChar(' ');
        }
    }

    function switchInputStatus(status) {
        currentInputStatus = status;
        YInputProperty.currentInputStatus = status;
    }

    Component.onCompleted: {
        id_input_text_title_area.setInitialText(initialText);
        if (visible) {
            YInputProperty.inputPageShowing = true;
            keyBoard.inputPageShowing = true;
            keyBoard.autoSendScan = false;
        }
    }
    Component.onDestruction: {
        YInputProperty.inputPageShowing = false;
        keyBoard.inputPageShowing = false;
    }

    // ---------- 布局：整页纵向滚动 ----------
    Flickable {
        id: id_page_flick
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: id_content_column.height
        pressDelay: 120
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: id_content_column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            spacing: 4

            // ===== 上方多行输入编辑区（高度随内容增长）=====
            YInputTextTitleArea {
                id: id_input_text_title_area
                secret: id_input_page.secret
                allowEmpty: id_input_page.allowEmpty
                anchors.left: parent.left
                anchors.right: parent.right
                onBacked: {
                    backButtonClicked();
                }
                onAccepted: {
                    if (currentPinyinLen > 0) {
                        id_rime_backend.clear();
                        currentPinyinLen = 0;
                        id_candidate_model.clear();
                    }
                    var closeAfter = closeOnAccept;
                    inputFinished(id_input_text_title_area.text);
                    if (closeAfter) backButtonClicked();
                }
            }

            // ===== 拼音候选词条 =====
            Item {
                id: id_candidate_view
                visible: id_input_page.isPinyinMode
                anchors.left: parent.left
                anchors.right: parent.right
                height: 42
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: "#2B2B2B"
                    radius: 10
                    border.color: "#3F3F3F"
                    border.width: 1
                }

                Item {
                    id: id_preedit_container
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: id_pre_edit.text.length > 0 ? id_pre_edit.contentWidth + 22 : 0
                    visible: width > 0

                    YTextMedium {
                        id: id_pre_edit
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: id_rime_backend.preeditText
                        color: "#AAAAAA"
                        font.pixelSize: 18
                    }

                    Rectangle {
                        width: 1
                        height: 20
                        color: "#555555"
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                ListView {
                    id: id_candidate_list
                    anchors.left: id_preedit_container.right
                    anchors.leftMargin: id_preedit_container.visible ? 8 : 4
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    orientation: ListView.Horizontal
                    clip: true
                    model: id_candidate_model
                    spacing: 8

                    delegate: Item {
                        width: id_candidate_text.contentWidth + 20
                        height: id_candidate_list.height

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 8
                            color: id_candidate_ma.pressed ? "#444444" : "transparent"
                        }

                        YTextMedium {
                            id: id_candidate_text
                            anchors.centerIn: parent
                            text: model.text
                            font.pixelSize: 20
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: id_candidate_ma
                            anchors.fill: parent
                            onClicked: {
                                selectCandidate(index);
                            }
                        }
                    }
                }

                YTextMedium {
                    anchors.centerIn: parent
                    text: "点 [中] 键退出拼音"
                    visible: id_input_page.isPinyinMode && id_rime_backend.preeditText.length === 0 && id_candidate_model.count === 0
                    color: "#666666"
                    font.pixelSize: 14
                }
            }

            // ===== QWERTY 键盘 =====
            Column {
                id: id_keyboard_column
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: id_input_page.keySpacing

                // ---- 字母行 1: q w e r t y u i o p ----
                Flickable {
                    id: id_flk_letters_1
                    visible: id_input_page.isLetterMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_flk_letters_1.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_letters_1
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: id_input_page.currentInputStatus === YBaseEnum.InputStatus.Upper
                                      ? modelData.toUpperCase() : modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 字母行 2: a s d f g h j k l ----
                Flickable {
                    id: id_flk_letters_2
                    visible: id_input_page.isLetterMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_flk_letters_2.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_letters_2
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: id_input_page.currentInputStatus === YBaseEnum.InputStatus.Upper
                                      ? modelData.toUpperCase() : modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 字母行 3: ⇧ z x c v b n m ----
                Flickable {
                    id: id_flk_letters_3
                    visible: id_input_page.isLetterMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_flk_letters_3.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_letters_3
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: id_input_page.keySpacing

                        YQwertyKey {
                            width: 110
                            height: id_input_page.keyH
                            text: "⇧"
                            accent: true
                            isChecked: id_input_page.currentInputStatus === YBaseEnum.InputStatus.Upper
                            onKeyPressed: {
                                id_input_page.switchInputStatus(
                                    id_input_page.currentInputStatus === YBaseEnum.InputStatus.Upper
                                    ? YBaseEnum.InputStatus.Lower : YBaseEnum.InputStatus.Upper);
                            }
                        }

                        Repeater {
                            model: ["z", "x", "c", "v", "b", "n", "m"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: id_input_page.currentInputStatus === YBaseEnum.InputStatus.Upper
                                      ? modelData.toUpperCase() : modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 数字行 1: 1 2 3 4 5 6 7 8 9 0 ----
                Flickable {
                    id: id_flk_numbers_1
                    visible: id_input_page.isNumberMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_row_numbers_1.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_numbers_1
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 数字行 2（超宽，水平滑动）: . , ? ! ' - / : ( ) @ ----
                Flickable {
                    id: id_flk_numbers_2
                    visible: id_input_page.isNumberMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_row_numbers_2.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_numbers_2
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: [".", ",", "?", "!", "'", "-", "/", ":", "(", ")", "@"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 符号行 1: . , ? ! ' " : ; ( ) ----
                Flickable {
                    id: id_flk_symbols_1
                    visible: id_input_page.isSymbolMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_row_symbols_1.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_symbols_1
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: [".", ",", "?", "!", "'", "\"", ":", ";", "(", ")"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 符号行 2: [ ] { } # % ^ & * + ----
                Flickable {
                    id: id_flk_symbols_2
                    visible: id_input_page.isSymbolMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_row_symbols_2.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_symbols_2
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: ["[", "]", "{", "}", "#", "%", "^", "&", "*", "+"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 符号行 3: = _ \ | ~ < > $ ￥ @ ----
                Flickable {
                    id: id_flk_symbols_3
                    visible: id_input_page.isSymbolMode
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_row_symbols_3.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_symbols_3
                        spacing: id_input_page.keySpacing

                        Repeater {
                            model: ["=", "_", "\\", "|", "~", "<", ">", "$", "￥", "@"]
                            delegate: YQwertyKey {
                                width: id_input_page.keyW
                                height: id_input_page.keyH
                                text: modelData
                                onKeyPressed: { id_input_page.enterText(text) }
                            }
                        }
                    }
                }

                // ---- 功能行: [中/EN] [123] [符号] [⌫] [空格] [,] [.] [换行] ----
                Flickable {
                    id: id_flk_functions
                    width: parent.width
                    height: id_input_page.keyH
                    contentWidth: id_flk_functions.width
                    contentHeight: id_input_page.keyH
                    clip: true
                    pressDelay: 60
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: id_row_functions
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: id_input_page.keySpacing

                        // 中/EN 拼音切换（数字/符号模式下为返回字母）
                        YQwertyKey {
                            width: 84
                            height: id_input_page.keyH
                            text: id_input_page.isLetterMode
                                  ? (id_input_page.isPinyinMode ? "中" : "EN") : "abc"
                            isChecked: id_input_page.isLetterMode && id_input_page.isPinyinMode
                            onKeyPressed: {
                                if (id_input_page.isLetterMode) {
                                    id_input_page.togglePinyinMode();
                                } else {
                                    id_input_page.switchInputStatus(YBaseEnum.InputStatus.Lower);
                                }
                            }
                        }

                        // 123 数字模式
                        YQwertyKey {
                            width: 74
                            height: id_input_page.keyH
                            text: "123"
                            isChecked: id_input_page.isNumberMode
                            onKeyPressed: {
                                id_input_page.switchInputStatus(id_input_page.isNumberMode
                                                                ? YBaseEnum.InputStatus.Lower
                                                                : YBaseEnum.InputStatus.Number);
                            }
                        }

                        // 符号模式
                        YQwertyKey {
                            width: 74
                            height: id_input_page.keyH
                            text: "符号"
                            isChecked: id_input_page.isSymbolMode
                            onKeyPressed: {
                                id_input_page.switchInputStatus(id_input_page.isSymbolMode
                                                                ? YBaseEnum.InputStatus.Lower
                                                                : YBaseEnum.InputStatus.Symbol);
                            }
                        }

                        // 删除（长按清空）
                        YQwertyKey {
                            width: 80
                            height: id_input_page.keyH
                            icon: "input/ic_delete"
                            accent: true
                            onKeyPressed: {
                                id_input_page.delChar();
                            }
                            onKeyLongPressed: {
                                id_input_page.clearAll();
                            }
                        }

                        // 空格（拼音模式优先选第一个候选词）
                        YQwertyKey {
                            width: 150
                            height: id_input_page.keyH
                            text: "空格"
                            accent: true
                            onKeyPressed: {
                                id_input_page.spaceKey();
                            }
                        }

                        YQwertyKey {
                            width: id_input_page.keyW
                            height: id_input_page.keyH
                            text: ","
                            onKeyPressed: { id_input_page.enterText(text) }
                        }

                        YQwertyKey {
                            width: id_input_page.keyW
                            height: id_input_page.keyH
                            text: "."
                            onKeyPressed: { id_input_page.enterText(text) }
                        }

                        // 换行
                        YQwertyKey {
                            width: 88
                            height: id_input_page.keyH
                            text: "换行"
                            accent: true
                            onKeyPressed: {
                                id_input_page.newLine();
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------- 系统事件 ----------
    Connections {
        target: baseSignals
        ignoreUnknownSignals: true
        enabled: id_input_page.visible
        function onCloseInputPageWhileHomeKeyReleased() {
            id_input_page.backButtonClicked();
        }
    }

    onVisibleChanged: {
        YInputProperty.inputPageShowing = visible;
        keyBoard.inputPageShowing = visible;   // 输入页显示时拦截扫描结果拼入输入框
        if (visible) {
            if (initialText.length > 0) {
                id_input_text_title_area.setInitialText(initialText);
            }
        } else {
            isPinyinMode = false;
            id_rime_backend.clear();
            id_candidate_model.clear();
            currentPinyinLen = 0;
        }
    }
}
