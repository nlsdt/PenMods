import QtQuick 2.12
import com.youdao.pen 1.0

Item {
    id: id_result_view
    objectName: "YInteractiveQuizzesResultView.qml"
    anchors.fill: parent

    property int lastSelectedIndex: 0

    signal endPlay()

    Component {
        id: id_result_right_tip_component
        YInteractiveQuizzesResultRight {
            onBackButtonClicked: {
                id_result_view.endPlay()
            }
        }
    }

    function requestRightTips() {
        requestResultTips(true)
    }

    Component {
        id: id_result_wrong_tip_component
        YInteractiveQuizzesResultWrong {
            onBackButtonClicked: {
                id_result_view.endPlay()
            }
        }
    }

    function requestWrongTips() {
        requestResultTips(false)
    }

    property int incubatorCreateCount: 0
    function requestResultTips(isRight) {
        function newComponentInit(incubatorObject) {
            incubatorObject.backButtonClicked.connect(incubatorObject.destroy)
            systemBase.homeKeyRelease.connect(incubatorObject.destroy)
            systemBase.homeKeyLongPress.connect(incubatorObject.destroy)
            incubatorObject.play()
        }

        let incubator
        if (isRight) {
            incubator = id_result_right_tip_component.incubateObject(
                                id_result_view)
        } else {
            incubator = id_result_wrong_tip_component.incubateObject(
                                id_result_view)
        }

        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateCount) {
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        } else {
            newComponentInit(incubator.object)
        }
    }
}
