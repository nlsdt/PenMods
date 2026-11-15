import QtQuick 2.15

Column {
    id: root

    property var attachments: []
    property var fontFamily: fontManager.fontFamily
    signal openRequested(string localPath)
    signal longPressed(real globalX, real globalY)

    spacing: 6
    visible: attachments && attachments.length > 0

    function formatIcon(name) {
        var lowerName = name ? name.toLowerCase() : "";
        if (/\.(md|markdown)$/.test(lowerName)) return "qrc:/images/format/suffix-md.png";
        if (/\.json$/.test(lowerName)) return "qrc:/images/format/suffix-json.png";
        if (/\.(xml|qml|html|htm)$/.test(lowerName)) return "qrc:/images/format/suffix-xml.png";
        if (/\.(sh|bash)$/.test(lowerName)) return "qrc:/images/format/suffix-sh.png";
        return "qrc:/images/format/suffix-txt.png";
    }

    function sizeLabel(bytes) {
        if (!bytes || bytes <= 0)
            return "文本文件";
        if (bytes < 1024)
            return bytes + " B";
        return Math.max(1, Math.round(bytes / 1024)) + " KB";
    }

    Repeater {
        model: root.attachments || []

        Rectangle {
            width: 210
            height: 42
            radius: 6
            color: "#000000"
            border.width: 1
            border.color: "#515259"

            Image {
                id: fileIcon
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                source: root.formatIcon(modelData.name)
                fillMode: Image.PreserveAspectFit
            }

            Column {
                anchors.left: fileIcon.right
                anchors.leftMargin: 7
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: modelData.name || "文本附件"
                    color: "#E6EDF3"
                    font.pixelSize: 11
                    font.family: root.fontFamily || fontManager.fontFamily
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                }

                Text {
                    width: parent.width
                    text: root.sizeLabel(modelData.size)
                    color: "#8297A8"
                    font.pixelSize: 9
                    font.family: root.fontFamily || fontManager.fontFamily
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: "#000000"
                opacity: fileMouse.pressed ? 0.2 : 0
            }

            MouseArea {
                id: fileMouse
                anchors.fill: parent
                onClicked: {
                    if (modelData.localPath)
                        root.openRequested(modelData.localPath);
                }
                onPressAndHold: {
                    var pos = mapToItem(null, mouseX, mouseY);
                    root.longPressed(pos.x, pos.y);
                }
            }
        }
    }
}
