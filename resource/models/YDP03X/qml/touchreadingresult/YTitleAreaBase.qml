import QtQuick 2.12

import BaseQml 1.0
import "../components"

YSpacing {
    id: id_title_area
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    implicitHeight: 76

    property alias backButtonVisible: id_back_button_loader.active
    signal callBack()

    YLoader {
        id: id_back_button_loader
        active: true
        sourceComponent: YTouchReadingModuleBackButton {
            onClicked: {
                callBack()
            }
        }
    }
}

