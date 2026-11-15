import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../components"
import "../i18n"
YPage {
    anchors.fill: parent
    property int followOverall: 0
    property bool autoClose: false
    function getOverallTitle(overall){
        if(overall < 60)
            return "还要继续努力哦！"
        else if(overall >= 60 && overall <70)
            return "你可以做得更好！"
        else if(overall >= 70 && overall < 80){
            return "表现不错，加油！"
        }else if(overall >= 80 && overall < 90)
            return "发音真棒，点赞！"
        else if(overall >= 90)
            return "发音堪比播音员，太厉害了！"
    }


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
        visible: !autoClose
        onClicked: {
            backButtonClicked()
        }
    }

    Rectangle {
        width: 249
        height: 35
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 130
        anchors.topMargin: 26
        color: "transparent"

        Text {
            text: getOverallTitle(followOverall)//"发音真棒，点赞 ！"
            anchors.fill: parent
            style: Text.Outline
            styleColor: "#1B79AB"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment  : Text.AlignHCenter
            font.bold: true
            font.pixelSize: 30
            font.family: "Poppins"
            color: "#FFFFFF"
        }
    }

    YFollowMedalButton {
        id: id_followMedalButton
        width: 174
        height: 174
        medal_width: 230
        mdeal_height: 230
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 168
        anchors.topMargin: 65
        mdeal_title_font: 70
        mdeal_title_v_ofset: 10
        mdeal_img_v_ofset: -5
        mdeal_title_text: followOverall
        visible: false
    }

    ListModel {
        id: id_factors_list_model
    }


    Column{
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.leftMargin: 441
        anchors.topMargin: 21
        spacing: 14
        Repeater {
            model: id_factors_list_model
            width: parent.width
            Column {
                width: parent.width
                Rectangle {
                    width: 197
                    height: 60
                    anchors.right: parent.right
                    anchors.rightMargin: l_Margin
                    color: "transparent"
                    radius: 12
                    clip: true
                    Rectangle{
                        anchors.fill: parent
                        color: "#43DCFF"
                        radius: 12
                        opacity: 0.1
                    }
                    Text {
                        id: id_title
                        text:title
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.leftMargin: 30
                        anchors.rightMargin: 71
                        anchors.topMargin: 14
                        anchors.bottomMargin: 14
                        font.pixelSize: 24
                        font.family: "OPPOSans"
                        color: "#89D6FF"
                    }

                    Text {
                        id: id_score
                        text:socre
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.leftMargin: 126
                        anchors.rightMargin: 30
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        font.pixelSize: 30
                        font.bold: true
                        font.family: "OPPOSans"
                        color: "#FFFFFF"
                    }

                }
            }
        }
    }

    function setSpeelResultData(fluency, integrity, overall, pronunciation,isAutoClose){
        id_factors_list_model.append({
                                         "l_Margin" : 102,
                                         "title" : "完整度：",
                                         "socre" : integrity
                                     })
        id_factors_list_model.append({
                                         "l_Margin" : 132,
                                         "title" : "准确度：",
                                         "socre" : pronunciation
                                     })
        id_factors_list_model.append({
                                         "l_Margin" : 162,
                                         "title" : "流利度：",
                                         "socre" : fluency
                                     })
        followOverall = overall
        autoClose = isAutoClose
        id_followMedalButton.visible = true
        if(autoClose){
            id_countDown.start()
        }
    }

    Timer {
        id:id_countDown;
        interval: 3000
        repeat: false
        onTriggered: {
            backButtonClicked()
            stop()
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        //enabled: id_dict_page.visible
        function onOcrStart() {
//            back()
        }
        function onOcrStop(scanType) {
            backButtonClicked()
        }
        function onHomeKeyPress() {
            backButtonClicked()
        }
    }
}
