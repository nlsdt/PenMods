import QtQuick 2.12
import "MathCache.js" as MathCache

// 单个数学公式渲染气泡，调用本地 MathJax 服务（127.0.0.1:3000）
Item {
    id: root

    property string latex: ""
    property bool display: true          // true=块级，false=行内
    property bool serverAvailable: false
    property real maxWidth: 300
    property var fontFamily: fontManager.fontFamily

    property int _state: MathCache.IDLE
    property string _svgData: ""
    property string _pendingUri: ""

    signal layoutAboutToChange

    Timer {
        id: commitTimer
        interval: 150
        repeat: false
        onTriggered: {
            root.layoutAboutToChange();
            root._svgData = root._pendingUri;
            root._pendingUri = "";
            root._state = MathCache.DONE;
        }
    }

    implicitWidth: {
        if (_state === MathCache.DONE)
            return Math.min(svgImage.implicitWidth + 8, maxWidth);
        if (_state === MathCache.ERROR || !serverAvailable)
            return root.display ? maxWidth : Math.min(fallbackText.implicitWidth + 16, maxWidth);
        return 60;
    }
    implicitHeight: {
        if (_state === MathCache.DONE)
            return Math.max(svgImage.implicitHeight + 8, 32);
        if (_state === MathCache.ERROR || !serverAvailable)
            return fallbackText.implicitHeight + 12;
        return 28;
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    onLatexChanged: _reset()
    onServerAvailableChanged: {
        if (serverAvailable && _state === MathCache.IDLE && latex !== "")
            _fetchSvg();
    }
    Component.onCompleted: _reset()

    function _reset() {
        commitTimer.stop();
        root._pendingUri = "";
        root._state = MathCache.IDLE;
        root._svgData = "";
        if (root.latex !== "" && root.serverAvailable)
            _fetchSvg();
    }

    function _fetchSvg() {
        root._state = MathCache.LOADING;
        MathCache.enqueueRequest(root.latex, root.display, function (result) {
            if (root == null || root._state !== MathCache.LOADING)
                return;
            if (result.success) {
                root._pendingUri = result.dataUri;
                commitTimer.restart();
            } else {
                root.layoutAboutToChange();
                root._svgData = "";
                root._state = MathCache.ERROR;
            }
        });
    }

    Text {
        id: fallbackText
        visible: root._state === MathCache.ERROR || (!root.serverAvailable && root._state !== MathCache.LOADING)
        text: root.display ? ("$$" + root.latex + "$$") : ("$" + root.latex + "$")
        color: "#A0B8D0"
        font.pixelSize: 13
        font.family: root.fontFamily || fontManager.fontFamily
        wrapMode: Text.Wrap
        // 块级公式宽度占满行、左对齐；行内公式使用自然宽度以避免在大 width 下溢出父容器
        width: root.display ? (root.maxWidth - 16) : implicitWidth
        anchors.left: root.display ? parent.left : undefined
        anchors.leftMargin: root.display ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: root.display ? undefined : parent.horizontalCenter
    }

    Row {
        visible: root._state === MathCache.LOADING
        anchors.centerIn: parent
        spacing: 4
        Repeater {
            model: 3
            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: "#62A8EA"
                SequentialAnimation on opacity {
                    running: root._state === MathCache.LOADING
                    loops: Animation.Infinite
                    PauseAnimation {
                        duration: index * 160
                    }
                    NumberAnimation {
                        from: 0.3
                        to: 1.0
                        duration: 260
                    }
                    NumberAnimation {
                        from: 1.0
                        to: 0.3
                        duration: 260
                    }
                    PauseAnimation {
                        duration: (2 - index) * 160
                    }
                }
            }
        }
    }

    Image {
        id: svgImage
        visible: root._state === MathCache.DONE
        anchors.centerIn: parent
        source: root._state === MathCache.DONE ? root._svgData : ""
        fillMode: Image.PreserveAspectFit
        width: root.maxWidth - 8
        smooth: true
        mipmap: true
    }
}
