import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "../timers"
import "../commons"

YBackgroundIgnoreMouseEvent {
    id: id_edit_widget
    objectName: "YMathExerciseEditWidget.qml"
    anchors.fill: parent
    visible: false

    property alias submitText: id_text_edit.text
    property string appendText: ""

    signal requestEnteredTooLongTip()

    signal requestNoInputTipClosed()

    function show() {
        visible = true
        id_text_edit.forceActiveFocus()
        id_text_edit.cursorPosition = submitText.length
    }

    function close() {
        visible = false
    }

    Flickable {
        id: id_text_edit_area
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 112
        contentHeight: id_container.height
        enabled: true
        pressDelay: 800

        function positionToEnd() {
            contentY = id_container.height - height
            returnToBounds()
        }

        Column {
            id: id_container
            anchors.left: parent.left
            anchors.right: parent.right

            YSpacingForColumn {
                implicitHeight: 20
            }

            TextEdit {
                id: id_text_edit
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(contentHeight, YEnum.Screen.Height - 40)
                color: YColors.white
                font.family: qmlGlobal.fontFamily
                font.pixelSize: 30
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                textFormat: TextEdit.PlainText
                cursorDelegate: id_cursor_delegate
                selectedTextColor: YColors.transparent
                focus: true
//                text: "I'm glad to know that you come to my city at the summer vacation. However, I'm afraid there're some bad news. I'm planning to participate in an international conference to held in another city during the time of you visit. All the top scientist in my field will show up at the conference. More importantly, I'm fortunate enough tp have been selected to give a speech on behalf of my research team at the conference. It's a nice chance to improve my oral English, and communicate with other scientists. I really can't miss it as it is very important for me. I hope you have fun."

                property bool autoCheckTooLength: true
                property int maximumLength: 5000/*articleManager.maximumTextLength*/
                readonly property bool isMaximumLength: length === maximumLength
                function checkTooLong() {
                    if(maximumLength > 0 && length >= maximumLength) {
                        if(length > maximumLength){
                            requestEnteredTooLongTip()
                            remove(cursorPosition, cursorPosition - length + maximumLength)
                        }
                    }
                }

                property int lastCheckStart: -1
                property int lastCheckEnd: -1
                function currentLineText() {
                    lastCheckStart = text.lastIndexOf('\n', cursorPosition - 1) + 1;
                    lastCheckEnd = text.indexOf('\n', cursorPosition);
                    if (-1 === lastCheckEnd) {
                        lastCheckEnd = length
                    }
                    return getText(lastCheckStart, lastCheckEnd)
                }

                function replaceFromPasteBoard(newCursorPosition){
                    select(lastCheckStart, lastCheckEnd)
                    paste()
                    cursorPosition = lastCheckStart + newCursorPosition
                }

                function removeCurrentLine(){
                    remove(lastCheckStart, lastCheckEnd)
                    cursorPosition = lastCheckStart
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

                function inputReturn() {
                    inputText('\n')
                }

                function appendResult(result) {
                    if (result.length > 0) {
                        const curPos = cursorPosition
                        const lastChar = getText(curPos, curPos - 1);
                        const nextChar = getText(curPos, curPos + 1);
                        if (!result.startsWith(" ") && (lastChar.length > 0)
                                && (lastChar !== " ") && (lastChar !== "\n")) {
                            result = " " + result
                        }
                        if (!result.endsWith(" ") && (nextChar.length > 0)
                                && (nextChar !== " ") && (nextChar !== "\n")) {
                            result = result + " "
                        }
                        insert(curPos, result)
                    }
                }

                onLengthChanged: {
                    if (autoCheckTooLength) {
                        checkTooLong()
                    }
                    if (0 === length) {
                        focus = false
                    }
                }

                onCursorPositionChanged: {
                    const currentPosY = cursorRectangle.y - id_text_edit_area.contentY
                    if ((currentPosY < 20) || (currentPosY > YEnum.Screen.Height - 76)) {
                        YTimers.delayCall(120, function(){
                            id_text_edit_area.contentY = Math.min(Math.max(cursorRectangle.y + 76 - YEnum.Screen.Height, 0),
                                                                  id_text_edit.height + 40 - YEnum.Screen.Height)
                        })
                    }
                    if (!id_text_edit.activeFocus) id_text_edit.forceActiveFocus()
                }

                onFocusChanged: {
                    if (focus && !activeFocus) id_text_edit.forceActiveFocus()
                }
            }

            YSpacingForColumn {
                implicitHeight: 20
            }
        }
    }

    Column {
        id: id_buttons_container
        spacing: 8
        width: 96
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        enabled: (id_text_edit.length > 0)

        property int incubatorCreateNoSubmitCount: 0
        property int incubatorCreateQweKeyboardCount: 0

        YTimer {
            id: id_del_delay_timer
            interval: 100
            repeat: (id_text_edit.length > 0) && id_del_button.pressed && id_del_button.mouseAreaItem.isPressAndHold
            onTriggered: {
                id_text_edit.del()
            }
        }

        YMathExerciseEditButton {
            id: id_del_button
            enabled: id_text_edit.activeFocus && (id_text_edit.length > 0)
            imageName: pressed ? "edit/delete_clicked"
                               : "edit/delete"
            onClicked: {
                id_text_edit.del()
            }
            onPressAndHold: {
                id_del_delay_timer.restart()
            }
        }

        YMathExerciseEditButton {
            enabled: id_text_edit.activeFocus && (id_text_edit.length > 0)
            imageName: "edit/return"
            onClicked: {
                if (!id_text_edit.isMaximumLength) {
                    id_text_edit.inputReturn()
                } else {
                    requestEnteredTooLongTip()
                }
            }
        }

        // 为编辑按钮占位
        YSpacingForColumn {
            id: id_space_for_edit_button
            implicitHeight: 52
        }

//        YMathExerciseEditButton {
//            enabled: id_text_edit.activeFocus && (id_text_edit.length > 0)
//            imageName: "edit/keyboard"
//            onValidClicked: {
//                if (!id_text_edit.isMaximumLength) {
//                    requestQweKeyboard(id_text_edit.currentLineText(),
//                                       id_text_edit.length)
//                } else {
//                    requestEnteredTooLongTip()
//                }
//            }
//        }

        YMathExerciseEditButton {
            id: id_submit_button
            color: YColors.green
            imageName: "edit/submit"
            enabled: (id_text_edit.length > 0) && !id_delay_append_timer.running && mathExerciseManager.isEditing
            onValidClicked: {
//                logManager.sendHttpLog("action=essay_submit")
//                id_article_submitting_tips.visible = true
//                articleManager.submitArticle(id_text_edit.text.trim())
                mathExerciseManager.submitExercise(id_text_edit.text.trim())
                mathExerciseManager.setIsEditing(false)
                id_delay_append_timer.times = 0
                // 此处不直接关闭编辑页面，在搜题结果页resultModel变化时再关闭。掩盖页面跳转
            }
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            mathExerciseManager.setIsEditing(false)
            id_edit_widget.close()
        }
    } // YVerticalTitleBar

    Component {
        id: id_cursor_delegate
        YCursorDelegateItem {
            implicitHeight: 36
            color: YColors.red
            running: !id_text_edit.readOnly && id_text_edit.activeFocus
            visible: running
        }
    }

    YTimer {
        id: id_delay_append_timer
        interval: 500

        property int times: 0

        function timesRestart() {
            if (++times < 4) {
                restart()
            } else {
                triggered()
            }
        }

        onTriggered: {
            if (!systemBase.isScanning) {
                times = 0

                id_text_edit.appendResult(appendText)
                YTimers.delayCall(120, id_text_edit_area.positionToEnd)


                systemBase.clearOcrLastResult()                
            }
        }
    }

    Connections {
        target: mathExerciseManager
        ignoreUnknownSignals: true
        function onScanMathExerciseResult(result, scanType) {
            appendText = result
            if (settingManager.isContinueScan && (scanType !== 0)) {
                id_delay_append_timer.timesRestart()
            } else {
                id_delay_append_timer.triggered()
            }
        }

        function onSubmitOcrFinished(onlineOcrResult) {
            id_text_edit.appendResult(onlineOcrResult)
            YTimers.delayCall(120, id_text_edit_area.positionToEnd)
//            newScanArticleAppend()
        }

        function onIsOcrRunningChanged() {
//            if (articleManager.isOcrRunning) {
//                id_text_edit_area.positionToEnd()
//            }
        }

//        function onSubmitFailed(submitType, errorMsg) {
//            if (2 === submitType) {

//            }
//        }
    }

    function requestQweKeyboard(text, length) {
        function newComponentInit(incubatorObject) {
            incubatorObject.editFinished.connect(id_text_edit.replaceFromPasteBoard)
            incubatorObject.editClear.connect(id_text_edit.removeCurrentLine)
            incubatorObject.quitEdit.connect(id_text_edit.forceActiveFocus)
            incubatorObject.quitEdit.connect(incubatorObject.destroy)
            incubatorObject.requestEnteredTooLongTip.connect(requestEnteredTooLongTip)
            systemBase.homeKeyPress.connect(incubatorObject.quitEdit)
            incubatorObject.text = text
            incubatorObject.length = length
            incubatorObject.show(id_text_edit.cursorPosition - id_text_edit.lastCheckStart)
        }

        const newComponent = Qt.createComponent(
                               "../qweinputmethod/YQweTextInput.qml")
        const incubator = newComponent.incubateObject(id_edit_widget)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --id_buttons_container.incubatorCreateQweKeyboardCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++id_buttons_container.incubatorCreateQweKeyboardCount
        } else {
            newComponentInit(incubator.object)
        }
    }
}
