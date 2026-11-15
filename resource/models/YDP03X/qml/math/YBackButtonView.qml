import QtQuick 2.12
import BaseQml 1.0

YBackgroundIgnoreMouseEvent {
    id: id_back_button_view
    anchors.fill: parent
    property alias backBar: id_back_bar
    signal backButtonClicked()


    YVerticalTitleBar {
        id: id_back_bar
        onCallBack: {
            id_back_button_view.backButtonClicked()
        }
    }
}
