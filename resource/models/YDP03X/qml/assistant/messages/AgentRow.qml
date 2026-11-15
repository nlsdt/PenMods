import QtQuick 2.12

// 「思考 · …」「运行命令 · …」「搜索 · …」「读取 · …」共用的行模板：
// 一行 12px 灰字 + 右侧展开箭头，展开后是明细块。
// read 读到的图片也挂在这里显示，不往对话里插消息。
Item {
    id: root

    property string label: ""
    property string detail: ""
    // "text"：普通灰字正文（思考）；"terminal"：等宽终端块（命令输出）。
    property string detailStyle: "text"
    // 展开后显示的图片（file:// 或 data:），为空则不显示。
    property string imageSource: ""
    // 流式过程中默认展开并跟随最新内容。
    property bool streaming: false
    property string state: ""

    property bool userToggled: false
    property bool userExpanded: false
    readonly property bool expanded: userToggled ? userExpanded : streaming
    readonly property bool hasDetail: detail !== "" || imageSource !== ""

    readonly property real bodyHeight: (expanded && hasDetail)
                                         ? Math.min(detailColumn.implicitHeight + 12, 200)
                                         : 0

    signal expansionStarted(bool expanding)

    width: parent ? parent.width : 0
    height: 18 + bodyHeight

    Item {
        id: header
        width: parent.width
        height: 18

        Text {
            id: labelText
            // 行首 8px：和正文/其它 trace 行同一左网格。
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: chevron.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            textFormat: Text.PlainText
            color: root.state === "error" ? "#FF6B6B" : "#8A8A8A"
            font.pixelSize: 12
            font.family: fontManager.fontFamily
            elide: Text.ElideRight
        }

        Canvas {
            id: chevron
            width: 12
            height: 12
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasDetail
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "#8A8A8A";
                ctx.lineWidth = 1.5;
                ctx.beginPath();
                if (root.expanded) {
                    ctx.moveTo(2, 8); ctx.lineTo(6, 4); ctx.lineTo(10, 8);
                } else {
                    ctx.moveTo(2, 4); ctx.lineTo(6, 8); ctx.lineTo(10, 4);
                }
                ctx.stroke();
            }
            Connections {
                target: root
                function onExpandedChanged() { chevron.requestPaint(); }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.hasDetail
            // 不能在整行上 preventStealing：那样从 trace 行起手拖动时列表完全不滚。
            preventStealing: false
            onClicked: {
                var next = !root.expanded;
                root.expansionStarted(next);
                root.userExpanded = next;
                root.userToggled = true;
            }
        }
    }

    Rectangle {
        id: detailCard
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.bodyHeight
        visible: height > 0
        color: root.detailStyle === "terminal" ? "#141416" : "transparent"
        radius: root.detailStyle === "terminal" ? 6 : 0
        border.width: root.detailStyle === "terminal" ? 1 : 0
        border.color: "#2C2C2E"
        clip: true

        Flickable {
            id: detailViewport
            anchors.fill: parent
            anchors.margins: root.detailStyle === "terminal" ? 6 : 0
            anchors.leftMargin: 8
            clip: true
            contentWidth: width
            contentHeight: detailColumn.implicitHeight
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds

            function followLatest() {
                if (root.streaming)
                    contentY = Math.max(0, contentHeight - height);
            }

            Column {
                id: detailColumn
                width: detailViewport.width
                spacing: 6

                Image {
                    id: detailImage
                    width: parent.width
                    visible: root.imageSource !== "" && status !== Image.Error
                    source: root.imageSource
                    asynchronous: true
                    cache: false
                    fillMode: Image.PreserveAspectFit
                    // 按原始比例缩放，最高 160px，避免一张大图撑爆列表。
                    height: (visible && sourceSize.width > 0)
                                ? Math.min(160, width * sourceSize.height / sourceSize.width)
                                : 0
                }

                Text {
                    id: detailText
                    width: parent.width
                    text: root.detail
                    color: "#8A8A8A"
                    font.pixelSize: 11
                    font.family: root.detailStyle === "terminal" ? "monospace" : fontManager.fontFamily
                    wrapMode: Text.WrapAnywhere
                    lineHeight: 1.3
                    visible: text !== ""
                    onImplicitHeightChanged: Qt.callLater(detailViewport.followLatest)
                }
            }

            onHeightChanged: Qt.callLater(followLatest)
        }
    }
}
