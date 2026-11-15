import QtQuick 2.12
import QtGraphicalEffects 1.12

Rectangle {
    id: root

    property var fontFamily: fontManager.fontFamily

    width: Math.min(parent.width - 32, Math.max(280, toastContent.implicitWidth + 48))
    height: toastContent.implicitHeight + 24
    radius: 6
    color: internal.backgroundColor
    border.width: 1
    border.color: internal.borderColor
    anchors.horizontalCenter: parent.horizontalCenter
    y: visible ? 20 : -height - 20
    z: 2000
    opacity: 0
    visible: opacity > 0

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 25
        color: "#20000000"
    }

    QtObject {
        id: internal
        property string message: ""
        property string type: "error"

        property color backgroundColor: {
            switch (type) {
            case "success": return "#d1e7dd";
            case "warning": return "#fff3cd";
            case "info":    return "#cff4fc";
            case "error":
            default:        return "#f8d7da";
            }
        }

        property color borderColor: {
            switch (type) {
            case "success": return "#badbcc";
            case "warning": return "#ffecb5";
            case "info":    return "#b6effb";
            case "error":
            default:        return "#f5c2c7";
            }
        }

        property color iconColor: {
            switch (type) {
            case "success": return "#0f5132";
            case "warning": return "#664d03";
            case "info":    return "#055160";
            case "error":
            default:        return "#842029";
            }
        }

        property color textColor: {
            switch (type) {
            case "success": return "#0f5132";
            case "warning": return "#664d03";
            case "info":    return "#055160";
            case "error":
            default:        return "#842029";
            }
        }
    }

    Behavior on y {
        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    Row {
        id: toastContent
        anchors.centerIn: parent
        spacing: 12

        Canvas {
            id: iconCanvas
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.lineWidth = 2;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.strokeStyle = internal.iconColor;
                ctx.fillStyle = internal.iconColor;

                var cx = width / 2;
                var cy = height / 2;
                var r = 8;

                switch (internal.type) {
                case "success": drawSuccessIcon(ctx, cx, cy, r); break;
                case "warning": drawWarningIcon(ctx, cx, cy); break;
                case "info":    drawInfoIcon(ctx, cx, cy, r); break;
                case "error":
                default:        drawErrorIcon(ctx, cx, cy, r); break;
                }
            }

            function drawCircle(ctx, cx, cy, r) {
                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                ctx.stroke();
            }

            function drawSuccessIcon(ctx, cx, cy, r) {
                drawCircle(ctx, cx, cy, r);
                ctx.beginPath();
                ctx.moveTo(cx - 4, cy);
                ctx.lineTo(cx - 1, cy + 3);
                ctx.lineTo(cx + 4, cy - 3);
                ctx.stroke();
            }

            function drawWarningIcon(ctx, cx, cy) {
                ctx.beginPath();
                ctx.moveTo(cx, 2);
                ctx.lineTo(width - 2, height - 2);
                ctx.lineTo(2, height - 2);
                ctx.closePath();
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(cx, 7);
                ctx.lineTo(cx, 12);
                ctx.stroke();

                ctx.beginPath();
                ctx.arc(cx, 15, 1.2, 0, 2 * Math.PI);
                ctx.fill();
            }

            function drawInfoIcon(ctx, cx, cy, r) {
                drawCircle(ctx, cx, cy, r);
                ctx.beginPath();
                ctx.arc(cx, cy - 3, 1.2, 0, 2 * Math.PI);
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.lineTo(cx, cy + 5);
                ctx.stroke();
            }

            function drawErrorIcon(ctx, cx, cy, r) {
                drawCircle(ctx, cx, cy, r);
                var offset = 3.5;
                ctx.beginPath();
                ctx.moveTo(cx - offset, cy - offset);
                ctx.lineTo(cx + offset, cy + offset);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(cx + offset, cy - offset);
                ctx.lineTo(cx - offset, cy + offset);
                ctx.stroke();
            }
        }

        Text {
            id: toastText
            text: internal.message
            color: internal.textColor
            font.pixelSize: 14
            font.family: root.fontFamily || fontManager.fontFamily
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.Wrap
            maximumLineCount: internal.type === "error" ? 6 : 3
            width: Math.min(implicitWidth, root.parent.width - 120)
        }

        Rectangle {
            width: 20
            height: 20
            radius: 4
            color: closeMouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.1) : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Canvas {
                anchors.centerIn: parent
                width: 12
                height: 12
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = internal.textColor;
                    ctx.lineWidth = 1.5;
                    ctx.lineCap = "round";
                    ctx.beginPath(); ctx.moveTo(2, 2); ctx.lineTo(10, 10); ctx.stroke();
                    ctx.beginPath(); ctx.moveTo(10, 2); ctx.lineTo(2, 10); ctx.stroke();
                }
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.hide()
            }
        }
    }

    Rectangle {
        id: progressBar
        height: 3
        radius: 1.5
        color: internal.iconColor
        opacity: 0.6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 8
        width: parent.width - 16

        Rectangle {
            id: progressIndicator
            height: parent.height
            radius: parent.radius
            color: parent.color
            anchors.left: parent.left
            width: parent.width
            property bool animateEnabled: false

            Behavior on width {
                enabled: progressIndicator.animateEnabled
                NumberAnimation { duration: toastTimer.interval; easing.type: Easing.Linear }
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 3000
        onTriggered: root.hide()
    }

    function show(msg, type, duration) {
        internal.message = msg;
        internal.type = type || "error";
        toastTimer.interval = duration || 3000;
        iconCanvas.requestPaint();
        progressIndicator.animateEnabled = false;
        progressIndicator.width = progressBar.width;
        opacity = 1;
        progressIndicator.animateEnabled = true;
        progressIndicator.width = 0;
        toastTimer.restart();
    }

    function hide() {
        opacity = 0;
        toastTimer.stop();
    }

    function success(msg, duration) { show(msg, "success", duration); }
    function error(msg, duration)   { show(msg, "error", duration); }
    function warning(msg, duration) { show(msg, "warning", duration); }
    function info(msg, duration)    { show(msg, "info", duration); }
}
