import QtQuick 2.12

import BaseQml 1.0

YTitleAreaBase {
    id: id_title_area

    signal validClicked()
    signal speekerCurrentFrameChanged()

    readonly property alias progressIndicator: id_progress_indicator
    readonly property alias progressIndicatorBackground: id_progress_indicator_bg
    readonly property alias listennigButton: id_listennig_button

    property alias currentIndex: id_progress_indicator.currentIndex
    property alias isBrowseMode: id_progress_indicator.isBrowseMode
    property alias listennigButtonVisible: id_listennig_button.visible

    function play() {
        id_listennig_button.play()
    }

    function stopPlay() {
        id_listennig_button.stopPlay()
    }

    YProgressIndicatorBackground {
        id: id_progress_indicator_bg
        width: id_progress_indicator.width + 56
        YInteractiveQuizzesProgressIndicator {
            id: id_progress_indicator
        }
    }

    YListennigButton {
        id: id_listennig_button
        onCurrentFrameChanged: {
            speekerCurrentFrameChanged()
        }
        onValidClicked: {
            id_title_area.validClicked()
        }
    }
}

