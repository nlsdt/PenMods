import QtQuick 2.15

Item {
    id: root

    property var attachments: []
    property var fontFamily: fontManager.fontFamily
    signal openRequested(string attachmentType, string localPath)
    signal longPressed(real globalX, real globalY)

    readonly property var imageAttachments: filterAttachments("image_url")
    readonly property var fileAttachments: filterAttachments("file")

    function filterAttachments(type) {
        var result = [];
        if (!attachments)
            return result;
        var count = attachments.count !== undefined ? attachments.count : attachments.length;
        for (var index = 0; index < count; index++) {
            var attachment = typeof attachments.get === "function" ? attachments.get(index) : attachments[index];
            if (attachment && attachment.type === type)
                result.push(attachment);
        }
        return result;
    }

    implicitWidth: Math.max(imageStrip.implicitWidth, fileList.implicitWidth)
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    visible: imageAttachments.length > 0 || fileAttachments.length > 0

    Column {
        id: content
        spacing: 6

        ImageAttachmentStrip {
            id: imageStrip
            attachments: root.imageAttachments
            fontFamily: root.fontFamily
            onOpenRequested: root.openRequested("image_url", localPath)
            onLongPressed: root.longPressed(globalX, globalY)
        }

        FileAttachmentList {
            id: fileList
            attachments: root.fileAttachments
            fontFamily: root.fontFamily
            onOpenRequested: root.openRequested("file", localPath)
            onLongPressed: root.longPressed(globalX, globalY)
        }
    }
}
