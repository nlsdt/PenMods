import QtQuick 2.12

Item {
    id: root
    anchors.fill: parent
    visible: active
    z: 3000

    property string toolCallId: ""
    property string command: ""
    property var fontFamily: fontManager.fontFamily
    property bool active: false

    property var queue: []

    signal approved(string toolCallId)
    signal denied(string toolCallId)

    function show(tcId, cmd) {
        if (active) {
            queue.push({"toolCallId": tcId, "command": cmd});
            return;
        }
        toolCallId = tcId;
        command = cmd;
        active = true;
    }

    function processNext() {
        if (queue.length > 0) {
            var next = queue.shift();
            toolCallId = next.toolCallId;
            command = next.command;
        } else {
            active = false;
            toolCallId = "";
            command = "";
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#CC000000"
        MouseArea { anchors.fill: parent }
    }

    Rectangle {
        id: dialogCard
        width: 290
        height: contentCol.height + 24
        anchors.centerIn: parent
        radius: 16
        color: "#1A1B1F"
        border.width: 1
        border.color: "#FF6B35"

        Column {
            id: contentCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 8

            Text {
                text: root.queue.length > 0
                    ? "AI 请求执行命令 (" + (root.queue.length + 1) + ")"
                    : "AI 请求执行命令"
                color: "#FF6B35"
                font.pixelSize: 13
                font.bold: true
                font.family: root.fontFamily || fontManager.fontFamily
            }

            Rectangle {
                width: parent.width
                height: Math.min(cmdText.implicitHeight + 12, 60)
                radius: 8
                color: "#141519"
                border.width: 1
                border.color: "#515259"
                clip: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 6
                    contentWidth: cmdText.implicitWidth
                    contentHeight: cmdText.implicitHeight
                    clip: true

                    Text {
                        id: cmdText
                        text: root.command
                        color: "#E0E0E0"
                        font.pixelSize: 11
                        font.family: root.fontFamily || fontManager.fontFamily
                        wrapMode: Text.Wrap
                        width: parent.parent.width - 12
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Rectangle {
                    width: 100; height: 32; radius: 10
                    color: "#2E1A1A"
                    border.width: 1; border.color: "#4A2A2A"
                    Text {
                        anchors.centerIn: parent
                        text: "拒绝"
                        color: "#FF453A"
                        font.pixelSize: 13
                        font.family: root.fontFamily || fontManager.fontFamily
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.denied(root.toolCallId);
                            root.processNext();
                        }
                    }
                }

                Rectangle {
                    width: 100; height: 32; radius: 10
                    color: "#1A2E1A"
                    border.width: 1; border.color: "#2A4A2A"
                    Text {
                        anchors.centerIn: parent
                        text: "执行"
                        color: "#4CAF50"
                        font.pixelSize: 13
                        font.family: root.fontFamily || fontManager.fontFamily
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.approved(root.toolCallId);
                            root.processNext();
                        }
                    }
                }
            }
        }
    }
}
