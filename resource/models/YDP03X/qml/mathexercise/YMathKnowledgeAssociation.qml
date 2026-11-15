import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../i18n"

Item {
    id: id_knowledges_association_item
    anchors.top: parent.top
    anchors.topMargin: 2
    width: 694
    height: id_association_item_col.height
    property alias title: id_content_title.text
    property bool lineVisible: true

    property var currentName: null
    property var parentsModel: null
    property var childrenModel: null

    property int maxCount: Math.max(parentsModel.length, childrenModel.length)
    property int treeHeight: (maxCount % 2 === 1) ? 150 * maxCount
                                                  : 150 * (maxCount + 1)

    Column {
        id: id_association_item_col
        width: parent.width
        spacing: 0

        Row {
            id: id_title_row
            height: 34
            spacing: 8

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 20
                radius: 2
                color: "#F03043"
            }

            YTextBase {
                id: id_content_title
                font.pixelSize: 26
                color: "#A8AAB2"
                height: contentHeight
            }
        }

        YSpacingForColumn {
            implicitHeight: 12
        }

        Row {
            id: id_tree_row
            height: treeHeight
            spacing: -50

            Column {
                id: id_parents_col
                anchors.verticalCenter: parentsModel.length === maxCount ? parent.verticalCenter : id_center_rect.verticalCenter
                anchors.verticalCenterOffset: (parentsModel.length % 2 === 0)
                                              ? (parentsModel.length === maxCount ? -75 : 80)
                                              : 5
                visible: parentsModel.length > 0

                width: 280
                spacing: 0

                Repeater {
                    id: id_parents_repetater
                    model: id_knowledges_association_item.parentsModel
                    property int centerIndex: (count - 1) / 2

                    Item {
                        width: 280
                        height: 150
                        property bool isCenter: id_parents_repetater.centerIndex === index
                        property bool up: index < id_parents_repetater.centerIndex
                        property bool isNext: Math.abs(index - id_parents_repetater.centerIndex) === 1

                        Rectangle {
                            id: id_parent_repeater_rect
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: 200
                            height: 140
                            radius: 20
                            color: "#1A1B1F"

                            YText {
                                anchors.left: parent.left
                                anchors.leftMargin: 18
                                anchors.right: parent.right
                                anchors.rightMargin: 18
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment : YText.AlignHCenter
                                verticalAlignment: YText.AlignVCenter
                                maximumLineCount: 3
                                wrapMode: YText.WordWrap
                                elide: Text.ElideRight
                                font.pixelSize: 26
                                text: model.modelData.knowName
                            }

                            YMouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mathExerciseManager.queryKnowledge(model.modelData.knowId, true)
                                }
                            }
                        }

                        YImage {
                            width: 25
                            height: 3
                            anchors.left: id_parent_repeater_rect.right
                            anchors.verticalCenter: id_parent_repeater_rect.verticalCenter
                            sourceSize: Qt.size(25, 3)
                            imageName: "math/ic-horizontal-line"
                            visible: isCenter
                        }

                        YImage {
                            width: 81
                            height: 83
                            anchors.left: id_parent_repeater_rect.right
                            anchors.top: parent.top
                            anchors.topMargin: up ? 65 : -8
                            sourceSize: Qt.size(81, 83)
                            imageName: up ? "math/ic-right-down-line" : "math/ic-right-up-line"
                            visible: !isCenter && isNext
                        }

                        YImage {
                            width: 81
                            height: 168
                            anchors.left: id_parent_repeater_rect.right
                            anchors.top: parent.top
                            anchors.topMargin: up ? 70 : -98
                            sourceSize: Qt.size(81, 168)
                            imageName: up ? "math/ic-right-down-line-long" : "math/ic-right-up-line-long"
                            visible: (!isCenter) && (!isNext)
                        }

                        YImage {
                            width: 11
                            height: 14
                            anchors.left: id_parent_repeater_rect.right
                            anchors.leftMargin: 19
                            anchors.verticalCenter: id_parent_repeater_rect.verticalCenter
                            sourceSize: Qt.size(11, 14)
                            imageName: "math/ic-right-arrow"
                            visible: isCenter
                        }

                        YImage {
                            width: 14
                            height: 11
                            anchors.right: parent.right
                            anchors.rightMargin: -7
                            anchors.top: parent.top
                            anchors.topMargin: up ? 137 : -8
                            sourceSize: Qt.size(14, 11)
                            imageName: up ? "math/ic-down-arrow" : "math/ic-up-arrow"
                            visible: !isCenter && isNext
                        }
                    }
                }
            }

            YImage {
                id: id_center_rect
                width: 174
                height: 144
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: (maxCount % 2 === 0) ? -155 : 0
                sourceSize: Qt.size(174, 144)
                imageName: "math/ic_center_border"

                YText {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment : YText.AlignHCenter
                    verticalAlignment: YText.AlignVCenter
                    maximumLineCount: 3
                    wrapMode: YText.WordWrap
                    elide: Text.ElideRight
                    font.pixelSize: 26
                    text: currentName
                }
            }

            Column {
                anchors.verticalCenter: childrenModel.length === maxCount ? parent.verticalCenter : id_center_rect.verticalCenter
                visible: childrenModel.length > 0
                anchors.verticalCenterOffset: (childrenModel.length % 2 === 0)
                                              ? (childrenModel.length === maxCount ? -75 : 80)
                                              : 5

                width: 200
                spacing: 0

                Repeater {
                    id: id_children_repetater
                    model: id_knowledges_association_item.childrenModel
                    property int centerIndex: (count - 1) / 2

                    Item {
                        width: 280
                        height: 150
                        property bool isCenter: id_children_repetater.centerIndex === index
                        property bool up: index < id_children_repetater.centerIndex
                        property bool isNext: Math.abs(index - id_children_repetater.centerIndex) === 1

                        Rectangle {
                            id: id_child_repeater_rect
                            anchors.top: parent.top
                            anchors.right: parent.right
                            width: 200
                            height: 140
                            radius: 20
                            color: "#1A1B1F"

                            YText {
                                anchors.left: parent.left
                                anchors.leftMargin: 18
                                anchors.right: parent.right
                                anchors.rightMargin: 18
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment : YText.AlignHCenter
                                verticalAlignment: YText.AlignVCenter
                                maximumLineCount: 3
                                wrapMode: YText.WordWrap
                                elide: Text.ElideRight
                                font.pixelSize: 26
                                text: model.modelData.knowName
                            }

                            YMouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mathExerciseManager.queryKnowledge(model.modelData.knowId, true)
                                }
                            }
                        }

                        YImage {
                            width: 25
                            height: 3
                            anchors.right: id_child_repeater_rect.left
                            anchors.rightMargin: 5
                            anchors.verticalCenter: id_child_repeater_rect.verticalCenter
                            sourceSize: Qt.size(25, 3)
                            imageName: "math/ic-horizontal-line"
                            visible: isCenter
                        }

                        YImage {
                            width: 81
                            height: 83
                            anchors.right: id_child_repeater_rect.left
                            anchors.top: parent.top
                            anchors.topMargin: up ? 65 : -8
                            sourceSize: Qt.size(81, 83)
                            imageName: up ? "math/ic-up-right-line" : "math/ic-down-right-line"
                            visible: !isCenter && isNext
                        }

                        YImage {
                            width: 81
                            height: 168
                            anchors.right: id_child_repeater_rect.left
                            anchors.top: parent.top
                            anchors.topMargin: up ? 69 : -98
                            sourceSize: Qt.size(81, 168)
                            imageName: up ? "math/ic-up-right-line-long" : "math/ic-down-right-line-long"
                            visible: (!isCenter) && (!isNext)
                        }

                        YImage {
                            width: 11
                            height: 14
                            anchors.right: id_child_repeater_rect.left
                            anchors.verticalCenter: id_child_repeater_rect.verticalCenter
                            anchors.verticalCenterOffset: isNext ? (up ? -3 : 3) : 0
                            sourceSize: Qt.size(11, 14)
                            imageName: "math/ic-right-arrow"
                        }
                    }
                }
            }
        }
    }
}
