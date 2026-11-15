import QtQuick 2.12

import BaseQml 1.0

YIconButton {
    id: id_filter_button
    opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
    implicitWidth: 44
    implicitHeight: 44
    radius: height/2
    mouseAreaMargins: -25
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 18
    sourceSize: Qt.size(36, 36)
    asynchronous: false
    imageName: "article/filter"
    onValidClicked: {
        logManager.sendHttpLog("action=essay_change_level")
        showArticleLevelSelectedFilter()
    }

    function showArticleLevelSelectedFilter() {
        function newComponentInit(incubatorObject) {
            incubatorObject.backButtonClicked.connect(incubatorObject.destroy)
            systemBase.homeKeyPress.connect(incubatorObject.destroy)
            systemBase.ocrStart.connect(incubatorObject.destroy)
            systemBase.isOidStart.connect(incubatorObject.destroy)
            incubatorObject.show()
        }

        const newComponent = Qt.createComponent(
                               "./YArticleLevelSelectedFilter.qml")
        const incubator = newComponent.incubateObject(
                            id_filter_button.parent)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --filterIncubatorCreateCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++filterIncubatorCreateCount
        } else {
            newComponentInit(incubator.object)
        }
    }

    property int filterIncubatorCreateCount: 0
    property int incubatorCreateCount: 0
    property int incubatorCreateArticlNeedNetWorkCount: 0
    property int incubatorCreateHistoryCount: 0
    property int incubatorCreateFinishedCount: 0
    property int incubatorCreateCorrectionsCompletedCount: 0
    property int incubatorCreateFirstEnterTipCount: 0
}
