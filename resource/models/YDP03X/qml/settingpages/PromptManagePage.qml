import QtQuick 2.12
import BaseQml 1.0

import "../common"
import "../components"
import "../i18n"
import "../settingpages"

YBackButtonPage {
    id: id_prompt_page
    objectName: "YPage===PromptManagePage.qml"

    property var promptList: []

    function refreshPrompts() {
        var raw = chatbot.getPrompts();
        try {
            var parsed = JSON.parse(raw);
            promptList = parsed.prompts || [];
        } catch (e) {
            promptList = [];
        }
    }

    function getActivePromptId() {
        try {
            var active = JSON.parse(chatbot.getActivePrompt());
            return active.id || "";
        } catch (e) {
            return "";
        }
    }

    function getPromptName(promptId) {
        for (var i = 0; i < promptList.length; i++) {
            if (promptList[i].id === promptId)
                return promptList[i].name || promptId;
        }
        return promptId;
    }

    function switchPrompt(promptId) {
        chatbot.setActivePrompt(promptId);
        refreshPrompts();
        showToast("已切换至 " + getPromptName(promptId));
    }

    function openDetailPage(data) {
        var comp = Qt.createComponent("PromptDetailPage.qml");
        var init = function(page) {
            page.promptData = data || {};
            page.promptSaved.connect(function() { refreshPrompts(); });
            page.promptDeleted.connect(function() { refreshPrompts(); });
            page.backButtonClicked.connect(function() { page.todoDestroy(); });
            page.show();
        };
        if (comp.status === Component.Ready) {
            var obj = comp.incubateObject(id_prompt_page.parent);
            if (obj.status !== Component.Ready) {
                obj.onStatusChanged = function(s) { if (s === Component.Ready) init(obj.object); };
            } else {
                init(obj.object);
            }
        } else {
            console.error("PromptDetailPage load error:", comp.errorString());
        }
    }

    property string toastMsg: ""
    property bool toastVisible: false
    property int toastType: 0

    function showToast(msg, type) {
        toastMsg = msg;
        toastType = type || 0;
        toastVisible = true;
        id_toast_timer.restart();
    }

    Timer { id: id_toast_timer; interval: 2500; onTriggered: toastVisible = false }

    Component.onCompleted: { refreshPrompts(); }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: toastVisible ? 16 : -52
        width: Math.min(parent.width - 40, id_toast_text.implicitWidth + 32)
        height: 48
        radius: 6
        color: toastType === 2 ? "#4A1A1D" : toastType === 1 ? "#1A3A2A" : "#1A2A3A"
        z: 2000
        visible: opacity > 0
        opacity: toastVisible ? 1 : 0

        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            id: id_toast_text
            anchors.centerIn: parent
            width: parent.width - 32
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: toastMsg
            color: toastType === 2 ? "#FF6B6B" : toastType === 1 ? "#4CAF50" : YColors.grayText
            font.pixelSize: 24
            font.family: fontManager.fontFamilyZhCn
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_content_col.height + 20
        clip: true

        Column {
            id: id_content_col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            YSettingItemTitle { title: "提示词管理"; titlePixelSize: 26 }

            Repeater {
                model: promptList.length

                DescribedClickableTextBox {
                    readonly property var promptItem: promptList[index] || ({})
                    readonly property bool isActive: promptItem.id === getActivePromptId()

                    title: promptItem.name || ""
                    describe: (isActive ? "使用中  ·  " : "")
                              + (promptItem.content
                                 ? promptItem.content.substring(0, 30) + (promptItem.content.length > 30 ? "…" : "")
                                 : "暂无内容")
                    describeItem.color: isActive ? YColors.blueText : YColors.grayText
                    opacityChangableWhenPressed: false

                    onClicked: {
                        if (!isActive) switchPrompt(promptItem.id);
                        else openDetailPage(promptItem);
                    }
                }
            }

            DescribedClickableTextBox {
                title: "添加提示词"
                describe: "创建新的 AI 人格"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openDetailPage({})
            }
        }
    }
}
