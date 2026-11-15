import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Shapes 1.14
import QtGraphicalEffects 1.14
import BaseQml 1.0
import "../i18n"
import "../components"
YPage {
    id: id_ai_sentence_analusis
    anchors.fill: parent


    YPopLayer {
        id: id_ai_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, true, false, properties)
            currentShowPage = popItemObject
        }
    }
    property var currentShowPage: null
    property string feedbackeds : ""

    function getFeedbackCurrentKey(){
        return id_sentence_detaile.getCurrentParentSenten() + id_sentence_detaile.getCurrentSentens()
    }


    function jumpTofeedBack(){
        console.log("seven:feedBack:",id_sentence_detaile.getCurrentSentens(),id_sentence_detaile.getLableSentence())
        if(!wifiManager.isOnline()){
            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, "#2D2E33")
        }else{
            id_feedback_dialog.orgSentence = id_sentence_detaile.getCurrentParentSenten()//id_sentence_detaile.getLableSentence()
            id_feedback_dialog.currentSentence = id_sentence_detaile.getCurrentSentens()
            console.log("seven:feedback:",id_feedback_dialog.orgSentence,id_feedback_dialog.currentSentence)
            id_feedback_dialog.feedbackType = 2
            id_feedback_dialog.createFeedbackModel()
            id_feedback_dialog.show()
        }
    }

    YFunctionFeedback{
        id: id_feedback_dialog
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            if(id_sentence_detaile.popStach() === 1){
                baseSignals.hideLoading()
                backButtonClicked()
            }

        }
    }

    Column {
        id: id_menu_bar_colum
        width: 80
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        Rectangle {
            width: parent.width
            height: 60
            color: "transparent"
            visible: feedbackeds.indexOf(getFeedbackCurrentKey()) === -1
            YIconButton {
                implicitWidth: 44
                implicitHeight: 44
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/report"
//                visible:{
//                    return feedbackeds.indexOf(getFeedbackCurrentKey()) === -1
//                }
                onValidClicked: {
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    jumpTofeedBack()
                }
            }
        }


    }

    YAISentenceDetailePage {
        id: id_sentence_detaile
        anchors.fill: parent
    }

    Connections{
        enabled: visible
        ignoreUnknownSignals: true
        target: funcFeedback
        onRequestResultCallBack:{
            if(responseJsonString === "0"){
//                resultManager.isReportButtonVisible = false
                baseSignals.showToast(YTranslateText.thxReport, "#2D2E33")
                if(feedbackeds.indexOf(getFeedbackCurrentKey()) === -1) feedbackeds += getFeedbackCurrentKey()
            }else
                baseSignals.showToast(YTranslateText.thxReportError, "#2D2E33")
        }
    }

}
