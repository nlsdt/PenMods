import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_textbook_homework
    objectName: "YTextbookHomework.qml"
    anchors.fill: parent

    signal backButtonClicked()

    property bool tabTypeIsHistory: false

    YVerticalTitleBar {
        onCallBack: {
            id_homework_page_switch_loader.active = false
            textBookTaskManager.wipeData()
            id_textbook_page.subPageCallBack()
            backButtonClicked()
        }

        YIconButton {
            id: id_more_button_bg
            enabled: id_textbook_page.isSelectEnabled
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            radius: height/2
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(36, 36)
            imageName: "textbook/switch"
            onClicked: {
                logManager.sendHttpLog("action=textbook_change_click")
                showSubPage(YEnum.Textbook_MyTextbook, true)
            }
        }
    }

    YLoader {
        id: id_homework_page_switch_loader
        anchors.fill: parent
        anchors.leftMargin: 90
        active: true
        asynchronous: false

        function checkEmpty() {
            if (isLoaded) {
                item.delayCheckEmptyTimer.recheck()
                textBookTaskManager.entryTask(tabTypeIsHistory)
            }
        }

        onLoaded: {
            checkEmpty()
        }

        sourceComponent: id_content_component

        Component {
            id: id_content_component
            YBackgroundIgnoreMouseEvent {
                readonly property bool wordsListEmpty: (0 === id_homework_switch_listview.count)

                readonly property alias delayCheckEmptyTimer: id_delay_check_empty_timer

                function showFilter() {
                    id_homework_switch_drawer_layer.show()
                }

                YBaseListView {
                    id: id_homework_switch_listview
                    anchors.fill: parent
                    model: textBookTaskManager
                    onMovingChanged: {
                        if (!moving && atYEnd && textBookTaskManager.hasMore) {
                            textBookTaskManager.loadMore()
                        }
                    }

                    delegate: id_normal_delegate
                    header: id_header

                    footer: (textBookTaskManager.itemCount > 0 && textBookTaskManager.hasMore)
                            ? id_listview_loading_footer : id_listview_loaded_footer

                    Component {
                        id: id_listview_loading_footer

                        YListViewLoadMoreFooter {}
                    }

                    Component {
                        id: id_listview_loaded_footer

                        YSpacing {
                            width: id_homework_switch_listview.width
                            implicitHeight: 12
                        }
                    }

                    Component.onCompleted: {
                        id_textbook_homework.backButtonClicked.connect(function(){
                            id_homework_switch_listview.header = null
                            id_header.destroy()
                            id_homework_switch_listview.model = null
                            id_normal_delegate.destroy()
                        })
                    }
                }

                Item {
                    id: id_empty_tip_item
                    anchors.top: parent.top
                    anchors.topMargin: 110
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: id_empty_tip_content.width
                    visible: false

                    Row {
                        id: id_empty_tip_content
                        spacing: 10
                        height: 54
                        YImage {
                            id: id_empty_tip_icon
                            width: 36
                            height: 36
                            sourceSize: Qt.size(36, 36)
                            imageName: "textbook/homework-empty"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        YText {
                            id: id_empty_tip_text
                            height: 34
                            color: YColors.grayText
                            font.family: fontManager.fontFamilyZhCn
                            text: tabTypeIsHistory ? YTranslateText.textbookHomeworkHistoryEmptyTip
                                                   : YTranslateText.textbookHomeworkCurrentEmptyTip
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    YTimer {
                        id: id_delay_check_empty_timer
                        interval: 1000

                        function recheck() {
                            id_empty_tip_item.visible = false
                            restart()
                        }

                        function reshow() {
                            id_empty_tip_item.visible = Qt.binding(function(){
                                return (0 === id_homework_switch_listview.count)
                            })
                        }

                        onTriggered: {
                            reshow()
                        }
                        objectName: "YTextbookHomework.qml_id_delay_check_empty_timer"
                    }
                }

                Component.onCompleted: {
                    id_delay_check_empty_timer.recheck()
                }

                Component {
                    id: id_normal_delegate
                    YMouseArea {
                        id: id_normal_delegate_item
                        width: ListView.view.width
                        height: 86
                        readonly property var taskEntity: model.modelData

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            height: 76
                            color: YColors.grayNormal
                            opacity: parent.pressed ? 0.6 : 1
                            radius: 16

                            YImage {
                                id: id_item_icon
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                imageName: {
                                    switch(id_normal_delegate_item.taskEntity.type) {
                                    case YEnum.TTT_Listen:
                                        return "textbook/homework-listen"
                                    case YEnum.TTT_Follow:
                                    default:
                                        return "textbook/homework-follow"
                                    }
                                }
                                sourceSize: Qt.size(36, 36)
                            }

                            YTextMedium {
                                id: id_item_title
                                anchors.left: id_item_icon.right
                                anchors.leftMargin: 12
                                anchors.right: parent.right
                                anchors.rightMargin: 296
                                anchors.verticalCenter: parent.verticalCenter
                                height: contentHeight
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: 26
                                elide: YTextEnUs.ElideRight
                                text: id_normal_delegate_item.taskEntity.title
                            }

                            YText {
                                id: id_item_time
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                width: contentWidth
                                height: contentHeight
                                color: YColors.grayText
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: 24
                                visible: {
                                    if (tabTypeIsHistory && (YEnum.TTT_Follow === id_normal_delegate_item.taskEntity.type)) {
                                        return id_normal_delegate_item.taskEntity.solved && id_normal_delegate_item.taskEntity.upload
                                    }
                                    return true
                                }
                                text: {
                                    if (tabTypeIsHistory) {
                                        switch(id_normal_delegate_item.taskEntity.type) {
                                        case YEnum.TTT_Follow:
                                            return id_normal_delegate_item.taskEntity.solved && id_normal_delegate_item.taskEntity.upload ? YTranslateText.textbookTaskDone : YTranslateText.textbookTaskUndone
                                        case YEnum.TTT_Listen:
                                        default:
                                            return id_normal_delegate_item.taskEntity.solved ? YTranslateText.textbookTaskDone : YTranslateText.textbookTaskUndone
                                        }
                                    } else {
                                        return id_normal_delegate_item.taskEntity.expirationString + YTranslateText.textbookTaskDeadline
                                    }
                                }
                            }
                            YImage {
                                id: id_item_upload_button
                                sourceSize: Qt.size(36, 36)
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                imageName: "textbook/homework-upload"
                                visible: tabTypeIsHistory && !id_item_time.visible

                            }
                        }

                        onClicked: {
                            if (!tabTypeIsHistory) {

                                id_homework_task_guide.taskId = id_normal_delegate_item.taskEntity.id
                                id_homework_task_guide.taskType = id_normal_delegate_item.taskEntity.type
                                if ((YEnum.TTT_Listen === id_normal_delegate_item.taskEntity.type) && settingManager.needShowListenTaskGuide) {
                                    id_homework_task_guide.visible = true
                                    settingManager.needShowListenTaskGuide = false
                                }
                                else if ((YEnum.TTT_Listen === id_normal_delegate_item.taskEntity.type) && settingManager.needShowFollowTaskGuide) {
                                    id_homework_task_guide.visible = true
                                    settingManager.needShowFollowTaskGuide = false
                                }
                                else {
                                    textBookTaskManager.clickMedia(id_normal_delegate_item.taskEntity.id)
                                }
                            }
                            else if (id_item_upload_button.visible){
                                id_textbook_submithomework_dialog.show()
                                textBookTaskManager.retryUploadOralAudios(id_normal_delegate_item.taskEntity.id)
                            }
                        }
                    }
                }

                Component {
                    id: id_header
                    Item {
                        id: id_title_bar
                        width: ListView.view.width
                        implicitHeight: 80

                        YTabsTitleBar {
                            id: id_tab_title_bar
                            anchors.top: id_title_bar.top
                            anchors.topMargin: 24
                            anchors.left: id_title_bar.left
                            anchors.leftMargin: 20
                            namesArray: [YTranslateText.textbookTOLearn, YTranslateText.textbookHistoryWork]

                            onCurrentIndexChanged: {
                                updateUI()
                                id_homework_page_switch_loader.checkEmpty()
                            }

                            function updateUI() {
                                if (currentIndex === 0) {
                                    tabTypeIsHistory = false
                                } else if (currentIndex === 1) {
                                    tabTypeIsHistory = true
                                } else {
                                    console.log("index not hold : ", currentIndex)
                                }
                            }

                            Component.onCompleted: {
                                updateUI()
                            }
                        }
                    }
                }

            }
        }
    }

    YTextBookTaskGuide {
        id: id_homework_task_guide
        visible: false
    }

    YTextbookSubmitHomeworkDialog {
        id: id_textbook_submithomework_dialog
        anchors.fill: parent
        onSubmitFinished: {
            id_textbook_submithomework_dialog.close()
        }
        onClosed: {
            id_textbook_submithomework_dialog.close()
        }

        Component.onCompleted: {
            id_textbook_submithomework_dialog.submitDoing = true
        }

        Connections {
            target: textBookTaskManager
            ignoreUnknownSignals: true
            function onUploadOralAudioFinished(taskId, success, errCode, errMsg) {
                console.log("YTextbookHomework.qml===onUploadOralAudioFinished", success, errMsg)
                if (success) {
                    id_textbook_submithomework_dialog.submitDoing = false
                    id_textbook_submithomework_dialog.submitDone = true
                }
                else {
                    id_textbook_submithomework_dialog.close()
                    baseSignals.showToast(errMsg.length > 0 ? errMsg: YTranslateText.textbookHomeworkOralNotExist, "#2D2E33")
                }
            }
        }
    }

}

