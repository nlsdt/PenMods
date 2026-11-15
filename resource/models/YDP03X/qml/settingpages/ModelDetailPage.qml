import QtQuick 2.12
import BaseQml 1.0

import "../common"
import "../components"
import "../i18n"
import "../settingpages"

YBackButtonPage {
    id: id_detail_page
    objectName: "YPage===ModelDetailPage.qml"

    // 传入的模型数据（空对象 = 新建）
    property var modelData: ({})
    readonly property bool isNew: !modelData || !modelData.id

    signal modelSaved()
    signal modelDeleted()

    // 本地编辑缓冲（从 modelData 初始化）
    property var fd: ({})

    // 当前激活的键盘字段 key（保留供外部可能引用）

    // 根据 modelData 初始化 fd
    function initFormData() {
        var cap = modelData.capabilities || {};
        fd = {
            "name":           modelData.name        || "",
            "provider":       modelData.provider    || "",
            "endpoint":       modelData.endpoint    || "",
            "modelId":        modelData.modelId     || "",
            "apiProtocol":    modelData.apiProtocol === "responses" ? "responses" : "chat_completions",
            "apiKey":         modelData.apiKey      || "",
            "temperature":    modelData.temperature !== undefined ? String(modelData.temperature) : "0.7",
            "maxContextSize": modelData.maxContextSize || 0,
            "capText":        cap.text      !== undefined ? cap.text      : true,
            "capVision":      cap.vision    || false,
            "capAudio":       cap.audio     || false,
            "capToolCall":    cap.toolCall  || false,
            "capReasoning":   cap.reasoning || false,
            "capImageGeneration": cap.imageGeneration || false,
            "reasoningEffort": modelData.reasoningEffort || "",
            "nativeWebSearchEnabled": modelData.nativeWebSearchEnabled || false,
            "nativeWebSearchProvider": modelData.nativeWebSearchProvider || "auto",
            "extraParams":    modelData.extraParams ? JSON.stringify(modelData.extraParams) : "",
            "proxyVisionModelId":  modelData.proxyVisionModelId  || "",
            "proxyVisionPrompt":   modelData.proxyVisionPrompt   || ""
        };
    }

    function openKeyboard(key, placeholder) {
        id_detail_pop.currentKey         = key;
        id_detail_pop.currentPlaceholder = placeholder;
        id_detail_pop.currentPrefill     = fd[key] !== undefined ? String(fd[key]) : "";
        var component = qmlCreateComponent("input/YInputPage");
        if (Component.Ready === component.status) {
            var incubator = component.incubateObject(id_detail_pop.containerItem);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(s) {
                    if (s === Component.Ready) id_detail_pop.inputPageCreated(incubator.object);
                };
            } else {
                id_detail_pop.inputPageCreated(incubator.object);
            }
        }
    }

    function saveModel() {
        if (!fd.name || !fd.endpoint || !fd.modelId) {
            showToast("名称、接口地址和模型 ID 为必填项", 2);
            return;
        }

        var modelId = isNew ? generateId(fd.name) : modelData.id;

        var modelObj = {
            "id":             modelId,
            "name":           fd.name,
            "provider":       fd.provider || "",
            "endpoint":       fd.endpoint,
            "modelId":        fd.modelId,
            "apiProtocol":    fd.apiProtocol,
            "apiKey":         fd.apiKey || "",
            "temperature":    isNaN(parseFloat(fd.temperature)) ? 0.7 : parseFloat(fd.temperature),
            "maxContextSize": fd.maxContextSize || 0,
            "reasoningEffort": fd.capReasoning ? fd.reasoningEffort : "",
            "nativeWebSearchEnabled": fd.apiProtocol === "responses" && fd.nativeWebSearchEnabled,
            "nativeWebSearchProvider": fd.nativeWebSearchProvider || "auto",
            "capabilities": {
                "text":      fd.capText,
                "vision":    fd.capVision,
                "audio":     fd.capAudio,
                "toolCall":  fd.capToolCall,
                "reasoning": fd.capReasoning,
                "imageGeneration": fd.capImageGeneration
            },
            "extraParams":    fd.extraParams || "",
            "proxyVisionModelId":  fd.proxyVisionModelId || "",
            "proxyVisionPrompt":   fd.proxyVisionPrompt  || ""
        };

        var success = chatbot.addModel(JSON.stringify(modelObj));
        if (success) {
            showToast(isNew ? "模型已添加" : "模型已更新", 1);
            modelSaved();
            backButtonClicked();
        } else {
            showToast("保存失败，请检查输入", 2);
        }
    }

    function generateId(name) {
        return name.toLowerCase().replace(/[^a-z0-9]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "") || "model";
    }

    function setFormField(key, value) {
        var next = {};
        for (var field in fd) next[field] = fd[field];
        next[key] = value;
        fd = next;
    }

    function reasoningEffortLabel(value) {
        var labels = { "": "默认", "none": "关闭", "minimal": "极低", "low": "低", "medium": "中", "high": "高", "xhigh": "极高" };
        return labels[value] || "默认";
    }

    function cycleReasoningEffort() {
        var values = ["", "none", "minimal", "low", "medium", "high", "xhigh"];
        var index = values.indexOf(fd.reasoningEffort);
        setFormField("reasoningEffort", values[(index + 1) % values.length]);
    }

    function nativeWebSearchProviderLabel(value) {
        var labels = { "auto": "自动识别", "openai": "OpenAI", "xai": "xAI", "compatible": "兼容服务" };
        return labels[value] || "自动识别";
    }

    function cycleNativeWebSearchProvider() {
        var values = ["auto", "openai", "xai", "compatible"];
        var index = values.indexOf(fd.nativeWebSearchProvider);
        setFormField("nativeWebSearchProvider", values[(index + 1) % values.length]);
    }

    property var visionModelList: []
    property bool proxySelectorOpen: false

    function refreshVisionModels() {
        var list = [];
        try {
            var modelsJson = JSON.parse(chatbot.getModels());
            var models = modelsJson.models || modelsJson;
            if (Array.isArray(models)) {
                for (var i = 0; i < models.length; i++) {
                    var m = models[i];
                    var cap = m.capabilities || {};
                    if (cap.vision && m.id !== (modelData.id || ""))
                        list.push({ "modelId": m.id, "modelName": m.name || m.id });
                }
            }
        } catch (e) {}
        visionModelList = list;
    }

    function getProxyModelName() {
        if (!fd.proxyVisionModelId) return "未设置";
        try {
            var modelsJson = JSON.parse(chatbot.getModels());
            var models = modelsJson.models || modelsJson;
            if (Array.isArray(models)) {
                for (var i = 0; i < models.length; i++) {
                    if (models[i].id === fd.proxyVisionModelId) return models[i].name || models[i].id;
                }
            }
        } catch (e) {}
        return "已删除的模型";
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

    Timer {
        id: id_toast_timer
        interval: 2500
        onTriggered: toastVisible = false
    }

    Component.onCompleted: {
        initFormData();
    }

    onModelDataChanged: {
        initFormData();
    }

    // Toast
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
        contentHeight: id_detail_col.height + 24
        clip: true

        Column {
            id: id_detail_col
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            YSettingItemTitle {
                titlePixelSize: 26
                title: isNew ? "添加模型" : "编辑模型"
            }

            // ─── 基本信息 ─────────────────────────────
            YText {
                text: "基本信息"
                color: YColors.grayText
                font.pixelSize: 24
                anchors.left: parent.left
                anchors.leftMargin: 4
            }

            DescribedClickableTextBox {
                title: "模型名称"
                describe: fd.name || "点击输入显示名称"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("name", "请输入模型名称")
            }

            DescribedClickableTextBox {
                title: "提供商"
                describe: fd.provider || "点击输入（选填）"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("provider", "请输入提供商名称")
            }

            // ─── 接口配置 ─────────────────────────────
            YText {
                text: "接口配置"
                color: YColors.grayText
                font.pixelSize: 24
                anchors.left: parent.left
                anchors.leftMargin: 4
            }

            DescribedClickableTextBox {
                title: "接口地址"
                describe: fd.endpoint || "点击输入 API 服务端点 URL"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("endpoint", "https://api.example.com/v1")
            }

            DescribedClickableTextBox {
                title: "模型 ID"
                describe: fd.modelId || "点击输入传给 API 的 model 参数"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("modelId", "请输入模型 ID")
            }

            DescribedSwitchItem {
                objectName: "ModelResponsesApi"
                title: "Responses API"
                description: "使用 /responses 协议"
                switchOn: fd.apiProtocol === "responses"
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: {
                    var responses = fd.apiProtocol !== "responses";
                    var chatEndpoint = "https://api.deepseek.com/v1/chat/completions";
                    var responsesEndpoint = "https://api.deepseek.com/v1/responses";
                    if (responses && fd.endpoint === chatEndpoint)
                        setFormField("endpoint", responsesEndpoint);
                    else if (!responses && fd.endpoint === responsesEndpoint)
                        setFormField("endpoint", chatEndpoint);
                    setFormField("apiProtocol", responses ? "responses" : "chat_completions");
                }
            }

            DescribedClickableTextBox {
                title: "API 密钥"
                describe: fd.apiKey ? "●".repeat(Math.min(fd.apiKey.length, 12)) : "点击输入身份验证密钥"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("apiKey", "请输入 API 密钥")
            }

            // ─── 高级选项 ─────────────────────────────
            YText {
                text: "高级选项"
                color: YColors.grayText
                font.pixelSize: 24
                anchors.left: parent.left
                anchors.leftMargin: 4
            }

            DescribedClickableTextBox {
                title: "温度"
                describe: fd.temperature !== undefined ? String(fd.temperature) : "0.7"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("temperature", "0.0 ~ 2.0")
            }

            DescribedClickableTextBox {
                title: "上下文窗口大小"
                describe: fd.maxContextSize > 0 ? String(fd.maxContextSize) + " tokens" : "未设置"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("maxContextSize", "输入模型最大上下文 Token 数，0 为未设置")
            }

            DescribedClickableTextBox {
                title: "自定义请求体参数"
                describe: (fd.extraParams && fd.extraParams !== "{}") ? fd.extraParams : "点击输入额外 JSON 参数"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("extraParams", "{ \"top_p\": 0.9 }")
            }

            // ─── 模型能力 ─────────────────────────────
            YText {
                text: "模型能力"
                color: YColors.grayText
                font.pixelSize: 24
                anchors.left: parent.left
                anchors.leftMargin: 4
            }

            DescribedSwitchItem {
                title: "文本"
                description: "支持文本输入与生成"
                switchOn: fd.capText
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("capText", !fd.capText)
            }

            DescribedSwitchItem {
                objectName: "ModelVision"
                title: "图像（Vision）"
                description: "支持图片输入"
                switchOn: fd.capVision
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("capVision", !fd.capVision)
            }

            DescribedSwitchItem {
                title: "音频"
                description: "支持音频输入"
                switchOn: fd.capAudio
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("capAudio", !fd.capAudio)
            }

            DescribedSwitchItem {
                title: "工具使用（Tool Call）"
                description: "支持函数调用"
                switchOn: fd.capToolCall
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("capToolCall", !fd.capToolCall)
            }

            DescribedSwitchItem {
                objectName: "ModelReasoning"
                title: "推理（Reasoning）"
                description: "支持思维链推理模式"
                switchOn: fd.capReasoning
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("capReasoning", !fd.capReasoning)
            }

            DescribedSwitchItem {
                objectName: "ModelImageGeneration"
                title: "图片生成"
                description: "使用 Responses API 图片生成工具"
                switchOn: fd.capImageGeneration
                enabled: fd.apiProtocol === "responses"
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("capImageGeneration", !fd.capImageGeneration)
            }

            DescribedSwitchItem {
                objectName: "ModelNativeWebSearch"
                title: "厂商联网搜索"
                description: "使用 Responses API 原生搜索工具"
                switchOn: fd.nativeWebSearchEnabled
                enabled: fd.apiProtocol === "responses"
                interval: 0
                toggleSwitchOnClick: false
                onTimerTriggered: setFormField("nativeWebSearchEnabled", !fd.nativeWebSearchEnabled)
            }

            DescribedClickableTextBox {
                objectName: "ModelWebSearchProvider"
                title: "联网搜索来源"
                describe: nativeWebSearchProviderLabel(fd.nativeWebSearchProvider)
                describeItem.color: YColors.grayText
                visible: fd.apiProtocol === "responses" && fd.nativeWebSearchEnabled
                opacityChangableWhenPressed: false
                onClicked: cycleNativeWebSearchProvider()
            }

            DescribedClickableTextBox {
                objectName: "ModelReasoningEffort"
                title: "思考强度"
                describe: reasoningEffortLabel(fd.reasoningEffort)
                describeItem.color: fd.reasoningEffort ? YColors.blueText : YColors.grayText
                visible: fd.capReasoning
                opacityChangableWhenPressed: false
                onClicked: cycleReasoningEffort()
            }

            // ─── 视觉代理设置（仅 Vision 关闭时显示）────
            YText {
                text: "视觉代理设置"
                color: YColors.grayText
                font.pixelSize: 24
                anchors.left: parent.left
                anchors.leftMargin: 4
                visible: !fd.capVision
            }

            DescribedClickableTextBox {
                title: "视觉代理模型"
                describe: getProxyModelName()
                describeItem.color: fd.proxyVisionModelId ? YColors.blueText : YColors.grayText
                visible: !fd.capVision
                opacityChangableWhenPressed: false
                onClicked: {
                    refreshVisionModels();
                    if (visionModelList.length === 0) {
                        showToast("暂无支持视觉的模型，请先添加", 2);
                        return;
                    }
                    proxySelectorOpen = true;
                }
            }

            DescribedClickableTextBox {
                title: "代理提示词"
                describe: fd.proxyVisionPrompt || "点击输入（默认：请详细描述图片内容）"
                describeItem.color: fd.proxyVisionPrompt ? YColors.blueText : YColors.grayText
                visible: !fd.capVision
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("proxyVisionPrompt", "请输入发给视觉模型的分析提示词")
            }

            PenModsSettingRow {
                title: isNew ? "添加模型" : "保存修改"
                onClicked: saveModel()
            }

            PenModsSettingRow {
                title: "删除模型"
                visible: !isNew
                onClicked: {
                    id_delete_dialog.tipItem.text = "确定删除模型「" + (modelData.name || modelData.id) + "」吗？此操作不可撤销。";
                    id_delete_dialog.show();
                }
            }
        }
    }

    // ─── 视觉代理模型选择器覆盖层 ─────────────────
    Rectangle {
        anchors.fill: parent
        color: "#AA000000"
        visible: proxySelectorOpen
        z: 1500

        MouseArea {
            anchors.fill: parent
            onClicked: proxySelectorOpen = false
        }

        Rectangle {
            objectName: "ModelProxySelector"
            width: Math.min(parent.width - 120, 640)
            height: Math.min(parent.height - 32, visionModelList.length * 76 + 88)
            color: YColors.grayNormal
            radius: 16
            anchors.centerIn: parent

            // Consume taps inside the dialog without dismissing it.
            MouseArea { anchors.fill: parent }

            YText {
                id: proxyTitle
                text: "选择视觉代理模型"
                color: YColors.white
                font.pixelSize: 26
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Flickable {
                anchors.top: proxyTitle.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 16
                contentHeight: id_proxy_model_col.height
                clip: true

                Column {
                    id: id_proxy_model_col
                    width: parent.width

                    Repeater {
                        model: visionModelList
                        PenModsSettingRow {
                            title: modelData.modelName
                            checked: modelData.modelId === fd.proxyVisionModelId
                            onClicked: {
                                setFormField("proxyVisionModelId", modelData.modelId);
                                proxySelectorOpen = false;
                            }
                        }
                    }
                }
            }
        }
    }

    YTwoButtonDialog {
        id: id_delete_dialog
        z: 1500
        anchors.fill: parent

        onClickedConfirm: {
            if (chatbot.removeModel(modelData.id)) {
                showToast("已删除: " + (modelData.name || modelData.id), 1);
                modelDeleted();
                close();
                backButtonClicked();
            } else {
                showToast("删除失败", 2);
                close();
            }
        }
        onClickedCancel: {
            close();
        }
    }

    YPagePopHelper {
        id: id_detail_pop
        z: 1000
        anchors.fill: parent
        objectName: "from_ModelDetailPage.qml"
        isShowing: keyBoard.inputPageShowing

        property string currentKey: ""
        property string currentPlaceholder: ""
        property string currentPrefill: ""

        function inputPageCreated(kbPage) {
            var key         = currentKey;
            var placeholder = currentPlaceholder;
            var prefill     = currentPrefill;

            kbPage.placeHolderText = placeholder;

            kbPage.backButtonClicked.connect(function() {
                keyBoard.inputPageShowing = false;
                kbPage.todoDestroy();
            });

            kbPage.inputFinished.connect(function(input) {
                keyBoard.inputPageShowing = false;
                kbPage.todoDestroy();
                if (input !== null) {
                    if (key === "temperature") {
                        var t = parseFloat(input);
                        setFormField(key, isNaN(t) ? "0.7" : String(Math.max(0, Math.min(2, t))));
                    } else if (key === "maxContextSize") {
                        var n = parseInt(input);
                        setFormField(key, (isNaN(n) || n < 0) ? 0 : n);
                    } else if (key === "extraParams") {
                        if (input.trim() !== "") {
                            try {
                                JSON.parse(input);
                                setFormField(key, input);
                            } catch(e) {
                                showToast("额外参数不是合法 JSON，已清空", 2);
                                setFormField(key, "");
                            }
                        } else {
                            setFormField(key, "");
                        }
                    } else {
                        setFormField(key, input);
                    }
                }
            });

            kbPage.enterText(prefill);
            kbPage.show();
            keyBoard.inputPageShowing = true;
        }
    }
}
