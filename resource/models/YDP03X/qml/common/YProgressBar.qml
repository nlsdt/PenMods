import QtQuick 2.12
import QtGraphicalEffects 1.14

import "../common"

Item {
    id: id_progress_bg
    clip: true

    // must be set properties
    property int progress: 0

    // other properties
    property alias radius: id_progress_bg_rect.radius
    property alias color: id_progress_bg_rect.color

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

    // 进度条置零
    function emptyProgress() {
        id_progress_fg.anchors.rightMargin = id_add_content.width + 10
    }

    // 进度条置满
    function fullProgress() {
        id_progress_fg.anchors.rightMargin = 0
    }


    Item {
        id: id_add_content
        anchors.fill: parent
        visible: false
        Rectangle {
            id: id_progress_bg_rect
            anchors.fill: parent
            radius: height/2
        }

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


    Rectangle {
        id: id_opacity_mask_bg
        anchors.fill: parent
        radius: id_progress_bg_rect.radius
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: id_add_content
        maskSource: id_opacity_mask_bg
    }

    YTextMedium {
        id: id_button_label
        font.pixelSize: 18
        anchors.centerIn: parent
    }

    Component.onCompleted: {
        id_add_content.updateProgress()
    }
}
