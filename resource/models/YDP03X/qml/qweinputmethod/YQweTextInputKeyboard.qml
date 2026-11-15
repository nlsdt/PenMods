import QtQuick 2.12

import BaseQml 1.0

Flickable {
    id: id_qwe_text_input_keyboard
    objectName: "YQweTextInputKeyboard.qml"
    contentHeight: id_keys_container.height
    clip: true

    property int currentKeyMode: YQweTextInputClikedKey.KeyMode.Lower

    signal keyPressed(string text)
    signal delPressed()
    signal delToStart()

    Column {
        id: id_keys_container
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 3
        Row {
            spacing: 3
            YQweTextInputClikedKey {
                textArray: ["q", "Q", "1"]
            }
            YQweTextInputClikedKey {
                textArray: ["w", "W", "2"]
            }
            YQweTextInputClikedKey {
                textArray: ["e", "E", "3"]
            }
            YQweTextInputClikedKey {
                textArray: ["r", "R", "4"]
            }
            YQweTextInputClikedKey {
                textArray: ["t", "T", "5"]
            }
            YQweTextInputClikedKey {
                textArray: ["y", "Y", "6"]
            }
            YQweTextInputClikedKey {
                textArray: ["u", "U", "7"]
            }
            YQweTextInputClikedKey {
                textArray: ["i", "I", "8"]
            }
            YQweTextInputClikedKey {
                textArray: ["o", "O", "9"]
            }
            YQweTextInputClikedKey {
                textArray: ["p", "P", "0"]
            }

            Item {
                implicitHeight: 62
                implicitWidth: 118

                YTimer {
                    id: id_del_delay_timer
                    interval: 100
                    repeat: id_del_button.pressed && id_del_button.mouseAreaItem.isPressAndHold
                    onTriggered: {
                        delPressed()
                    }
                }

                YIconButton {
                    id: id_del_button
                    radius: 14
                    implicitWidth: 116
                    implicitHeight: 62
                    anchors.right: parent.right
                    sourceSize: Qt.size(60, 60)
                    imageName: pressed ? "input/ic_delete_clicked"
                                       : "input/ic_delete"
                    onValidClicked: {
                        delPressed()
                    }
                    onPressAndHold: {
                        id_del_delay_timer.restart()
                    }
                }
            }
        }

        Row {
            spacing: 3
            Item { // spacing holder
                implicitHeight: 62
                implicitWidth: 47
            }
            YQweTextInputClikedKey {
                textArray: ["a", "A", "."]
            }
            YQweTextInputClikedKey {
                textArray: ["s", "S", ","]
            }
            YQweTextInputClikedKey {
                textArray: ["d", "D", "?"]
            }
            YQweTextInputClikedKey {
                textArray: ["f", "F", "!"]
            }
            YQweTextInputClikedKey {
                textArray: ["g", "G", "'"]
            }
            YQweTextInputClikedKey {
                textArray: ["h", "H", "-"]
            }
            YQweTextInputClikedKey {
                textArray: ["j", "J", "/"]
            }
            YQweTextInputClikedKey {
                textArray: ["k", "K", ":"]
            }
            YQweTextInputClikedKey {
                textArray: ["l", "L", ";"]
            }
            Item { // spacing holder
                implicitHeight: 62
                implicitWidth: 14
            }
            YIconButton {
                radius: 14
                implicitWidth: 116
                implicitHeight: 62
                sourceSize: YQweTextInputClikedKey.KeyMode.Symbol !== currentKeyMode
                            ? Qt.size(106, 60) : Qt.size(60, 60)
                imageName: YQweTextInputClikedKey.KeyMode.Symbol !== currentKeyMode
                           ? "input/switch_num_symbol"
                           : (id_case_switch_button.isChecked
                              ? "input/char_upper"
                              : "input/char_lower")
                onValidClicked: {
                    if (YQweTextInputClikedKey.KeyMode.Symbol !== currentKeyMode) {
                        currentKeyMode = YQweTextInputClikedKey.KeyMode.Symbol
                    } else {
                        if (id_case_switch_button.isChecked) {
                            currentKeyMode = YQweTextInputClikedKey.KeyMode.Upper
                        } else {
                            currentKeyMode = YQweTextInputClikedKey.KeyMode.Lower
                        }
                    }
                }
            }
        }

        Row {
            spacing: 3
            Item {
                implicitWidth: 70
                implicitHeight: 62
                YIconButton {
                    id: id_case_switch_button
                    radius: 14
                    implicitWidth: 70
                    implicitHeight: 62
                    sourceSize: Qt.size(60, 60)
                    color: isChecked ? "#E5E5E5" : YColors.grayNormal
                    imageName: isChecked ? "input/switch_lower"
                                         : "input/switch_upper"
                    visible: YQweTextInputClikedKey.KeyMode.Symbol !== currentKeyMode
                    property bool isChecked: false
                    onValidClicked: {
                        if (!isChecked) {
                            currentKeyMode = YQweTextInputClikedKey.KeyMode.Upper
                        } else {
                            currentKeyMode = YQweTextInputClikedKey.KeyMode.Lower
                        }
                        isChecked = !isChecked
                    }
                }
            }
            Item { // spacing holder
                implicitHeight: 62
                implicitWidth: 14
            }
            YQweTextInputClikedKey {
                textArray: ["z", "Z", "("]
            }
            YQweTextInputClikedKey {
                textArray: ["x", "X", ")"]
            }
            YQweTextInputClikedKey {
                textArray: ["c", "C", "$"]
            }
            YQweTextInputClikedKey {
                textArray: ["v", "V", "&"]
            }
            YQweTextInputClikedKey {
                textArray: ["b", "B", "@"]
            }
            YQweTextInputClikedKey {
                textArray: ["n", "N", "\""]
            }
            YQweTextInputClikedKey {
                textArray: ["m", "M", "["]
            }
            Item { // spacing holder
                implicitHeight: 62
                implicitWidth: 14
            }
            YIconButton {
                radius: 14
                implicitWidth: 206
                implicitHeight: 62
                sourceSize: Qt.size(60, 60)
                imageName: "input/ic_space"
                onValidClicked: {
                    keyPressed(" ")
                }
            }
        }

        Row {
            spacing: 3
            visible: YQweTextInputClikedKey.KeyMode.Symbol === currentKeyMode
            Item { // spacing holder
                implicitHeight: 62
                implicitWidth: 47
                visible: YQweTextInputClikedKey.KeyMode.Symbol === currentKeyMode
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "]"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "{"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "}"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "#"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "%"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "^"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "*"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "|"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "~"]
            }
        }

        Row {
            spacing: 3
            visible: YQweTextInputClikedKey.KeyMode.Symbol === currentKeyMode
            Item { // spacing holder
                implicitHeight: 62
                implicitWidth: 127
                visible: YQweTextInputClikedKey.KeyMode.Symbol === currentKeyMode
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "<"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", ">"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "¥"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "="]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "_"]
            }
            YQweTextInputClikedKey {
                textArray: ["", "", "\\"]
            }
        }

        YSpacingForColumn {
            implicitHeight: 21
        }
    }
}
