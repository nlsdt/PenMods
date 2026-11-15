import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
YPage {
    id: id_speech_newitem
    objectName: "YPage === YSpeechNewDetail.qml"
    property var resType : 0;
    property var content : JSON.parse(speechManager.newcontent);
    property var enterTimestamp: null
    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            soundCenter.stop();
            backButtonClicked();
        }
    }

    Component.onDestruction: {
        if (enterTimestamp !== null) {
            logManager.sendHttpLog("action=assistant_stay_time&duration=%1".arg(Math.floor(new Date() - enterTimestamp) / 1000))
            enterTimestamp = null
        }
    }
    YFunctionFeedback{
        id: id_feedback_dialog
    }


    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 26
        contentHeight: id_speech_content.height
        //语音助手 反馈按钮
        YIconButton {
            id: id_voice_feedback_button
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            anchors.right: parent.right
            anchors.rightMargin: 16
            icon: "assistant/report"
            sourceSize: Qt.size(36, 36)
            onValidClicked: {
                if(!wifiManager.isOnline()){
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, "#1A1B1F")
                }else{
                    id_feedback_dialog.createFeedbackModel()
                    id_feedback_dialog.show()
                }

            }
        }
        Column {
            id: id_speech_content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 16
            YTextCH {
                id: id_title_text
                width: parent.width - id_voice_feedback_button.width - 20
                horizontalAlignment : YText.AlignHLeft
                verticalAlignment: YText.AlignVCenter
                color: YColors.grayText
                wrapMode: YTextBase.Wrap
                text: speechManager.asrResult
            }
            YSpacingForColumn {
                implicitHeight: id_title_text.lineCount > 1 ? 16 : 26
            }
            Rectangle{
                id: id_speech_commontext
                color: YColors.grayNormal
                radius: 16
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_speech_commontext_info.height + 44
                visible: resType === "message" || resType === "not_support"
                // 发音按钮
                 YAudioPlayButton {
                     id: id_follow_content_pron
                     textFontFamily: fontManager.fontFamilyEnUs
                     textFormat: YText.PlainText
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     color: YColors.transparent
                     enabled: true
                     visible: true
                     onValidClicked: {
                         if (playing) {
                             playWord(content.metadata.msg, "ch")
                         }
                     }
                 }

                YTextCH {
                    id: id_speech_commontext_info
                    anchors.left: id_follow_content_pron.right
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 22
                    font.pixelSize: 28
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 38
                    textFormat: YText.RichText
                    wrapMode: YTextBase.Wrap
                    text: content.metadata.msg
                    onVisibleChanged: {

                    }
                }
            }


        }
    }
    Connections{
        enabled: true
        ignoreUnknownSignals: true
        target: funcFeedback
        onRequestResultCallBack:{
            console.log("seven:voicefeedback:",responseJsonString)
            if(responseJsonString === "0"){
                id_voice_feedback_button.visible = false
                baseSignals.showToast(YTranslateText.thxReport, "#1A1B1F")
            }else
                baseSignals.showToast(YTranslateText.thxReportError, "#1A1B1F")
        }
    }

    function visibleChanged() {
        if (visible) {
            logManager.sendHttpLog("view=assistant_view&query=%1".arg(speechManager.asrResult))
            enterTimestamp = new Date()
        }
    }
}


