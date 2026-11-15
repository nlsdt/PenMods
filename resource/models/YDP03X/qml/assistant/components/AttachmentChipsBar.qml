import QtQuick 2.12

Rectangle {
    id: root

    property var filesModel: null
    property var mediaModel: null
    property var fontFamily

    function formatIcon(item, isMedia) {
        if (isMedia)
            return item && item.type === "input_audio"
                    ? "qrc:/images/format/suffix-mp3.png"
                    : "qrc:/images/format/suffix-image.png";
        var name = item && item.name ? item.name.toLowerCase() : "";
        if (/\.(md|markdown)$/.test(name)) return "qrc:/images/format/suffix-md.png";
        if (/\.json$/.test(name)) return "qrc:/images/format/suffix-json.png";
        if (/\.(xml|qml|html|htm)$/.test(name)) return "qrc:/images/format/suffix-xml.png";
        if (/\.(sh|bash)$/.test(name)) return "qrc:/images/format/suffix-sh.png";
        return "qrc:/images/format/suffix-txt.png";
    }

    height: 34
    radius: 8
    color: "#CC1A1B1F"
    border.width: 1
    border.color: "#515259"

    ListView {
        anchors { fill: parent; margins: 4 }
        orientation: ListView.Horizontal
        spacing: 6
        clip: true
        model: (root.filesModel ? root.filesModel.count : 0) + (root.mediaModel ? root.mediaModel.count : 0)

        delegate: Rectangle {
            readonly property int fileCount: root.filesModel ? root.filesModel.count : 0
            readonly property bool isMediaChip: index >= fileCount
            readonly property int mediaIndex: index - fileCount
            readonly property var chipData: isMediaChip
                ? (root.mediaModel && mediaIndex < root.mediaModel.count ? root.mediaModel.get(mediaIndex) : null)
                : (root.filesModel && index < root.filesModel.count ? root.filesModel.get(index) : null)

            height: 26
            width: chipContent.implicitWidth + 36
            radius: 6
            color: isMediaChip ? "#28552A" : "#2B5278"

            Row {
                id: chipContent
                anchors {
                    left: parent.left
                    leftMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                spacing: 4

                Image {
                    width: 15
                    height: 15
                    source: root.formatIcon(chipData, isMediaChip)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: chipData ? (chipData.label || chipData.name || chipData.type || "") : ""
                    color: "#FFFFFF"
                    font.pixelSize: 11
                    font.family: root.fontFamily || ""
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                    width: Math.min(implicitWidth, 120)
                }
            }

            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 2
                }
                width: 22
                height: 22
                radius: 11
                color: "#44FFFFFF"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    onClicked: {
                        if (isMediaChip) {
                            root.mediaModel.remove(mediaIndex, 1);
                        } else {
                            root.filesModel.remove(index, 1);
                        }
                    }
                }
            }
        }
    }
}
