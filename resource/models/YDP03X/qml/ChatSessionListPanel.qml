import BaseQml 1.0
import com.youdao.pen 1.0
import QtQuick 2.12
import com.github.penuniverse 1.0

// 会话历史列表面板，从左侧滑入。
Rectangle {
    id: id_root
    width: 0
    height: parent ? parent.height : 170
    color: "#000000"
    clip: true
    z: 100

    // 面板宽度（动画目标值）
    property real panelWidth: 180
    // 是否正在显示
    property bool isOpen: false
    // 会话列表模型
    property var sessionsData: []
    // 当前活动会话 ID
    property string activeSessionId: ""

    // 关闭信号
    signal closeRequested
    // 会话切换信号
    signal sessionSelected(string sessionId)
    // 新会话创建信号
    signal newSessionRequested
    // 重命名会话信号
    signal renameSessionRequested(string sessionId, string sessionTitle)

    // 动画控制
    Behavior on width {
        NumberAnimation {
            duration: 130
            easing.type: Easing.OutCubic
        }
    }

    function open() {
        width = panelWidth;
        isOpen = true;
        refreshSessions();
    }

    function close() {
        width = 0;
        isOpen = false;
    }

    function toggle() {
        if (isOpen)
            close();
        else
            open();
    }

    function refreshSessions() {
        if (typeof chatbot !== 'undefined' && chatbot !== null && typeof chatbot.getSessions === 'function') {
            var jsonStr = chatbot.getSessions();
            try {
                var data = JSON.parse(jsonStr);
                sessionsData = data.sessions || [];
                activeSessionId = data.activeSessionId || "";
                // 按更新时间倒序排列
                sessionsData.sort(function (a, b) {
                    if (a.updatedAt > b.updatedAt)
                        return -1;
                    if (a.updatedAt < b.updatedAt)
                        return 1;
                    return 0;
                });
            } catch (e) {
                console.error("解析会话列表失败: " + e);
                sessionsData = [];
            }
        }
    }

    // 当面板打开时刷新数据
    onIsOpenChanged: {
        if (isOpen)
            refreshSessions();
    }

    // 面板内容（仅在宽度 > 0 时有意义）
    Column {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4
        visible: id_root.width > 10

        // 标题栏
        Row {
            width: parent.width
            height: 26
            spacing: 4

            Text {
                text: "对话历史"
                color: "#FFFFFF"
                font.pixelSize: 12
                font.family: fontManager.fontFamily
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: 1
                height: 1
            } // spacer

            // 新建会话按钮
            Rectangle {
                width: 22
                height: 22
                radius: 7
                color: newSessionMouse.pressed ? "#2B5278" : "#1A1B1F"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "+"
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.family: fontManager.fontFamily
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: newSessionMouse
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: {
                        id_root.close();
                        id_root.newSessionRequested();
                    }
                }
            }
        }

        // 分割线
        Rectangle {
            width: parent.width
            height: 1
            color: "#515259"
        }

        // 会话列表
        ListView {
            id: sessionListView
            width: parent.width
            height: parent.height - 38
            clip: true
            model: sessionsData
            spacing: 3

            delegate: Rectangle {
                width: sessionListView.width
                height: 38
                radius: 8
                color: {
                    if (modelData.id === id_root.activeSessionId)
                        return "#1A1B1F";
                    if (sessionMouse.pressed)
                        return "#1A1B1F";
                    return "#1A1B1F";
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 1

                    Text {
                        text: modelData.title || "未命名对话"
                        color: "#FFFFFF"
                        font.pixelSize: 11
                        font.family: fontManager.fontFamily
                        font.bold: modelData.id === id_root.activeSessionId
                        elide: Text.ElideRight
                        width: parent.width - 50
                    }

                    Text {
                        text: (modelData.messageCount || 0) + " 条消息"
                        color: "#5A6B7D"
                        font.pixelSize: 9
                        font.family: fontManager.fontFamily
                    }
                }

                // 删除按钮
                Rectangle {
                    id: deleteBtn
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 6
                    }
                    width: 20
                    height: 20
                    radius: 5
                    color: deleteBtnMouse.pressed ? "#44FF453A" : "transparent"
                    visible: sessionsData.length > 1
                    z: 10

                    Text {
                        text: "×"
                        color: "#FF453A"
                        font.pixelSize: 14
                        font.family: fontManager.fontFamily
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: deleteBtnMouse
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        onClicked: {
                            if (typeof chatbot !== 'undefined' && chatbot !== null) {
                                chatbot.deleteSession(modelData.id);
                                id_root.refreshSessions();
                            }
                        }
                    }
                }

                MouseArea {
                    id: sessionMouse
                    anchors.fill: parent
                    onClicked: {
                        // 检查点击是否在删除按钮上，如果是则不处理
                        var clickPos = mapToItem(deleteBtn, mouse.x, mouse.y);
                        if (clickPos.x >= -6 && clickPos.x <= deleteBtn.width + 6 && clickPos.y >= -6 && clickPos.y <= deleteBtn.height + 6) {
                            return;
                        }

                        if (modelData.id !== id_root.activeSessionId) {
                            id_root.sessionSelected(modelData.id);
                        }
                        id_root.close();
                    }
                    onPressAndHold: {
                        // 检查长按是否在删除按钮上
                        var pressPos = mapToItem(deleteBtn, mouse.x, mouse.y);
                        if (pressPos.x >= -6 && pressPos.x <= deleteBtn.width + 6 && pressPos.y >= -6 && pressPos.y <= deleteBtn.height + 6) {
                            return;
                        }
                        // 长按弹出重命名
                        id_root.renameSessionRequested(modelData.id, modelData.title || "未命名对话");
                    }
                }
            }
        }
    }
}
