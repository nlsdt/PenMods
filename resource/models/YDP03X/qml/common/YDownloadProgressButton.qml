import QtQuick 2.12

Item {
    id: id_download_progress_button
    implicitWidth: 226
    implicitHeight: 72
    opacity: id_mouse_area.pressed || !enabled ? 0.6 : 1

    property alias buttonColor: id_button_bg.color
    property alias progressColor: id_progress_fg.color
    property int progress: 0
    property alias text: id_button_label.text
    property alias textFamily: id_button_label.font.family
    property alias clickable: id_mouse_area.enabled
    property int radius: id_button_bg.radius

    onProgressChanged: {
        id_progress_rect.updateProgress()
    }

    readonly property real step: width / 100.0

    signal download()

    YMouseArea {
        id: id_mouse_area
        anchors.fill: parent
        objectName: "YDownloadProgressButton.qml_YMouseArea"
        enabled: (progress >= 0)
        onClicked: {
            download()
        }
    }

    Rectangle {
        id: id_button_bg
        anchors.fill: parent
        color: "#383940"
        radius: height/2
        smooth: true

        Item {
            id: id_progress_rect
            anchors.fill: parent
            smooth: true
            clip: true

            Rectangle {
                id: id_progress_fg
                implicitWidth: id_download_progress_button.width
                implicitHeight: id_download_progress_button.height
                anchors.right: parent.right
                anchors.rightMargin: -parent.anchors.rightMargin
                color: "#FFFFFF"
                radius: height/2
                smooth: true
            }

            function updateProgress() {
                if (0 === progress) {
                    id_progress_rect.anchors.rightMargin
                            = id_download_progress_button.width + 10
                } else if (100 === progress) {
                    id_progress_rect.anchors.rightMargin = 0
                } else {
                    id_progress_rect.anchors.rightMargin
                            = id_download_progress_button.width - step * progress
                }
            }
        }
    }

    YTextMedium {
        id: id_button_label
        font.pixelSize: 26
        anchors.centerIn: parent
    }

    Component.onCompleted: {
        id_progress_rect.updateProgress()
    }
}
