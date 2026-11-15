import BaseQml 1.0
import com.youdao.pen 1.0
import QtQuick 2.15

Item {
    id: root

    property string text: ""
    property string rawText: ""
    property string reasoningText: ""
    property bool isUser: false
    property bool isComplete: false
    property bool isThinking: false
    property bool isReasoning: false
    property bool isToolCall: false
    property string toolState: ""
    // read 读到的图片：展开条目时才显示，不作为消息附加到对话。
    property string imageSource: ""
    property string attachmentsJson: "[]"
    readonly property var attachments: {
        try {
            return JSON.parse(attachmentsJson || "[]");
        } catch (error) {
            return [];
        }
    }
    property bool mathServerAvailable: false
    property bool textureCacheEnabled: true
    property string renderMode: "full"
    property bool listMoving: false
    property bool listScrolledUp: false
    property bool navigationJumping: false
    property int messageIndex: -1
    property real listWidth: 320
    property real listContentY: 0
    property real listViewportHeight: 170
    property real richPreloadMargin: 510
    readonly property bool richContentNearViewport:
        y + Math.max(height, 44) >= listContentY - richPreloadMargin
        && y <= listContentY + listViewportHeight + richPreloadMargin
    property var fontFamily: fontManager.fontFamily
    property bool _pooled: false

    signal longPressed(real globalX, real globalY, int msgIndex)
    signal toolCardExpansionStarted(bool expanding)
    signal richContentCommitStarted(real itemY)
    signal attachmentOpenRequested(string attachmentType, string localPath)

    width: listWidth
    height: messageLoader.height

    Loader {
        id: messageLoader
        width: root.width
        height: item ? item.implicitHeight : 44
        sourceComponent: root.isThinking ? thinkingComponent
                       : root.isReasoning ? reasoningComponent
                       : root.isToolCall ? toolComponent
                       : root.isUser ? userComponent
                       : root.renderMode === "full" ? assistantComponent
                       : simpleAssistantComponent
    }

    Component {
        id: thinkingComponent
        Item {
            implicitWidth: root.width
            implicitHeight: thinkingDots.height + 8

            ThinkingDotsIndicator {
                id: thinkingDots
                isAnimating: true
                anchors.verticalCenter: parent.verticalCenter
                x: 8
            }
        }
    }

    Component {
        id: reasoningComponent
        Item {
            implicitWidth: root.width
            implicitHeight: reasoningRow.height + 2

            AgentRow {
                id: reasoningRow
                width: parent.width
                label: "思考 · " + (root.rawText || "").split("\n")[0]
                detail: root.rawText
                detailStyle: "text"
                streaming: !root.isComplete
                onExpansionStarted: function (expanding) {
                    root.toolCardExpansionStarted(expanding);
                }
            }
        }
    }

    Component {
        id: toolComponent
        Item {
            implicitWidth: root.width
            implicitHeight: toolRow.height + 2

            AgentRow {
                id: toolRow
                width: parent.width
                label: root.text
                detail: root.rawText
                detailStyle: "terminal"
                state: root.toolState
                imageSource: root.imageSource || ""
                onExpansionStarted: function (expanding) {
                    root.toolCardExpansionStarted(expanding);
                }
            }
        }
    }

    Component {
        id: simpleAssistantComponent
        Item {
            implicitWidth: root.width
            implicitHeight: simpleContent.height + 10

            Column {
                id: simpleContent
                x: 8
                spacing: 8

                AttachmentMessage {
                    attachments: root.attachments
                    fontFamily: root.fontFamily
                    onOpenRequested: function (attachmentType, localPath) {
                        root.attachmentOpenRequested(attachmentType, localPath);
                    }
                    onLongPressed: function (globalX, globalY) {
                        root.longPressed(globalX, globalY, root.messageIndex);
                    }
                }

                SimpleAssistantBubble {
                    id: simpleBubble
                    rawText: root.rawText
                    isComplete: root.isComplete
                    richText: root.renderMode === "basic"
                    maxWidth: root.listWidth - 16
                    fontFamily: root.fontFamily

                    MouseArea {
                        anchors.fill: parent
                        onPressAndHold: {
                            var pos = mapToItem(null, mouseX, mouseY);
                            root.longPressed(pos.x, pos.y, root.messageIndex);
                        }
                    }
                }
            }
        }
    }

    Component {
        id: assistantComponent
        Item {
            id: assistantItem
            implicitWidth: root.width
            implicitHeight: assistantContent.height + 10
            readonly property bool containsMath: root.rawText.indexOf("$") !== -1
                                                 || root.rawText.indexOf("\\(") !== -1
                                                 || root.rawText.indexOf("\\[") !== -1
            readonly property bool textureCacheActive: root.textureCacheEnabled && !root._pooled
                                                       && root.richContentNearViewport
                                                       && root.isComplete && !containsMath
                                                       && mixedBubble.renderReady && aiBubble.height > 0
                                                       && aiBubble.height <= 1024

            Column {
                id: assistantContent
                x: 8
                spacing: 8

                AttachmentMessage {
                    attachments: root.attachments
                    fontFamily: root.fontFamily
                    onOpenRequested: function (attachmentType, localPath) {
                        root.attachmentOpenRequested(attachmentType, localPath);
                    }
                    onLongPressed: function (globalX, globalY) {
                        root.longPressed(globalX, globalY, root.messageIndex);
                    }
                }

            Rectangle {
                id: aiBubble
                width: root.listWidth - 16
                height: mixedBubble.implicitHeight + 18
                // DSH 风格：助手消息不画气泡，只有用户消息有灰色气泡。
                radius: 0
                color: "transparent"
                clip: true
                layer.enabled: assistantItem.textureCacheActive
                layer.smooth: false
                layer.mipmap: false

                MixedContentBubble {
                    id: mixedBubble
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                    rawText: (root.reasoningText !== ""
                              ? "**推理过程**\n\n" + root.reasoningText + "\n\n**回答**\n\n" : "") + root.rawText
                    isComplete: root.isComplete
                    streamTailOnly: !root.listScrolledUp
                    serverAvailable: root.mathServerAvailable
                    layoutBusy: root.listMoving || root.navigationJumping || !root.richContentNearViewport
                    parseDelay: 16 + Math.abs(root.messageIndex % 4) * 20
                    maxWidth: root.listWidth - 44
                    fontFamily: root.fontFamily
                    onRenderCommitStarted: root.richContentCommitStarted(root.y)
                }

                MouseArea {
                    id: aiMessageGestureArea
                    anchors.fill: parent
                    z: 1
                    onPressAndHold: {
                        var pos = aiMessageGestureArea.mapToItem(null, mouseX, mouseY);
                        root.longPressed(pos.x, pos.y, root.messageIndex);
                    }
                }
            }
            }
        }
    }

    Component {
        id: userComponent
        Item {
            implicitWidth: root.width
            implicitHeight: userContent.height + 10

            Column {
                id: userContent
                width: Math.max(attachmentStrip.implicitWidth, chatBubble.width)
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 8

                AttachmentMessage {
                    id: attachmentStrip
                    anchors.right: parent.right
                    attachments: root.attachments
                    fontFamily: root.fontFamily
                    onOpenRequested: function (attachmentType, localPath) {
                        root.attachmentOpenRequested(attachmentType, localPath);
                    }
                    onLongPressed: function (globalX, globalY) {
                        root.longPressed(globalX, globalY, root.messageIndex);
                    }
                }

                ChatBubble {
                    id: chatBubble
                    text: root.text
                    visible: root.text !== ""
                    isUser: true
                    isComplete: root.isComplete
                    maxBubbleWidth: root.listWidth * 0.85
                    containerWidth: root.listWidth
                    fontFamily: root.fontFamily
                    anchors.right: parent.right
                    onPressAndHold: {
                        var pos = chatBubble.mapToItem(null, mouseX, mouseY);
                        root.longPressed(pos.x, pos.y, root.messageIndex);
                    }
                }
            }
        }
    }

    Timer {
        id: layerRearmTimer
        interval: 16
        repeat: false
        onTriggered: root._pooled = false
    }

    ListView.onPooled: {
        layerRearmTimer.stop();
        root._pooled = true;
    }
    ListView.onReused: {
        root._pooled = true;
        layerRearmTimer.restart();
    }
}
