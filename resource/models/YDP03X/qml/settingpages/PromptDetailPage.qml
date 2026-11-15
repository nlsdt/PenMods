import QtQuick 2.12
import BaseQml 1.0

import "../common"
import "../components"
import "../i18n"
import "../settingpages"

YBackButtonPage {
    id: id_detail_page
    objectName: "YPage===PromptDetailPage.qml"

    property var promptData: ({})
    readonly property bool isNew: !promptData || !promptData.id

    signal promptSaved()
    signal promptDeleted()

    property var fd: ({})

    function initFormData() {
        fd = {
            "name":    promptData.name    || "",
            "content": promptData.content || ""
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

    function savePrompt() {
        if (!fd.name) {
            showToast("名称不能为空", 2);
            return;
        }

        var promptId = isNew ? generateId(fd.name) : promptData.id;

        var promptObj = {
            "id":      promptId,
            "name":    fd.name,
            "content": fd.content || ""
        };

        var success = chatbot.addPrompt(JSON.stringify(promptObj));
        if (success) {
            showToast(isNew ? "提示词已添加" : "提示词已更新", 1);
            promptSaved();
            backButtonClicked();
        } else {
            showToast("保存失败", 2);
        }
    }

    function generateId(name) {
        return name.toLowerCase().replace(/[^a-z0-9]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "") || "prompt";
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

    Component.onCompleted: { initFormData(); }

    onPromptDataChanged: { initFormData(); }

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
                title: isNew ? "添加提示词" : "编辑提示词"
            }

            DescribedClickableTextBox {
                title: "名称"
                describe: fd.name || "点击输入人格显示名称"
                describeItem.color: YColors.grayText
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("name", "请输入提示词名称")
            }

            DescribedClickableTextBox {
                title: "内容"
                describe: fd.content
                          ? fd.content.substring(0, 40) + (fd.content.length > 40 ? "…" : "")
                          : "点击编辑系统提示词内容"
                opacityChangableWhenPressed: false
                onClicked: openKeyboard("content", "请输入提示词内容")
            }

            YSettingAboutClickableItem {
                titlePixelSize: 28
                valuePixelSize: 26
                title: isNew ? "添加提示词" : "保存修改"
                onClicked: savePrompt()
            }

            YSettingAboutClickableItem {
                titlePixelSize: 28
                valuePixelSize: 26
                title: "删除提示词"
                visible: !isNew
                onClicked: {
                    id_delete_dialog.tipItem.text = "确定删除提示词「" + (promptData.name || promptData.id) + "」吗？";
                    id_delete_dialog.show();
                }
            }
        }
    }

    YTwoButtonDialog {
        id: id_delete_dialog
        z: 1500
        anchors.fill: parent

        onClickedConfirm: {
            if (chatbot.removePrompt(promptData.id)) {
                promptDeleted();
                close();
                backButtonClicked();
            } else {
                showToast("删除失败", 2);
                close();
            }
        }
        onClickedCancel: { close(); }
    }

    YPagePopHelper {
        id: id_detail_pop
        z: 1000
        anchors.fill: parent
        objectName: "from_PromptDetailPage.qml"
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
                    fd[key] = input;
                    fd = fd;
                }
            });

            kbPage.enterText(prefill);
            kbPage.show();
            keyBoard.inputPageShowing = true;
        }
    }
}
