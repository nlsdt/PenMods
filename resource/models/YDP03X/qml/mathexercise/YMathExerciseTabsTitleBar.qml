import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../commons"

Item {
    implicitHeight: 68
    implicitWidth: 690
    property int currentIndex: 0
    property var namesArray: null

    signal showIntroduction()

    Row {
        id: id_tab_title_row
        spacing: 50
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 30
        height: 34

        Repeater {
            id: id_repeater
            model: namesArray

            YTextBase {
                font.pixelSize: 26
                color: index === currentIndex ? YColors.white : "#A8AAB2"
                text: model.modelData
                height: 34
                width: paintedWidth
                verticalAlignment: YTextBase.AlignVCenter
                opacity: id_tab_ma.pressed ? 0.6 : 1
                font.bold: index === currentIndex

                YMouseArea {
                    id: id_tab_ma
                    anchors.fill: parent
                    onClicked: {
                        currentIndex = index
                    }
                    objectName: "YMathExerciseTabsTitleBar.qml_id_tab_title_row"
                }
            }
        }
    }

    YIconButton {
        id: id_guide_button_bg
        color: "transparent"
        implicitWidth: 36
        implicitHeight: 36
        mouseAreaMargins: -20
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.top: parent.top
        anchors.topMargin: 20
        sourceSize: Qt.size(36, 36)
        imageName: "math/exercise-guide"
        onClicked: {
            showIntroduction()
        }
    }
}
