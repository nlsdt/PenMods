import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YDialog {
    id: id_label_edit_item
    anchors.fill: parent

    signal submit(var value)

    property int currentCheckedCount: 0

    property var labelArry: [
        YTranslateText.becauseKnowledge,
        YTranslateText.becauseCareless,
        YTranslateText.becauseThink,
        YTranslateText.becauseUnderstand,
        YTranslateText.becauseAgain
    ]

    function submitLabels() {
        var arry = []
        arry = requestLabelsRecord()
        submit(arry)
//        mathExerciseManager.addToFavorites(arry)
    }

    function requestLabelsRecord() {
        var labelsRecordArr = []
        for (var i = 0; i < check_box_repeater.count; i++) {
            if (check_box_repeater.itemAt(i).checked) {
                var content = check_box_repeater.itemAt(i).title
                labelsRecordArr.push(content)
            }
        }
        return labelsRecordArr
    }

    function clearLabelRecord() {
        for (var i = 0; i < check_box_repeater.count; i++) {
            check_box_repeater.itemAt(i).checked = false
        }
        updateDoneEnabled()
    }

    function updateDoneEnabled(){
        currentCheckedCount = requestLabelsRecord().length
    }


    Item {
        id: id_label_select_container
        anchors.fill: parent
        anchors.leftMargin: 30

        YText{
            id: id_label_select_title
            anchors.top: parent.top
            anchors.topMargin: 24
            height: 34
            text: YTranslateText.labelsSelect
            color: "#A8AAB2"
            font.pixelSize: 26
            verticalAlignment: Text.AlignVCenter
        }

        YTextBase {
            id: id_confirm_label
            color: YColors.blueText
            font.pixelSize: 24
            anchors.top: parent.top
            anchors.topMargin: 27
            anchors.left: parent.left
            anchors.leftMargin: 702
            text: YTranslateText.confirm
            width: paintedWidth
            height: paintedHeight
            opacity: id_confirm_label_button.pressed ? 0.6 : 1

            YMouseArea {
                id: id_confirm_label_button
                anchors.centerIn: parent
                width: 48 + 40
                height: 28 + 40
                onClicked: {
                    submitLabels()
                }
                objectName: "YMouseArea_id_confirm_label_button"
            }
        }

        Flow {
            anchors.top: id_label_select_title.bottom
            anchors.topMargin: 34
            width: parent.width
            spacing: 40
            Repeater {
                id: check_box_repeater
                model: labelArry

                Item {
                    property alias checked: id_check_box.checked
                    property string title: id_check_box.title
                    width: id_check_box.width + 30
                    height: id_check_box.height

                    YCheckBox {
                        id: id_check_box
                        title: model.modelData
                        checked: false
                        enabled: checked || (currentCheckedCount < 4)
                        onClicked: {
                            updateDoneEnabled()
                        }
                    }

                    YMouseArea {
                        anchors.fill: parent
                        enabled: !id_check_box.enabled

                        onClicked: {
                            baseSignals.showToast(YTranslateText.labelsCountTip, "#CC2D2E33")
                        }
                    }
                }

            }
        }
    }

}
