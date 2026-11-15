import QtQuick 2.12
import com.youdao.pen 1.0
import "../common"

Item {
    id: host
    property var acceptText: null
    property var acceptConfirmation: null
    property string confirmation: ""
    property url inputSource: Qt.resolvedUrl("../input/YInputPage.qml")
    readonly property alias inputItem: inputLoader.item
    readonly property alias pageItem: pageLoader.item
    readonly property alias confirmationItem: confirmationDialog
    signal operationFailed(string message)

    function openPage(name, properties) {
        var options = properties || {};
        options.destroyOnBack = false;
        pageLoader.setSource(Qt.resolvedUrl(name + ".qml"), options);
    }
    function editText(prompt, initial, accepted, secret, allowEmpty) {
        cancelInput();
        acceptText = accepted;
        inputLoader.setSource(inputSource, {
            "destroyOnBack": false, "closeOnAccept": false,
            "initialText": initial || "", "placeHolderText": prompt,
            "secret": !!secret, "allowEmpty": !!allowEmpty
        });
    }
    function cancelInput() {
        acceptText = null;
        if (inputLoader.item) inputLoader.item.visible = false;
        inputLoader.source = "";
    }
    function editAntiEmbsUnlock() {
        editText("请输入文本", "", function(text) {
            if (!antiEmbs.deactivate(text)) {
                // Close the keyboard before entering the normal dictionary flow.
                Qt.callLater(function() {
                    var result = resultManager.entryResult(text, "", "", YEnum.PageIndex.Dict, 1, false);
                    qmlGlobal.showDictPage(YEnum.PageIndex.Dict);
                    if (!result) baseSignals.showToast("查询失败，请重试", "#2D2E33");
                });
            }
        }, false);
    }
    function confirmAction(message, accepted) {
        acceptConfirmation = accepted;
        confirmation = message;
        confirmationDialog.show();
    }
    function closeConfirmation(accepted) {
        var callback = acceptConfirmation;
        acceptConfirmation = null;
        confirmation = "";
        confirmationDialog.close();
        if (accepted && callback) callback();
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        onLoaded: {
            item.backButtonClicked.connect(function() { pageLoader.source = ""; });
            item.show();
        }
        onStatusChanged: {
            if (status === Loader.Error) {
                host.operationFailed("无法打开设置页面");
                source = "";
            }
        }
    }
    Loader {
        id: inputLoader
        anchors.fill: parent
        z: 1
        onLoaded: {
            item.backButtonClicked.connect(function() {
                host.cancelInput();
            });
            item.inputFinished.connect(function(text) {
                if (!host.acceptText || host.acceptText(text) !== false) {
                    host.cancelInput();
                }
            });
            item.show();
        }
        onStatusChanged: {
            if (status === Loader.Error) {
                host.acceptText = null;
                host.operationFailed("无法打开输入键盘");
                source = "";
            }
        }
    }
    YTwoButtonDialog {
        id: confirmationDialog
        anchors.fill: parent
        z: 2
        tipItem.text: host.confirmation
        onClickedConfirm: host.closeConfirmation(true)
        onClickedCancel: host.closeConfirmation(false)
        onClosed: host.closeConfirmation(false)
    }
    Connections {
        target: systemBase
        enabled: confirmationDialog.isShowing
        function onHomeKeyRelease() { host.closeConfirmation(false); }
    }
}
