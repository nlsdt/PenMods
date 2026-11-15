import QtQuick 2.12
import QtQuick.Shapes 1.12

Item {
    id: id_dash_line
    implicitWidth: 84
    implicitHeight: 42
    smooth: true
    antialiasing: true

    readonly property bool lengthHorizontalLongerThanVertical: width >= height
    readonly property int radius: Math.min(width, height) / 2

    readonly property alias shapeItem: id_shape
    readonly property alias shapePathItem: id_shape_path

    property bool isDashLine: true

    Shape {
        id: id_shape
        anchors.fill: parent
        asynchronous: true
        ShapePath {
            id: id_shape_path
            fillColor: "transparent"
            strokeColor: "#FF5847"
            strokeStyle: isDashLine ? ShapePath.DashLine : ShapePath.SolidLine
            strokeWidth: 2
            dashPattern: [1, 3]
            startX: lengthHorizontalLongerThanVertical ? radius : 0
            startY: lengthHorizontalLongerThanVertical ? 0 : radius
            PathArc {
                x: lengthHorizontalLongerThanVertical ? radius : id_dash_line.width
                y: lengthHorizontalLongerThanVertical ? id_dash_line.height : radius
                radiusX: radius
                radiusY: radius
                direction: lengthHorizontalLongerThanVertical ? PathArc.Counterclockwise : PathArc.Clockwise
            }
            PathLine {
                x: lengthHorizontalLongerThanVertical ? id_dash_line.width - radius : id_dash_line.width
                y: lengthHorizontalLongerThanVertical ? id_dash_line.height : id_dash_line.height - radius
            }
            PathArc {
                x: lengthHorizontalLongerThanVertical ? id_dash_line.width - radius : 0
                y: lengthHorizontalLongerThanVertical ? 0 : id_dash_line.height - radius
                radiusX: radius
                radiusY: radius
                direction: lengthHorizontalLongerThanVertical ? PathArc.Counterclockwise : PathArc.Clockwise
            }
            PathLine {
                x: lengthHorizontalLongerThanVertical ? radius : 0
                y: lengthHorizontalLongerThanVertical ? 0 : radius
            }
        }
    }
}
