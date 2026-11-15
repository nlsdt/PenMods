import QtQuick 2.12
import com.youdao.pen 1.0
import com.github.penuniverse 1.0

import BaseQml 1.0
import "./common"
import "./components"
import "./i18n"

// =====================================================================
// 录音机 —— 绑定 3 代 `audioRecorder`（start/stop/state/fileName/setFileName）。
// 仅在 C++ 侧未注册该上下文属性时，演示模式显示「需要 C++ 支持」。
// 说明：3 代 stop() 返回 bool，错误/成功 toast 由 C++ 内部弹出，QML 不再
// switch 返回码；录音期间压制系统声音的 Hook 为 YDP02X 专属（YDP03X 无）。
// =====================================================================
YBackButtonPage {
    id: id_audio_recorder

    objectName: "YPage===AudioRecorder.qml"
    property bool locked: false
    property int currentSeconds: 0

    function recorderReady() {
        return typeof audioRecorder !== "undefined" && audioRecorder !== null;
    }

    function start() {
        if (locked || !recorderReady()) return;
        locked = true;
        currentSeconds = 0;
        audioRecorder.start();
        locked = false;
    }

    function stop() {
        if (locked || !recorderReady()) return;
        locked = true;
        audioRecorder.stop(); // C++ 内部已弹出成功 / 错误 toast
        locked = false;
    }

    function ts2str(ts) {
        let s = ts % 60; ts -= s;
        let m = (ts / 60) % 60; ts -= m * 60;
        let h = ts / 3600;
        if (s < 10) s = "0" + s;
        if (m < 10) m = "0" + m;
        if (h < 10) h = "0" + h;
        return h + ":" + m + ":" + s;
    }

    function requestKeyboard() {
        let component = qmlCreateComponent("input/YInputPage");
        if (Component.Ready === component.status) {
            var incubator = component.incubateObject(id_page_pop_helper.containerItem);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function (status) {
                    if (status === Component.Ready) {
                        id_page_pop_helper.inputPageCreated(incubator.object);
                    }
                };
            } else {
                id_page_pop_helper.inputPageCreated(incubator.object);
            }
        }
    }

    Component.onCompleted: {
        if (recorderReady())
            id_column_main.update();
    }

    // 返回时停止录音；不覆盖 YPage 默认关闭行为，故用 Connections 追加。
    Connections {
        target: id_audio_recorder
        function onBackButtonClicked() {
            stop();
        }
    }

    Flickable {
        id: id_item_container

        anchors.fill: parent
        anchors.leftMargin: 54
        anchors.rightMargin: 10
        contentHeight: id_title_container.height + id_column_main.height

        YSettingItemTitle {
            id: id_title_container
            title: "录音机"
        }

        Column {
            id: id_column_main

            function update() {
                if (!id_audio_recorder.recorderReady()) {
                    id_state.title = "需要 C++ 支持";
                    id_state.value = '';
                    id_state.source = '';
                    return;
                }
                switch (audioRecorder.state) {
                case AudioRecorder.ActiveState:
                    id_state.title = '正在录音';
                    id_state.value = '00:00:00';
                    id_state.source = '';
                    break;
                case AudioRecorder.SuspendedState:
                    id_state.title = '暂停';
                    id_state.value = '';
                    id_state.source = 'audioplayer/play';
                    break;
                default: // Idle / Stopped / Interrupted
                    id_state.title = '就绪';
                    id_state.value = '';
                    id_state.source = 'audioplayer/mic';
                    break;
                }
            }

            anchors.top: id_title_container.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            YSettingAboutClickableItem {
                id: id_state

                opacityChangableWhenPressed: false
                sourceSize: Qt.size(24, 24)
                onClicked: {
                    if (!id_audio_recorder.recorderReady()) return;
                    switch (audioRecorder.state) {
                    case AudioRecorder.ActiveState:
                        id_audio_recorder.stop();
                        break;
                    case AudioRecorder.SuspendedState:
                        break;
                    default:
                        id_audio_recorder.start();
                        break;
                    }
                }
            }

            YSettingAboutClickableItem {
                title: (id_audio_recorder.recorderReady() && audioRecorder.state == AudioRecorder.ActiveState)
                       ? "修改文件名" : "文件名"
                enabled: id_audio_recorder.recorderReady()
                         && audioRecorder.state == AudioRecorder.ActiveState
                value: id_audio_recorder.recorderReady() ? audioRecorder.fileName : ""
                imageName: "settings/info_more_arrow"
                onClicked: id_audio_recorder.requestKeyboard()
            }

            YSpacingForColumn {
                implicitHeight: 4
            }
        }
    }

    Connections {
        target: id_audio_recorder.recorderReady() ? audioRecorder : null
        function onStateChanged() {
            if (!id_audio_recorder.recorderReady()) return;
            id_column_main.update();
            if (audioRecorder.state !== AudioRecorder.ActiveState)
                currentSeconds = 0;
        }
        function onNotify() {
            if (!id_audio_recorder.recorderReady()) return;
            currentSeconds += 1;
            id_state.value = id_audio_recorder.ts2str(currentSeconds);
        }
    }

    // 左侧录音控制按钮（底部一排）
    Item {
        id: id_sidebar
        anchors.fill: parent
        anchors.topMargin: 80
        visible: !YInputProperty.inputPageShowing

        Column {
            id: id_column_sidebar
            anchors.left: parent.left
            anchors.leftMargin: 10
            spacing: 10

            YIconButton {
                id: id_start_record
                width: 44
                height: 44
                radius: 10
                enabled: id_audio_recorder.recorderReady()
                         && audioRecorder.state != AudioRecorder.ActiveState
                source: "audioplayer/mic"
                sourceSize: Qt.size(22, 22)
                onValidClicked: id_audio_recorder.start()
            }

            YIconButton {
                id: id_play_record
                width: 44
                height: 44
                radius: 10
                enabled: id_audio_recorder.recorderReady()
                         && audioRecorder.state != AudioRecorder.ActiveState
                source: "audioplayer/play"
                sourceSize: Qt.size(22, 22)
                onValidClicked: {
                    // 回放录音：2 代亦未实现，保留占位。
                }
            }

            YIconButton {
                id: id_stop_record
                width: 44
                height: 44
                radius: 10
                enabled: id_audio_recorder.recorderReady()
                         && audioRecorder.state == AudioRecorder.ActiveState
                source: "textbook/select-check"
                sourceSize: Qt.size(22, 22)
                onValidClicked: id_audio_recorder.stop()
            }
        }
    }

    YPagePopHelper {
        id: id_page_pop_helper

        function inputPageCreated(keyboardPage) {
            keyboardPage.backButtonClicked.connect(function () {
                YInputProperty.inputPageShowing = false;
                keyboardPage.todoDestroy();
                keyboardPage = null;
            });
            keyboardPage.inputFinished.connect(function (content) {
                if (!id_audio_recorder.recorderReady()) return;
                let ret = audioRecorder.setFileName(content);
                if (ret === AudioRecorder.SetPathResult.Ok) {
                    baseSignals.showToast('文件名已修改');
                } else if (ret === AudioRecorder.SetPathResult.IllegalSymbolDetected) {
                    baseSignals.showToast('文件名不能包含特殊字符', YColors.yellow);
                }
            });
            keyboardPage.initialText = id_audio_recorder.recorderReady() ? audioRecorder.fileName : "";
            keyboardPage.show();
            YInputProperty.inputPageShowing = true;
        }

        isShowing: YInputProperty.inputPageShowing
        objectName: "from_AudioRecorder.qml"
    }
}
