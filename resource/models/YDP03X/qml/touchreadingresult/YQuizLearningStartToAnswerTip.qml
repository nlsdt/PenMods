import QtQuick 2.12

import BaseQml 1.0

Item {

    signal startToAnswer()

    property alias text: id_start_to_answer_questions_button.text

    YButton {
        id: id_start_to_answer_questions_button
        implicitWidth: 226
        anchors.top: parent.top
        anchors.topMargin: 158
        anchors.horizontalCenter: parent.horizontalCenter
        text: "进入闯关"
        color: YColors.highlight
        onClicked: {
            startToAnswer()
        }
    }

    YImage {
        width: 250
        height: 145
        anchors.top: parent.top
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize: Qt.size(250, 145)
        imageName: "touchreading/start_answer"
    }
}
