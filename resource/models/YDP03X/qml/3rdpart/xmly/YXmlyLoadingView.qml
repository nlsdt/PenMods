import QtQuick 2.0
import BaseQml 1.0

Item {
    id: loading_view
    property string text: ""
    property bool loading: true
    property bool retryEnable: false
    // 避免与页面左侧导航栏事件冲突
    property int mouseLeftMargin: 80

    signal retryClicked()

    // 当有错误信息时，停止loading
    onTextChanged: {
        if (text !== "") {
            loading = false
        }
    }

    // 当loading时清空错误信息
    onLoadingChanged: {
        if (loading) {
            text = ""
        }
    }

    YText {
        id: loading_text
        anchors.centerIn: parent
        color: YColors.white
        text: loading ? qsTr("loading...") : loading_view.text
    }

    YMouseArea {
        anchors.fill: parent
        anchors.leftMargin: mouseLeftMargin
        visible: retryEnable
        onClicked: {
            if (loading) {
                return
            }
            loading = true
            // 延迟500ms执行，确保有loading显示的过程
            timer.setTimeout(function() {
                retryClicked()
            }, 500)
        }
    }

    // https://cloud.tencent.com/developer/ask/217737
    Timer {
        id: timer
        function setTimeout(cb, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.triggered.connect(function release () {
                timer.triggered.disconnect(cb); // This is important
                timer.triggered.disconnect(release); // This is important as well
            });
            timer.start();
        }
    }

}
