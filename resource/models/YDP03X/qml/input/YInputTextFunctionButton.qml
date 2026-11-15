import QtQuick 2.12

import "../common"

YPressedBaseButton {
    property alias imageName: id_icon.imageName
    YImage {
        id: id_icon
        anchors.centerIn: parent
        sourceSize: Qt.size(60, 60)
    }
}
