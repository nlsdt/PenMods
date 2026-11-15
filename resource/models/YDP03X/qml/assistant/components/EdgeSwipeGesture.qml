import BaseQml 1.0
import com.youdao.pen 1.0
import QtQuick 2.12

// 侧边滑动手势检测。
Item {
    id: root

    property string edge: "left" // "left" | "right"
    property real edgeWidth: 40
    property real threshold: Math.max(6, Math.min(Math.round(edgeWidth * 0.8), 24))
    property bool gestureEnabled: true
    property color indicatorColor: "#2B5278"
    property real verticalTolerance: 1.5

    readonly property bool isLeft: edge === "left"

    signal triggered()        // 向内（朝屏幕中心）滑动：打开/收起面板
    signal triggeredOutward() // 向外（朝边框）滑动：收起面板

    width: edgeWidth

    property real _startX: 0
    property real _startY: 0
    property real _maxInward: 0
    property real _maxOutward: 0
    property bool _isDragging: false

    function _inward(x) {
        return isLeft ? (x - _startX) : (_startX - x);
    }

    function _outward(x) {
        return isLeft ? (_startX - x) : (x - _startX);
    }

    function _reset() {
        _isDragging = false;
        _maxInward = 0;
        _maxOutward = 0;
        indicator.width = 0;
    }

    MouseArea {
        id: gestureArea
        anchors.fill: parent
        z: 50
        // 防止拖动被祖先 Flickable 抢走。
        preventStealing: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (!root.gestureEnabled) {
                root._reset();
                return;
            }
            root._startX = mouseX;
            root._startY = mouseY;
            root._maxInward = 0;
            root._maxOutward = 0;
            root._isDragging = true;
        }

        onPositionChanged: {
            if (!root._isDragging || !root.gestureEnabled)
                return;
            var inward = root._inward(mouseX);
            var outward = root._outward(mouseX);
            if (inward > root._maxInward)
                root._maxInward = inward;
            if (outward > root._maxOutward)
                root._maxOutward = outward;
            var shown = Math.max(root._maxInward, root._maxOutward);
            indicator.width = Math.max(0, Math.min(shown, root.threshold));
        }

        onReleased: {
            if (!root._isDragging || !root.gestureEnabled) {
                root._reset();
                return;
            }
            root._isDragging = false;
            var dx = Math.abs(mouseX - root._startX);
            var dy = Math.abs(mouseY - root._startY);
            var directional = dx >= root.verticalTolerance * dy;
            if (directional && root._maxInward >= root.threshold)
                root.triggered();
            else if (directional && root._maxOutward >= root.threshold)
                root.triggeredOutward();
            root._reset();
        }

        onCanceled: root._reset()
    }

    // 滑动指示条，不做动画。
    Rectangle {
        id: indicator
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: root.isLeft ? 0 : (parent.width - width)
        width: 0
        color: root.indicatorColor
        opacity: width > 0 ? 0.85 : 0
        z: 60
    }
}
