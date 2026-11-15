import QtQuick 2.12
import BaseQml 1.0

Row {
    id: indicator
    property int power: 0
    property bool charging: false
    readonly property real fraction: Math.max(0, Math.min(100, power)) / 100
    readonly property color batteryColor: charging ? YColors.green : power <= 20 ? YColors.red : YColors.white
    spacing: 8
    height: 22

    Item {
        width: 30
        height: parent.height
        Rectangle {
            id: body
            width: 26
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            radius: 3
            color: "transparent"
            border.width: 1.5
            border.color: indicator.batteryColor
            Rectangle {
                x: 3
                y: 3
                width: (parent.width - 6) * indicator.fraction
                height: parent.height - 6
                radius: 1
                color: indicator.batteryColor
            }
            Canvas {
                anchors.centerIn: parent
                width: 10
                height: 12
                visible: indicator.charging
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.fillStyle = "#1A1B1F";
                    ctx.beginPath();
                    ctx.moveTo(6, 0); ctx.lineTo(1, 7); ctx.lineTo(4, 7);
                    ctx.lineTo(3, 12); ctx.lineTo(9, 5); ctx.lineTo(6, 5);
                    ctx.closePath(); ctx.fill();
                }
            }
        }
        Rectangle {
            anchors.left: body.right
            anchors.leftMargin: 1
            anchors.verticalCenter: body.verticalCenter
            width: 3
            height: 6
            radius: 1
            color: indicator.batteryColor
        }
    }
    YText {
        anchors.verticalCenter: parent.verticalCenter
        text: Math.max(0, Math.min(100, indicator.power)) + "%"
        font.pixelSize: 16
        color: YColors.white
    }
}
