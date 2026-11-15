import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
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
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 26
        color: "transparent"
        Text {
            text: getOverallTitle(followOverall)
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
        width: 174
        height: 174
        medal_width: 230
        mdeal_height: 230
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 65
        mdeal_title_font: 70
        mdeal_title_v_ofset: 10
        mdeal_img_v_ofset: -5
        mdeal_title_text: followOverall
    }
    function setSpeelResultData(overall, isAutoClose){

        followOverall = overall
        autoClose = isAutoClose
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
