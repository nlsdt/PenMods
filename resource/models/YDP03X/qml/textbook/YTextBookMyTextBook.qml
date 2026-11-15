import QtQuick 2.12
import QtGraphicalEffects 1.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_textbook_my_textbook_page_root
    anchors.fill: parent

    property int checkedIndex: -1
    property bool isFirstSelect: settingManager.defaultGradeId.length <= 0

    // 半透明遮罩
    Item {
        id: id_effect_item
        implicitWidth: 80
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: id_my_textbook_content_loader.z + 1

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: (!isFirstSelect && id_my_textbook_content_loader.isLoaded)
                        ? id_my_textbook_content_loader.item : null
            sourceRect: Qt.rect(x - 90, y - 16, width, height)
        }

        FastBlur {
            anchors.fill: parent
            source: id_effect_source
            radius: 32
        }

        Rectangle {
            anchors.fill: parent
            color: "#4D000000"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }

    YVerticalTitleBar {
        z: id_effect_item.z + 1
        onCallBack: {
            textBookManager.wipeData()
            id_textbook_page.subPageCallBack()
        }
        objectName: "YBackButtonPage.qml_" + id_textbook_my_textbook_page_root.objectName

    }

    YLoader {
        id: id_my_textbook_content_loader
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        active: true
        asynchronous: false
        sourceComponent: {
            return id_textbook_block_list_component
        }

        Component {
            id: id_textbook_block_list_component

            YHorizontalListView {
                id: id_textbook_listview
                anchors.fill: parent
                anchors.topMargin: 16
                anchors.bottomMargin: 16
                spacing: 12
                rightMargin: 12
                model: textBookManager
                cacheBuffer: 5000
                clip: false
                interactive: -1 === checkedIndex
                opacity: (checkedIndex !== -1) ? 0 : 1
                visible: opacity > 0.1

                onCountChanged: {
                    console.log("YTextBookMyTextBook.qml_textbooklistview===count===", count)
                }

                onMovingChanged: {
                    if (!moving && atYEnd && textBookManager.hasMore) {
                        textBookManager.loadMore(true)
                    }
                }

                delegate: YHorizontalListViewDelegate {
                    id: id_my_textbook_delegate_item
                    width: 154
                    height: id_textbook_listview.height
                    objectName: "YTextBookMyTextBook.qml_mytextbookdelegateitem_index" + index

                    Item {
                        id: id_textbook_delegate_item_root
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 222
                        opacity: id_clickabled_button.pressed || !enabled ? 0.6 : 1

                        Image {
                            id: _image
                            readonly property string iconSource: qmlGlobal.fileExists(model.modelData.icon) ? model.modelData.icon.toLoadFileUrl()
                                                                                                               : "image://icons/textbook/book_default.png"

                            smooth: true
                            visible: true
                            anchors.fill: parent
                            source: iconSource
                            sourceSize: Qt.size(parent.width, parent.height)
                            antialiasing: true

//                            Rectangle {
//                                width: parent.width
//                                height: 52
//                                anchors.bottom: parent.bottom
//                                color: "#000000"
//                                opacity: 0.5
//                                visible:  (settingManager.studyingBookId === model.modelData.bookId) || model.modelData.isExpirated
//                            }
                        }
                        YBlurMaskRectangle {
                            width: parent.width
                            height: 52
                            anchors.bottom: parent.bottom
                            id: id_blur_mask_rectangle
                            sourceItem: parent
                            sourceRect: Qt.rect(parent.x, parent.y + 162, width, 60)
                            radius: 14
                            visible:  (settingManager.studyingBookId === model.modelData.bookId) || model.modelData.isExpirated
                            Rectangle {
                                anchors.fill: parent
                                color: "#000000"
                                opacity: 0.14
                            }
                        }
//                        OpacityMask {
//                            id: mask_image
//                            anchors.fill: _image
//                            source: _image
//                            maskSource: parent
//                            visible: true
//                            antialiasing: true
//                        }

                        YShadowText {
                            id: id_item_publisher
                            anchors.top: parent.top
                            anchors.topMargin: 30
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            width: 130
                            maximumLineCount: 2
                            font.pixelSize: 14
                            font.family: fontManager.fontFamilyZhCn
                            text: model.modelData.publisher
                            wrapMode: YText.WrapAnywhere
                            elide: YText.ElideRight
                            visible: _image.iconSource.indexOf("book_default.png") > 0
                        }

                        YText {
                            id: id_item_title
                            anchors.top: id_item_publisher.bottom
                            anchors.topMargin: 8
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            width: id_item_publisher.width
                            height: 22
                            font.pixelSize: 18
                            font.family: fontManager.fontFamilyZhCn
                            text: model.modelData.title
                            elide: YText.ElideRight
                            visible: _image.iconSource.indexOf("book_default.png") > 0
                        }


                        Item {
                            width: parent.width
                            height: 52
                            anchors.bottom: parent.bottom

                            YTextMedium {
                                id: id_item_bottom_expiration_text
                                color: YColors.white
                                width: contentWidth
                                height: contentHeight
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: 22
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.bold: true
                                text:{
                                    if(settingManager.studyingBookId === model.modelData.bookId)
                                        return YTranslateText.textbookStudying
                                    if(model.modelData.isExpirated)
                                        return YTranslateText.textbookExpired

                                    return ""
                                }
                            }
                        }

                        YMouseArea {
                            id: id_clickabled_button
                            anchors.fill: parent
                            anchors.margins: -28
                            onClicked: {
                                id_textbook_page.selectTextbookObj = model.modelData
                                showSubPage(YEnum.Textbook_Operation, true)
                            }
                            objectName: "YTextBookMyTextBook.qml_textbookdelegateitem_index" + index
                        }
                    } //  Rectangle
                }

                footer: Item {
                    width: 154 + 12
                    height: 222

                    YImageButton {
                        id: id_textbook_select_item
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        imageName: "textbook/add"
                        mouseAreaMargins: -20
                        onClicked: {
                            id_textbook_page.selectTextbookObj = model.modelData
                            showSubPage(YEnum.Textbook_Select, true)
                            console.log("YTextBookMyTextBook.qml_footer.onClicked")
                        }
                    }
                } // footer Item
            } // YHorizontalListView
        } // Component

        Component.onCompleted: {
            textBookManager.wipeData()
            textBookManager.loadMore(true)
        }
    }

}
