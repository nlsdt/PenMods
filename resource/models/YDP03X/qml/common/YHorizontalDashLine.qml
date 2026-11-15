import QtQuick 2.12
import QtQuick.Shapes 1.14

YSpacingForColumn {
    id: id_horizontal_dash_line
    Shape {
        anchors.fill: parent
        ShapePath {
            strokeColor: "#28FFFFFF"
            strokeStyle: ShapePath.DashLine
            dashPattern: [
                id_horizontal_dash_line.height - 1,
                id_horizontal_dash_line.height + 1
            ]
            startX: 0
            startY: 0
            PathLine { x: id_horizontal_dash_line.width; y: 0 }
        }
    }
}
