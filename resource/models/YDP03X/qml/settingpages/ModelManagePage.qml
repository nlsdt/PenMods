import QtQuick 2.12
import BaseQml 1.0

import "../common"
import "../components"
import "../i18n"
import "../settingpages"

YBackButtonPage {
    id: id_model_page
    objectName: "YPage===ModelManagePage.qml"

    property var modelList: []

    function refreshModels() {
        var raw = chatbot.getModels();
        try {
            var parsed = JSON.parse(raw);
            modelList = parsed.models || [];
        } catch (e) {
            modelList = [];
        }
    }

    function getActiveModelId() {
        try {
            var active = JSON.parse(chatbot.getActiveModel());
            return active.id || "";
        } catch (e) {
            return "";
        }
    }

    function getModelName(modelId) {
        for (var i = 0; i < modelList.length; i++) {
            if (modelList[i].id === modelId)
                return modelList[i].name || modelId;
        }
        return modelId;
    }

    function switchModel(modelId) {
        chatbot.setActiveModel(modelId);
        refreshModels();
        showToast("已切换至 " + getModelName(modelId));
    }

    function openDetailPage(data) {
        var comp = Qt.createComponent("ModelDetailPage.qml");
        var init = function(page) {
            page.modelData = data || {};
            page.modelSaved.connect(function() { refreshModels(); });
            page.modelDeleted.connect(function() { refreshModels(); });
            page.backButtonClicked.connect(function() { page.todoDestroy(); });
            page.show();
        };
        if (comp.status === Component.Ready) {
            var obj = comp.incubateObject(id_model_page.parent);
            if (obj.status !== Component.Ready) {
                obj.onStatusChanged = function(s) { if (s === Component.Ready) init(obj.object); };
            } else {
                init(obj.object);
            }
        } else {
            console.error("ModelDetailPage load error:", comp.errorString());
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

    Component.onCompleted: { refreshModels(); }

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

            YSettingItemTitle { title: "模型管理"; titlePixelSize: 26 }

            Repeater {
                model: modelList.length

                DescribedClickableTextBox {
                    readonly property var modelItem: modelList[index] || ({})
                    readonly property bool isActive: modelItem.id === getActiveModelId()

                    title: modelItem.name || ""
                    describe: (isActive ? "使用中  ·  " : "") + (modelItem.provider || modelItem.modelId || "")
                    describeItem.color: isActive ? YColors.blueText : YColors.grayText
                    opacityChangableWhenPressed: false

                    onClicked: {
                        if (!isActive) switchModel(modelItem.id);
                        else openDetailPage(modelItem);
                    }
                }
            }

            DescribedClickableTextBox {
                title: "添加模型"
                describe: "配置新的 AI 模型"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openDetailPage({})
            }
        }
    }
}
