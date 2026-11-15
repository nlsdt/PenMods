import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: root

    property var attachments: []
    property var fontFamily: fontManager.fontFamily
    signal openRequested(string localPath)
    signal longPressed(real globalX, real globalY)

    readonly property int imageCount: !attachments ? 0
                                             : attachments.count !== undefined ? attachments.count
                                             : attachments.length !== undefined ? attachments.length : 0

    function attachmentAt(index) {
        if (!attachments)
            return null;
        return typeof attachments.get === "function" ? attachments.get(index) : attachments[index];
    }

    readonly property int thumbnailSize: 58
    readonly property int thumbnailSpacing: 6
    implicitWidth: Math.min(210, imageCount * thumbnailSize + Math.max(0, imageCount - 1) * thumbnailSpacing)
    implicitHeight: imageCount > 0 ? thumbnailSize : 0
    width: implicitWidth
    height: implicitHeight
    visible: imageCount > 0
    clip: true

    Row {
        anchors.fill: parent
        spacing: root.thumbnailSpacing

        Repeater {
            model: root.imageCount

            Item {
                id: thumbnail
                readonly property var attachment: root.attachmentAt(index)
                width: root.thumbnailSize
                height: root.thumbnailSize

                Image {
                    id: sourceImage
                    anchors.fill: parent
                    anchors.margins: 1
                    source: thumbnail.attachment ? thumbnail.attachment.source || "" : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    visible: false
                }

                Rectangle {
                    id: imageMask
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: 6
                    visible: false
                }

                OpacityMask {
                    anchors.fill: sourceImage
                    source: sourceImage
                    maskSource: imageMask
                    cached: true
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "transparent"
                    border.width: 1
                    border.color: "#515259"
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "#000000"
                    opacity: imageMouse.pressed ? 0.25 : 0
                }

                MouseArea {
                    id: imageMouse
                    anchors.fill: parent
                    onClicked: {
                        if (parent.attachment && parent.attachment.localPath)
                            root.openRequested(parent.attachment.localPath);
                    }
                    onPressAndHold: {
                        var pos = mapToItem(null, mouseX, mouseY);
                        root.longPressed(pos.x, pos.y);
                    }
                }
            }
        }
    }
}
