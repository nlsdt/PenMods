import QtQuick 2.12
import BaseQml 1.0

YBlurMaskRectangle {
    id: id_progress_bg

    // must be set properties
    property int progress: 0

    // other properties
    property alias progressColor: id_progress_fg.color
    property alias progressGradient: id_progress_fg.gradient

    property alias text: id_button_label.text
    readonly property alias textItem: id_button_label
    property alias textPixelSize: id_button_label.font.pixelSize

    // readonly properties
    readonly property real step: width / 100.0

    onProgressChanged: {
        id_add_content.updateProgress()
    }

    Item {
        id: id_add_content
        anchors.fill: parent

        Rectangle {
            id: id_progress_fg
            implicitWidth: id_progress_bg.width
            implicitHeight: id_progress_bg.height
            anchors.right: parent.right
            anchors.rightMargin: id_add_content.width
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6F6CFF" }
                GradientStop { position: 1.0; color: "#644FEC" }
            }
            radius: id_progress_bg.radius
        }

        YTextMedium {
            id: id_button_label
            font.pixelSize: 18
            anchors.centerIn: parent
        }

        function updateProgress() {
            if (0 === progress) {
                id_progress_fg.anchors.rightMargin
                        = id_add_content.width + 10
            } else if (100 === progress) {
                id_progress_fg.anchors.rightMargin = 0
            } else {
                id_progress_fg.anchors.rightMargin
                        = id_add_content.width - step * progress
            }
        }
    }

    Component.onCompleted: {
        id_add_content.updateProgress()
    }
}
