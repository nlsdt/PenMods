import QtQuick 2.12
import BaseQml 1.0

YMouseArea {
    implicitWidth: 164
    implicitHeight: 164
    enabled: selectabled && (0 === answerResult.length)
    objectName: "YAnswerQuestionOptionItem.qml===YMouseArea"
    readonly property string answerContentGroup: model.modelData.option_image + model.modelData.option_text
    readonly property bool answerCompleted: selectedAnswerContentGroup === answerContentGroup
    default property alias content: id_container.data

    readonly property alias backgroundItem: id_bg
    property bool backgroundColorChangedAfterAnswered: true

    onClicked: {
        answerResult = model.modelData.option_isTrue
        selectedAnswerContentGroup = answerContentGroup
        selectedResult()
    }

    Rectangle {
        id: id_bg
        anchors.fill: parent
        color: {
            if (backgroundColorChangedAfterAnswered && answerCompleted) {
                return "y" === answerResult ? "#0073FF" : "#FF6D12"
            }
            return "#292A51"
        }
        radius: 20
    }

    Item {
        id: id_container
        anchors.fill: parent
    }
}
