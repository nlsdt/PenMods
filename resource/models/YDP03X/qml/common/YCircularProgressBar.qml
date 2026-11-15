import QtQuick 2.12

Item {
    id: root

    property int size: 36
    property int lineWidth: 4
    property int progressValue: 0
    property int mediaIdValue: 0

    property color primaryColor: YColors.red
    property color secondaryColor: "#2D2E33"
    property string lineCap: "square"

    width: size
    height: size

    onProgressValueChanged: {
        canvas.degree = progressValue/100.0 * 360;
    }

    Canvas {
        id: canvas

        property real degree: 0

        anchors.fill: parent
        antialiasing: true

        onDegreeChanged: {
            requestPaint();
        }

        onPaint: {
            var ctx = getContext("2d");

            var x = root.width/2;
            var y = root.height/2;

            var radius = root.size/2 - root.lineWidth
            var startAngle = (Math.PI/180) * 270;
            var fullAngle = (Math.PI/180) * (270 + 360);
            var progressAngle = (Math.PI/180) * (270 + degree);

            ctx.reset()

            ctx.lineCap = lineCap;
            ctx.lineWidth = root.lineWidth;

            ctx.beginPath();
            ctx.arc(x, y, radius, startAngle, fullAngle);
            ctx.strokeStyle = root.secondaryColor;
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(x, y, radius, startAngle, progressAngle);
            ctx.strokeStyle = root.primaryColor;
            ctx.stroke();
        }
    }
}
