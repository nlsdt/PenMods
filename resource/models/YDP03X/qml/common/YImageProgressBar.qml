import QtQuick 2.12

YImage {
    id: id_image_progress_bar
    sourceSize: Qt.size(800, 2)
    imageName: "audioplayer/progress_bar_bg"

    property int progress: 0

    property alias frontgroundImageName: id_image_progress_bar_front.imageName

    onProgressChanged: {
        id_progress_rect.positionProgress()
    }

    Item {
        id: id_progress_rect
        anchors.fill: parent
        anchors.rightMargin: id_image_progress_bar.width
        clip: true

        readonly property real step: id_image_progress_bar.width / 100

        function positionProgress() {
            anchors.rightMargin = id_image_progress_bar.width - (progress * step)
        }

        YImage {
            id: id_image_progress_bar_front
            width: id_image_progress_bar.width
            height: id_image_progress_bar.height
            anchors.right: parent.right
            anchors.rightMargin: - parent.anchors.rightMargin
            sourceSize: id_image_progress_bar.sourceSize
            imageName: "audioplayer/progress_bar_fr"
        }
    }
}

