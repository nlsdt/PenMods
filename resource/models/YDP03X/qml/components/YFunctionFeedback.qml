
import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"
import "../i18n"
// import QtQuick.Controls 1.4
// import QtQuick.Controls.Styles 1.4
YDialog{
    /*
    *feedbackContentModel 数据结构示例
    *
    [
        {title:"反馈分组1","arr":["反馈类型1","反馈类型2","返回类型3","反馈类型4"]},
        {title:"反馈分组2","arr":["反馈类型1","反馈类型2","返回类型3","反馈类型4"]}
    ]
    */
    id: id_feedback_dialog
    property var feedbackContentModel : []
    property var vis : true//false
    anchors.fill: parent
    z: 100
    visible : vis
    property var feedbackType : 1 // 0 查词反馈 1 语音反馈
    property var feedBackRequestArr : [];//保存问题类型

    property string orgSentence : ""
    property string currentSentence : ""

    function closeFeedbackpage(){
        close()
        closed()
        check_box_content_flickable.contentY = 0
    }

    function clearfeedBackRequest(){
        feedBackRequestArr.splice(0,feedBackRequestArr.length);
        updateDoneEnabled()
    }
    function addfeedBackContent(content){
        var isHascontent = false
        feedBackRequestArr.forEach(function(obj){
            if(content === obj)
                isHascontent = true
        })
        if(!isHascontent) feedBackRequestArr.push(content)
        updateDoneEnabled()
    }
    function delfeedbackContent(content){
        for(var i = 0; i < feedBackRequestArr.length;i++){
            if(feedBackRequestArr[i] === content){
                feedBackRequestArr.splice(i,1)
                break
            }
        }
        updateDoneEnabled()
    }

    function updateDoneEnabled(){
        id_done_button.enabled = feedBackRequestArr.length > 0 ? true : false
    }

    function createFeedbackModel(){
        clearfeedBackRequest()
        id_feedbackModel.clear()
        var arr = []
        var subArr = []
        switch (feedbackType){
        case 0:
            subArr.push({"Title":YTranslateText.feedBack_ide_error,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_inaccuratePronunciation,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_ParaphraseContentError,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_other,"Checked":false})
            id_feedbackModel.append({"Title":YTranslateText.feedBack_queryWord_title,"arr":subArr})
            break;
        case 1:
            subArr.push({"Title":YTranslateText.feedBack_littleContent,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_pq,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_contentError,"Checked":false})
            id_feedbackModel.append({"Title":YTranslateText.feedBack_res_content_title,"arr":subArr})
            subArr = []
            subArr.push({"Title":YTranslateText.feedBack_SpeechError,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_operateDiff,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_silent,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_misspeak,"Checked":false})
            subArr.push({"Title":YTranslateText.feedBack_other,"Checked":false})
            id_feedbackModel.append({"Title":YTranslateText.feedBack_more_title,"arr":subArr})
            break;
        case 2:
            subArr.push({"Title": "时态错误","Checked":false})
            subArr.push({"Title": "语态错误","Checked":false})
            subArr.push({"Title": "句子成分错误","Checked":false})
            subArr.push({"Title": "句子类型错误","Checked":false})
            subArr.push({"Title": "句子拆分错误","Checked":false})
            subArr.push({"Title": "其他错误","Checked":false})
            id_feedbackModel.append({"Title": "质量问题（多选）：","arr":subArr})
//            subArr = []
//            subArr.push({"Title": "理解困难","Checked":false})
//            subArr.push({"Title":"不好操作","Checked":false})
//            subArr.push({"Title":"其他","Checked":false})
//            id_feedbackModel.append({"Title": "体验问题（多选）：","arr":subArr})
            break
        default:
            break;
        }
    }

    Connections{
        enabled: true
        ignoreUnknownSignals: false
        target: systemBase
        onHomeKeyPress:{
            closeFeedbackpage()
        }
        onOcrStart: {
            closeFeedbackpage()
        }
    }
    
    
    Rectangle {
        id: id_vertical_bar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80
        color: "transparent"
        //关闭
        YIconButton {
            id: id_close_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height/2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "commons/close"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            onClicked: {

                closeFeedbackpage()
            }
        }
        //确定
        YIconButton {
            id: id_done_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height/2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "commons/confirm"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            onClicked: {

                if(!wifiManager.isOnline()){
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, "#2D2E33")
                }

                if(feedBackRequestArr.length ==0){
                    baseSignals.showToast("请选择要反馈的类型", "#2D2E33")
                    return;
                }

                closeFeedbackpage()
                var requestJson = {}
                requestJson.feedArray = feedBackRequestArr
                switch (feedbackType){
                case 0:
                    requestJson.asr = speechManager.asrResult
                    requestJson.res = speechManager.content
                    funcFeedback.feedBackQueryWords(JSON.stringify(requestJson))
                    break
                case 1:
                    requestJson.asr = speechManager.asrResult
                    requestJson.res = speechManager.content
                    funcFeedback.feedBackVoiceAssistant(JSON.stringify(requestJson))
                    break
                case 2:
                    requestJson.orgSentence = orgSentence
                    requestJson.currentSentence = currentSentence
                    funcFeedback.feedBackAiSentence(JSON.stringify(requestJson))
                    break
                default:

                }
//                if(feedbackType == 1){
//                    requestJson.asr = speechManager.asrResult
//                    requestJson.res = speechManager.content
//                    funcFeedback.feedBackVoiceAssistant(JSON.stringify(requestJson))
//                    // console.log("chenfei:feedBackRequestArr:",feedBackRequestArr,":asr:",speechManager.asrResult,":res:",speechManager.content)
//                }else{
//                    requestJson.asr = speechManager.asrResult
//                    requestJson.res = speechManager.content
//                    funcFeedback.feedBackQueryWords(JSON.stringify(requestJson))
//                }
                
            }
        }

    }

    ListModel{
        id: id_feedbackModel
    }
    
    Flickable{
        id: check_box_content_flickable
        anchors.left: id_vertical_bar.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 80
        contentHeight: check_box_conetentColum.height
        Column {
            id: check_box_conetentColum
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right

            YSpacingForColumn{
                height: 22
                visible: true
            }
            Repeater {
                id: id_feedback_content
                width: parent.width
                model: {
                    return id_feedbackModel//arr
                }
                Column {
                    width: parent.width
                    YText{
                        id: id_feedBack_title
                        text: Title//id_feedback_content.model[index].title
                        color: "#909199"
                        font.pixelSize: 28
                        verticalAlignment:Text.AlignVCenter
                    }

                    YSpacingForColumn{
                        height: 22
                        visible: true
                    }

                    Flow {
                        width: parent.width
                        spacing: 30
                        Repeater {
                            id: check_box_repeater
                            model: arr//id_feedback_content.model[index].arr
                            YCheckBox{
                                title: Title//check_box_repeater.model[index].title
                                checked: Checked//check_box_repeater.model[index].checked
                                onClicked:{
                                    console.log("chenfei:checked:",checked,"title:",title)
                                    if(checked)
                                        addfeedBackContent(title)
                                    else 
                                        delfeedbackContent(title)
                                }
                            }
                        } 
                    }
                    YSpacingForColumn{
                        height: 22
                        visible: true
                    }
                }
            }
        }
    }
}

