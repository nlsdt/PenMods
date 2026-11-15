import QtQuick 2.12

import BaseQml 1.0
import "../components"

YTouchReadingViewDelegateBase {
    id: id_delegate_item_root
    implicitWidth: 160
    delegateItem: id_delegate_item

    signal clicked()

    YMouseArea {
        id: id_delegate_item_button
        anchors.fill: parent
        onClicked: {
            id_delegate_item_root.clicked()
        }
        objectName: "ContentMedalSetDetailItem.qml_id_store_series_delegate"
    }

    YImage {
        id: id_delegate_item
        width: 120
        height: 120
        anchors.horizontalCenter: parent.horizontalCenter
        source: model.modelData.isLighted ?
                    model.modelData.lightedMedalRoundLocal.toLoadFileUrl() :
                    model.modelData.darkMedalRoundLocal.toLoadFileUrl()
    }

    Component.onCompleted: {
        console.log("ZDS===test===isLighted: ", model.modelData.isLighted)
        console.log("ZDS===test===lightedMedalRoundLocal: ", model.modelData.lightedMedalRoundLocal)
        console.log("ZDS===test===darkMedalRoundLocal: ", model.modelData.darkMedalRoundLocal)
    }
}
