import QtQuick 2.12

Item {
    id: root

    property var fontFamily: fontManager.fontFamily
    property bool tavilyEnabled: false
    property bool tavilyConfigured: false

    signal webSearchToggled()
    signal fileReferenceRequested()
    signal newConversationRequested()
    signal attachImageRequested()

    anchors.fill: parent
    visible: opacity > 0
    opacity: 0
    z: 2000

    function show() {
        opacity = 1;
        menuContent.scale = 0.8;
        contentScale.from = 0.8;
        contentScale.to = 1.0;
        contentScale.restart();
    }

    function hide() {
        opacity = 0;
        menuContent.scale = 0.8;
    }

    Rectangle {
        anchors.fill: parent
        color: "#AA000000"
        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }
    }

    Rectangle {
        id: menuContent
        width: 260
        height: 150
        color: "#1C1C1E"
        radius: 20
        anchors.centerIn: parent
        scale: 0.8

        NumberAnimation on scale {
            id: contentScale
            duration: 200
            easing.type: Easing.OutBack
            from: 0.8
            to: 1.0
        }
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Grid {
            anchors.centerIn: parent
            columns: 2
            spacing: 15

            Rectangle {
                width: 100; height: 60; radius: 12
                color: root.tavilyEnabled ? "#2B5278" : "#2C2C2E"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Canvas {
                        width: 22; height: 22
                        anchors.horizontalCenter: parent.horizontalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = root.tavilyEnabled ? "#FFFFFF" : "#8899AA";
                            ctx.lineWidth = 2;
                            ctx.lineCap = "round";
                            var cx = 9, cy = 9, r = 6;
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.moveTo(cx + 4.2, cy + 4.2);
                            ctx.lineTo(cx + 8, cy + 8);
                            ctx.stroke();
                        }
                        property bool _dep: root.tavilyEnabled
                        on_DepChanged: requestPaint()
                    }
                    Text {
                        text: "网络搜索"
                        color: "white"
                        font.pixelSize: 12
                        font.family: root.fontFamily || fontManager.fontFamily
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.webSearchToggled();
                        root.hide();
                    }
                }
            }

            Rectangle {
                width: 100; height: 60; radius: 12
                color: "#2C2C2E"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "📁"
                        font.pixelSize: 18
                        font.family: root.fontFamily || fontManager.fontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "引用文件"
                        color: "white"
                        font.pixelSize: 12
                        font.family: root.fontFamily || fontManager.fontFamily
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.hide();
                        root.fileReferenceRequested();
                    }
                }
            }

            Rectangle {
                width: 100; height: 60; radius: 12
                color: "#2C2C2E"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "✨"
                        font.pixelSize: 18
                        font.family: root.fontFamily || fontManager.fontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "新对话"
                        color: "white"
                        font.pixelSize: 12
                        font.family: root.fontFamily || fontManager.fontFamily
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.newConversationRequested();
                        root.hide();
                    }
                }
            }

            Rectangle {
                width: 100; height: 60; radius: 12
                color: "#2C2C2E"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "📷"
                        font.pixelSize: 18
                        font.family: root.fontFamily || fontManager.fontFamily
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "拍摄图片"
                        color: "white"
                        font.pixelSize: 12
                        font.family: root.fontFamily || fontManager.fontFamily
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.hide();
                        root.attachImageRequested();
                    }
                }
            }
        }
    }
}
