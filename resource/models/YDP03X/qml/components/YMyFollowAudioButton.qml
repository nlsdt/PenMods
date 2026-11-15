import QtQuick 2.0

Rectangle {
    width: 118
    height: 45
    color: "#43DCFF"
    radius: 16
    property alias myFollownabled: id_my_audio_pron.enabled
    property alias followEnable: id_my_audio_pron.enabled
    property bool isSentenceFollow: true
    YFollowAudioButton {
        id: id_my_audio_pron
        textFontFamily: fontManager.fontFamilyEnUs
        textFormat: YText.PlainText
        leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        radius: 12
        anchors.fill: parent
        color: "#46ABFD"
        textColor: "#FFFFFF"
        spacing: 0
        enabled: true
        pixelSize: 28
        text: " 我的"
        visible: true
        onValidClicked: {
            playJap()
        }
        function playJap(){
            console.log("seven:isSentenceFollow:1",isSentenceFollow)
            if(isSentenceFollow)
                playAudioFileData("/tmp/cursound")
            else
                playAudioFileData("/tmp/cursoundWord")
        }
    }
}
