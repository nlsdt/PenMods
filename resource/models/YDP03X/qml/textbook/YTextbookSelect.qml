import QtQuick 2.12
import QtGraphicalEffects 1.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"

Item {
    id: id_textbook_select_item
    objectName: "YTextBookSelect.qml"
    anchors.fill: parent
    property int checkedIndex: -1

    Item {
        id: id_effect_item
        implicitWidth: 80
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: id_textbook_select_content_loader.z + 1

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: (!id_textbook_page.isFirstSelect && id_textbook_select_content_loader.isLoaded)
                        ? id_textbook_select_content_loader.item : null
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
        enabled: id_grade_select_drawer_layer.state === "hide"
        z: id_effect_item.z + 1
        iconButtonBackgroundItem.icon: id_textbook_page.isFirstSelect ? "commons/close" : "ic_back"
        onCallBack: {
            if (id_textbook_page.isFirstSelect) {
                id_textbook_page.subPageCallBack()
            } else {
                id_textbook_page.isFirstSelect = true
            }
        }
        objectName: "YBackButtonPage.qml_" + id_textbook_select_item.objectName

        Item {
            id: id_check_select_button
            width: 80
            height: 62
            anchors.bottom: parent.bottom
            enabled: id_textbook_select_content_loader.isLoaded
                     && !(id_textbook_page.isFirstSelect && id_textbook_select_content_loader.item.selectedGrade.length <= 0)
            opacity: !enabled ? 0.6 : 1

            YIconButton {
                implicitWidth: 44
                implicitHeight: 44
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 22
                icon: id_textbook_page.isFirstSelect ? "textbook/select-check" : "commons/more"
                iconSourceSize: Qt.size(36, 36)
            }

            YMouseArea {
                anchors.fill: parent
                anchors.bottomMargin: -18

                onClicked: {
                    if (id_textbook_page.isFirstSelect) {
                        let qsSelectedGrade = id_textbook_select_content_loader.item.selectedGrade
                        if (qsSelectedGrade.startsWith("primary")) {
                            logManager.sendHttpLog("action=textbook_primary_click")
                        } else if (qsSelectedGrade.startsWith("middle")) {
                            logManager.sendHttpLog("action=textbook_junior_click")
                        } else if (qsSelectedGrade.startsWith("high")) {
                            logManager.sendHttpLog("action=textbook_senior_click")
                        }
                        logManager.sendHttpLog("action=textbook_show")
                        textBookManager.setDefaultGrade(qsSelectedGrade)
                        textBookManager.reload()
                        id_textbook_page.isFirstSelect = false
                    } else {
                        id_grade_select_drawer_layer.show()
                    }
                }
            }
        }
    }

    YLoader {
        id: id_textbook_select_content_loader
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        active: true
        asynchronous: false
        sourceComponent: {
            if (id_textbook_page.isFirstSelect) {
                return id_select_stage_grade_component
            } else {
                return id_textbook_block_list_component
            }
        }

        Component {
            id: id_select_stage_grade_component
            YTextbookSelectStageAndGrade {
                bigButton: true
            }
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
                    console.log("YTextbookSelect.qml_textbooklistview===count===", count)
                }

                onMovingChanged: {
                    if (!moving && atYEnd && textBookManager.hasMore) {
                        textBookManager.loadMore()
                    }
                }

                delegate: YHorizontalListViewDelegate {
                    id: id_textbook_delegate_item
                    width: 154
                    height: id_textbook_listview.height
                    objectName: "YTextbookSelect.qml_textbookdelegateitem_index" + index

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
                        }
                        OpacityMask {
                            id: mask_image
                            anchors.fill: _image
                            source: _image
                            maskSource: parent
                            visible: true
                            antialiasing: true
                        }

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

                        YMouseArea {
                            id: id_clickabled_button
                            anchors.fill: parent
                            anchors.margins: -28
                            onClicked: {
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked gradeId:", model.modelData.gradeId)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked bookId:", model.modelData.bookId)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked title:", model.modelData.title)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked fullTitle:", model.modelData.fullTitle)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked subject:", model.modelData.subject)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked publisher:", model.modelData.publisher)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked price:", model.modelData.price)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked priceBrief:", model.modelData.priceBrief)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked isBought:", model.modelData.isBought)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked expiration:", model.modelData.expiration)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked activeCode:", model.modelData.activeCode)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked url:", model.modelData.url)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked localFile:", model.modelData.localFile)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked localFileMd5:", model.modelData.localFileMd5)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked version:", model.modelData.version)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked coverUrl:", model.modelData.coverUrl)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked icon:", model.modelData.icon)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked publishTime:", model.modelData.publishTime)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked progress:", model.modelData.progress)
                                //console.log("YTextbookSelect.qml_textbookdelegateitem.onClicked downloadState:", model.modelData.downloadState)

                                textBookManager.queryBookPrice(model.modelData.bookId)
                                id_textbook_page.selectTextbookObj = model.modelData
                                showSubPage(YEnum.Textbook_Operation, true)
                            }
                            objectName: "YTextbookSelect.qml_textbookdelegateitem_index" + index
                        }
                    }
                }

                footer: (textBookManager.itemCount > 0 && textBookManager.hasMore)
                        ? id_listview_loading_footer : null

                Component {
                    id: id_listview_loading_footer

                    YListViewLoadMoreFooter {}
                }
            }
        }
    }

    YDrawerLayer {
        id: id_grade_select_drawer_layer
        //visible: !isDownloadManagerView
        indicatorLeftMargin: 16
        indicatorRightMargin: 50
        drawerContainerRightMargin: 30
        containerWidth: 558
        z: id_textbook_select_content_loader.z + 1

        YLoader {
            anchors.fill: parent
            active: !id_textbook_page.isFirstSelect
            asynchronous: false
            sourceComponent: YTextbookSelectStageAndGrade {
                id: id_textbook_select_grade
                bigButton: false
                onSelectedGradeChanged: {
                    if (selectedGrade.length > 0 && id_grade_select_drawer_layer.state === "show") {
                        logManager.sendHttpLog("action=textbook_show")
                        textBookManager.setDefaultGrade(selectedGrade)
                        textBookManager.reload()
                    }
                }
            }
        }
    }
}

