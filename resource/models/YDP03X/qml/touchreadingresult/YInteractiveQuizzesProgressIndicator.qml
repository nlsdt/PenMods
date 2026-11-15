import QtQuick 2.12

Row {
    id: id_progress_indicator
    spacing: 6
    height: 16
    anchors.centerIn: parent

    property bool isBrowseMode: false

    property int totalCount: 5

    function putResult(index, result, selectedAnswerContentGroup) {
        let resultObject = id_progress_list_model.get(index)
        resultObject.selectedAnswerContentGroup = selectedAnswerContentGroup
        resultObject.result = result
    }

    function getResultObject(index) {
        return id_progress_list_model.get(index)
    }

    property int currentIndex: 0

    function reset() {
        id_progress_list_model.reset()
    }

    onTotalCountChanged: {
        reset()
    }

    ListModel {
        id: id_progress_list_model

        function reset() {
            clear()
            for (let i=0; i<totalCount; ++i) {
                append({"result": "", "selectedAnswerContentGroup": ""})
            }
        }

        Component.onCompleted: {
            reset()
        }
    }

    Repeater {
        id: id_progress_repeater
        model: id_progress_list_model
        Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            radius: height/2
            smooth: true
            color: {
                switch (result) {
                case "y":
                    return "#2295FF"
                case "n":
                    return "#FF5847"
                default:
                    return "#1FFFFFFF"
                }
            }

            Rectangle {
                implicitWidth: 18
                implicitHeight: 18
                anchors.centerIn: parent
                color: "transparent"
                radius: height/2
                border.color: "#FFFFFF"
                border.width: 2
                visible: isBrowseMode && (index === currentIndex)
            }
        }
    }
}
