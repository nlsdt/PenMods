import QtQuick 2.12
import QtGraphicalEffects 1.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_textbook_operation_item
    objectName: "YTextBookOperation.qml"
    anchors.fill: parent
    readonly property var textbookObj: id_textbook_page.selectTextbookObj
    readonly property bool textbookIsBought: textbookObj.isBought
    readonly property bool textbookIsExpirated: textbookObj.isExpirated
    readonly property int textbookDownloadState: textbookObj.downloadState
    property int showContentState: YEnum.TB_OS_Bought
    property bool showBoughtTipDetail: false
    property var paymentMethod: YEnum.OC_WX
    property var paymentQrContent: ""
    property var paymentQrcodeOrderId: ""
    property bool isAddingToShelf: false

    function updateShowContentState() {
        //console.log("YTextbookOperation.qml === updateShowContentState textbookObj.isBought:", textbookObj.isBought)
        //console.log("YTextbookOperation.qml === updateShowContentState textbookObj.isExpirated:", textbookObj.isExpirated)
        //console.log("YTextbookOperation.qml === updateShowContentState textbookObj.downloadState:", textbookObj.downloadState)
        if (textbookObj.isBought) {
            if (textbookObj.isExpirated) {
                showContentState = YEnum.TB_OS_Rebought
            } else if (textbookObj.downloadState === YEnum.DS_SUCCEED) {
                showContentState = YEnum.TB_OS_StartStudy
            } else {
                showContentState = YEnum.TB_OS_Download
                showBoughtTipDetail = false
            }
        } else {
            showContentState = YEnum.TB_OS_Bought
        }
    }

    function showKeyboard(keyBoardPage) {
        keyBoardPage.backButtonClicked.connect(function(){
            keyBoardPage.todoDestroy()
            YInputProperty.inputPageShowing = false
            keyBoardPage = null
        })
        keyBoardPage.inputFinished.connect(function(pwd){
            if (pwd.length > 0) {
                textBookManager.payByRedeemCode(textbookObj.bookId, pwd.toUpperCase())
                baseSignals.showToast(YTranslateText.textbookVerificationCodeVerifying, YColors.grayNormal)
            }
        })
        keyBoardPage.placeHolderText = YTranslateText.textbookInputVerificationCode
        keyBoardPage.visible = true
        YInputProperty.inputPageShowing = true
    }

    property int incubatorCreateCount: 0
    function requestKeyboard() {
        const component = qmlCreateComponent("input/YInputPage")
        if (Component.Ready === component.status) {
            let incubator = component.incubateObject(id_keyboard_container);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            showKeyboard(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                showKeyboard(incubator.object)
            }
        }
    }

    onTextbookIsBoughtChanged: {
        //console.log("YTextbookOperation.qml === onTextbookDownloadStateChanged textbookIsBought:", textbookIsBought)
        updateShowContentState()
        if (textbookIsBought) id_textbook_operation_drawer_layer.hide()
    }

    onTextbookIsExpiratedChanged: {
        //console.log("YTextbookOperation.qml === onTextbookDownloadStateChanged textbookIsExpirated:", textbookIsExpirated)
        updateShowContentState()
    }

    onTextbookDownloadStateChanged: {
        //console.log("YTextbookOperation.qml === onTextbookDownloadStateChanged textbookDownloadState:", textbookDownloadState)
        updateShowContentState()
    }

    YVerticalTitleBar {
        onCallBack: {
            if (showContentState === YEnum.TB_OS_PaymentQrcode) {
                textBookManager.stopOrderStatusCheckLoop()
                showContentState = YEnum.TB_OS_Bought
            } else if (showBoughtTipDetail) {
                showBoughtTipDetail = false
            } else {
                id_textbook_page.closeOperationSubPage()
            }
        }
        objectName: "YBackButtonPage.qml_" + id_textbook_operation_item.objectName

        Item {
            id: id_vertical_bottom_button
            width: 80
            height: 62
            anchors.bottom: parent.bottom
            visible: (id_vertical_bottom_button_icon.icon.length > 0) && textbookObj.fullTitle.indexOf("人教版") < 0

            YIconButton {
                id: id_vertical_bottom_button_icon
                implicitWidth: 44
                implicitHeight: 44
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 22
                icon: {
                    switch (showContentState) {
                    case YEnum.TB_OS_Bought:
                        return "textbook/verification-code"
                    case YEnum.TB_OS_StartStudy:
                    case YEnum.TB_OS_ContinueBought:
                    case YEnum.TB_OS_PaymentQrcode:
                    case YEnum.TB_OS_Download:
                    case YEnum.TB_OS_Rebought:
                    default:
                        return ""
                    }
                }
                iconSourceSize: Qt.size(36, 36)
            }

            YMouseArea {
                anchors.fill: parent
                anchors.bottomMargin: -18

                onClicked: {
                    if (id_vertical_bottom_button_icon.icon.indexOf("code") >= 0) {
                        logManager.sendHttpLog("action=textbook_coupon_click")
                        id_textbook_operation_drawer_layer.drawerLayerType = 1
                        id_textbook_operation_drawer_layer.show()
                    }
                }
            }
        }
    }

    Item {
        id: id_textbook_operation_content
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        Rectangle {
            id: id_textbook_icon
            anchors.verticalCenter: parent.verticalCenter
            height: (showContentState === YEnum.TB_OS_PaymentQrcode) ? 210 : 222
            width: (showContentState === YEnum.TB_OS_PaymentQrcode) ? 210 : 154
            color: (showContentState === YEnum.TB_OS_PaymentQrcode) ? "#FFFFFF" : "#000000"
            radius: 16

            Loader {
                id: id_textbook_icon_loader
                sourceComponent: {
                    if ((showContentState === YEnum.TB_OS_PaymentQrcode)) {
                        return id_textbook_payment_qrcode_component
                    } else {
                        return id_textbook_icon_component
                    }
                }
            }

            Component {
                id: id_textbook_payment_qrcode_component

                Item {
                    id: id_textbook_icon_item_root
                    width: id_textbook_icon.width
                    height: id_textbook_icon.height

                    Image {
                        id: id_qrcode_icon
                        anchors.centerIn: parent
                        visible: paymentQrContent.length > 0
                        source: visible ? paymentQrContent : ""
                        width: 200
                        height: 200
                    }

                    YImage {
                        id: id_qrcode_icon_default
                        anchors.centerIn: parent
                        sourceSize: Qt.size(94, 50)
                        imageName: "login/login-default-qr"
                        visible: !id_qrcode_icon.visible
                    }
                }
            }

            Component {
                id: id_textbook_icon_component

                Item {
                    id: id_textbook_icon_item_root
                    width: id_textbook_icon.width
                    height: id_textbook_icon.height

                    Image {
                        id: _image
                        readonly property string iconSource: qmlGlobal.fileExists(textbookObj.icon) ? textbookObj.icon.toLoadFileUrl()
                                                                                                           : "image://icons/textbook/book_default.png"

                        smooth: true
                        visible: false
                        anchors.fill: parent
                        source: iconSource
                        sourceSize: Qt.size(parent.width, parent.height)
                        antialiasing: true


                    }
                    OpacityMask {
                        id: mask_image
                        anchors.fill: _image
                        source: _image
                        maskSource: id_textbook_icon
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
                        text: textbookObj.publisher
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
                        text: textbookObj.title
                        elide: YText.ElideRight
                        visible: _image.iconSource.indexOf("book_default.png") > 0
                    }

                    Rectangle {
                        width: parent.width
                        height: 52
                        anchors.bottom: parent.bottom
                        color: "#000000"
                        opacity: 0.5
                        visible: !id_free_buy_btn.visible

                        YImage {
                            id: id_item_bottom_shop_image
                            imageName: qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP) ? "textbook/shopping-add" : "textbook/shopping-cart"
                            sourceSize: Qt.size(28, 28)
                            width: sourceSize.width
                            height: sourceSize.height
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 17
                            visible: showContentState === YEnum.TB_OS_Bought
                        }

                        YTextMedium {
                            id: id_item_bottom_shop_text
                            color: YColors.white
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 22
                            width: 88
                            height: 27
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 17
                            text:  {
                                if (!qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)) {
                                    return YTranslateText.textbookClickToBuy
                                }
                                return isAddingToShelf ? YTranslateText.textbookAddingShelf : YTranslateText.textbookAddShelf
                            }
                            visible: showContentState === YEnum.TB_OS_Bought
                        }

                        YTextMedium {
                            id: id_item_bottom_expiration_text
                            color: YColors.white
                            width: contentWidth
                            height: contentHeight
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            text: {
                                switch (showContentState) {
                                case YEnum.TB_OS_ContinueBought:
                                case YEnum.TB_OS_Download:
                                case YEnum.TB_OS_StartStudy:
                                    return textbookObj.expirationString + YTranslateText.textbookExpire
                                case YEnum.TB_OS_Rebought:
                                    return YTranslateText.textbookExpire
                                default:
                                    return ""
                                }
                            }
                            visible: text.length > 0 && !qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)
                        }
                    }

                    Item {
                        id: id_free_buy_btn
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 108
                        visible: showContentState === YEnum.TB_OS_Bought
                                 && textbookObj.freeBrief.length > 0
                                 && !qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)

                        YImage {
                            imageName: "textbook/free-buy"
                            sourceSize: Qt.size(154, 108)
                            width: sourceSize.width
                            height: sourceSize.height
                            anchors.bottom: parent.bottom
                            visible: parent.visible && !isAddingToShelf
                        }

                        YImage {
                            imageName: "textbook/free-buy-adding"
                            sourceSize: Qt.size(154, 108)
                            width: sourceSize.width
                            height: sourceSize.height
                            anchors.bottom: parent.bottom
                            visible: parent.visible && isAddingToShelf
                        }

                    }

                    YMouseArea {
                        id: id_clickabled_button
                        anchors.fill: parent
                        anchors.margins: -28
                        enabled: (showContentState === YEnum.TB_OS_Bought) && !isAddingToShelf
                        onClicked: {
                            if (showContentState === YEnum.TB_OS_Bought) {
                                if (!wifiManager.internetConnect) {
                                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                                    return
                                }

                                if (qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)) {
                                    isAddingToShelf = true
                                    textBookManager.httpPayByRenJiao(textbookObj.bookId)
                                    return
                                }
                                if (textbookObj.freeBrief.length > 0) {
                                    isAddingToShelf = true
                                    logManager.sendHttpLog("action=textbook_purchase_free_click")
                                    textBookManager.httpPayByFree(textbookObj.bookId)
                                    return
                                }

                                textBookManager.syncBookPayInfo(textbookObj.bookId)
                                logManager.sendHttpLog("action=textbook_purchase_click")
                                id_textbook_operation_drawer_layer.drawerLayerType = 0
                                id_textbook_operation_drawer_layer.show()
                            }
                        }
                        objectName: "YTextbookOperation.qml_textbookicon"
                    }
                }
            }
        }

        Item {
            id: id_textbook_content
            anchors.left: id_textbook_icon.right
            anchors.leftMargin: 26
            anchors.right: parent.right
            anchors.rightMargin: 16
            height: parent.height

            YTextMedium {
                id: id_textbook_fullTitle_text
                width: parent.width
                height: 66
                lineHeightMode: Text.FixedHeight
                lineHeight: height/2
                anchors.top: parent.top
                anchors.topMargin: 18
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 27
                verticalAlignment: Text.AlignVCenter
                text: textbookObj.fullTitle
                visible: !showBoughtTipDetail
            }

            Loader {
                anchors.fill: parent
                active: true
                sourceComponent: {
                    switch (showContentState) {
                    case YEnum.TB_OS_ContinueBought:
                    case YEnum.TB_OS_Download:
                    case YEnum.TB_OS_StartStudy:
                    case YEnum.TB_OS_Rebought:
                        return id_textbook_dowmload_content_component
                    case YEnum.TB_OS_Bought:
                    case YEnum.TB_OS_PaymentQrcode:
                    default:
                        return id_textbook_bought_content_component
                    }
                }
            }

            Component {
                id: id_textbook_dowmload_content_component

                Item {
                    id: id_textbook_dowmload_content
                    anchors.fill: parent
                    anchors.topMargin: 92
                    Column {
                        width: parent.width
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        spacing: 2
                        YText {
                            id: id_textbook_isbn_text
                            width: parent.width
                            height: 27
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 22
                            verticalAlignment: Text.AlignVCenter
                            color: YColors.grayText
                            text: textbookObj.isbn.length > 0 ? "ISBN " + textbookObj.isbn : ""
                            visible: textbookObj.isbn.length > 0
                        }

                        YText {
                            id: id_textbook_active_code_text
                            width: parent.width
                            height: 27
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 22
                            verticalAlignment: Text.AlignVCenter
                            color: YColors.grayText
                            text: textbookObj.activeCode.length > 0 ? YTranslateText.textbookActiveCode + textbookObj.activeCode : ""
                        }
                    }

                    Row {
                        id: id_textbook_dowmload_button_row
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 16
                        height: 72
                        spacing: 16

                        YDownloadProgressButton {
                            id: id_download_progress_button
                            implicitWidth: 400
                            buttonColor: YColors.grayButton
                            progressColor: YColors.blueRect
                            visible: showContentState === YEnum.TB_OS_Download
                            clickable: visible
                            textFamily: fontManager.fontFamilyZhCn
                            text: textbookObj.downloadState !== YEnum.DS_ING
                                  ? YTranslateText.clickToDownload
                                  : YTranslateText.downloadProgress.arg(textbookObj.progress)
                            onDownload: {
                                if (textbookObj.downloadState === YEnum.DS_SUCCEED) {
                                    return
                                }
                                if (!wifiManager.internetConnect) {
                                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                                    return
                                }
                                if (textbookObj.downloadState !== YEnum.DS_ING) {
                                    textBookManager.downloadBook(textbookObj.bookId)
                                } else {
                                    textBookManager.downloadPause(textbookObj.bookId)
                                }
                            }
                            Component.onCompleted: {
                                id_download_progress_button.progress = Qt.binding(function() {
                                    return textbookObj.progress
                                })
                            }
                        }

                        YButton {
                            height: parent.height
                            width: 400
                            color: YColors.blueRect
                            visible: {
                                switch (showContentState) {
                                case YEnum.TB_OS_ContinueBought:
                                case YEnum.TB_OS_StartStudy:
                                case YEnum.TB_OS_Rebought:
                                    return true
                                default:
                                    return false
                                }
                            }
                            textFamily: fontManager.fontFamilyZhCn
                            text: {
                                switch (showContentState) {
                                case YEnum.TB_OS_ContinueBought:
                                    return YTranslateText.textbookContinueBuy
                                case YEnum.TB_OS_StartStudy:
                                    return YTranslateText.textbookStartStudy
                                case YEnum.TB_OS_Rebought:
                                    return YTranslateText.textbookRebought
                                default:
                                    return ""
                                }
                            }
                            onValidClicked: {
                                switch (showContentState) {
                                case YEnum.TB_OS_ContinueBought:
                                case YEnum.TB_OS_Rebought:
                                    showContentState = YEnum.TB_OS_Bought
                                    break
                                case YEnum.TB_OS_StartStudy:
                                    textBookManager.setDefaultGrade(textbookObj.gradeId)
                                    textBookManager.setStudyingBook(textbookObj.bookId)
                                    showSubPage(YEnum.Textbook_Home, false)
                                    break
                                default:
                                    break
                                }
                            }
                        }

                        Item {
                            id: id_textbook_block_delete_button
                            visible: textbookObj.downloadState === YEnum.DS_SUCCEED
                            width: 72
                            height: 72

                            YIconButton {
                                implicitWidth: parent.width
                                implicitHeight: parent.height
                                radius: height * 0.5
                                color: YColors.grayButton
                                icon: "ic_delete"
                                iconSourceSize: Qt.size(36, 36)
                            }

                            YMouseArea {
                                anchors.fill: parent
                                anchors.margins: -18
                                enabled: id_textbook_block_delete_button.visible
                                onClicked: {
                                    id_textbook_operation_drawer_layer.drawerLayerType = 2
                                    id_textbook_operation_drawer_layer.show()
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: id_textbook_bought_content_component

                Item {
                    id: id_textbook_bought_content
                    anchors.fill: parent

                    Column {
                        width: parent.width
                        anchors.bottom: id_textbook_bought_tip_text.top
                        anchors.bottomMargin: 7
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        spacing: 6
                        Row {
                            id: id_textbook_price_info
                            visible: id_textbook_price_info_text.visible
                            width: parent.width
                            height: 34
                            YText {
                                id: id_textbook_price_text
                                width: contentWidth
                                height: parent.height
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: showBoughtTipDetail ? 26 : 24
                                verticalAlignment: Text.AlignVCenter
                                color: showBoughtTipDetail ? YColors.white : YColors.grayText
                                text: YTranslateText.textbookPrice
                            }

                            YTextMedium {
                                id: id_textbook_price_info_text
                                height: parent.height
                                width: contentWidth
                                anchors.verticalCenter: id_textbook_price_text.verticalCenter
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: showBoughtTipDetail ? 26 : 24
                                verticalAlignment: Text.AlignVCenter
                                color: textbookObj.freeBrief.length > 0 ? YColors.grayText : YColors.red
                                text: textbookObj.priceBrief
                                visible: textbookObj.priceBrief.length > 0

                                YImage {
                                    imageName: "textbook/red-delete-line"
                                    height: 10
                                    anchors.verticalCenter: id_textbook_price_info_text.verticalCenter
                                    anchors.left: id_textbook_price_info_text.left
                                    anchors.right: id_textbook_price_info_text.right
                                    anchors.leftMargin: -10
                                    anchors.rightMargin: -10
                                    visible: id_textbook_free_info_text.visible
                                }
                            }

                            YTextMedium {
                                id: id_textbook_free_info_text
                                height: parent.height
                                width: contentWidth
                                anchors.verticalCenter: id_textbook_price_info_text.verticalCenter
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: id_textbook_price_info_text.font.pixelSize
                                verticalAlignment: Text.AlignVCenter
                                color: YColors.red
                                text: "  " + textbookObj.freeBrief
                                visible: id_textbook_price_info_text.visible && textbookObj.freeBrief.length > 0
                            }
                        }

                        YText {
                            id: id_textbook_isbn_text
                            width: parent.width
                            height: 27

                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 22
                            verticalAlignment: Text.AlignVCenter
                            color: YColors.grayText
                            text: textbookObj.isbn.length > 0 ? "ISBN " + textbookObj.isbn : ""
                            visible: !showBoughtTipDetail
                        }
                    }
                    YText {
                        id: id_textbook_bought_tip_text
                        width: parent.width
                        height: showBoughtTipDetail ? 144 : 72
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 36
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin:  {
                            let margin = showBoughtTipDetail ? 32 : 16
                            if (showBoughtTipDetail && !id_textbook_price_info.visible) {
                                margin += id_textbook_price_info.height + id_textbook_price_info.anchors.bottomMargin
                            }

                            return margin
                        }
                        wrapMode: Text.WrapAnywhere
                        elide: (showContentState === YEnum.TB_OS_PaymentQrcode) ? Text.ElideNone : Text.ElideRight
                        textFormat: (showContentState === YEnum.TB_OS_PaymentQrcode) ? Text.RichText : Text.PlainText
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: showBoughtTipDetail ? 26 : 24
                        verticalAlignment: Text.AlignVCenter
                        color: showBoughtTipDetail ? YColors.white : YColors.grayText
                        text: {
                            if ((showContentState === YEnum.TB_OS_PaymentQrcode)) {
                                let qsPayMethod = ""
                                switch (paymentMethod) {
                                case YEnum.OC_WX:
                                    qsPayMethod = YTranslateText.textbookPaymentTipWeChat
                                    break
                                case YEnum.OC_ALI:
                                default:
                                    qsPayMethod = YTranslateText.textbookPaymentTipAlipay
                                    break
                                }
                                return YTranslateText.textbookPaymentTip.arg('<span style="color:' + YColors.red + ';">' + qsPayMethod + '</span>')
                            } else {
                                return textbookObj.remark
                            }
                        }

                        YMouseArea {
                            anchors.fill: parent
                            enabled: showBoughtTipDetail
                            onClicked: {
                                if (showBoughtTipDetail) {
                                    showBoughtTipDetail = false
                                }
                            }
                        }

                        Behavior on height {
                            NumberAnimation { duration: 60 }
                        }
                    }

                    YImage {
                        id: id_textbook_bought_tip_detail_image
                        width: 24
                        height: 24
                        sourceSize: Qt.size(24, 24)
                        imageName: "textbook/enter-icon"
                        anchors.left: id_textbook_bought_tip_text.right
                        anchors.leftMargin: -16
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 26
                        visible: !showBoughtTipDetail && (showContentState !== YEnum.TB_OS_PaymentQrcode)

                        YMouseArea {
                            id: id_textbook_bought_tip_detail_clickarea
                            anchors.centerIn: id_textbook_bought_tip_detail_image
                            width: 60
                            height: 60
                            onClicked: {
                                showBoughtTipDetail = !showBoughtTipDetail
                            }
                        }
                    }

                }
            }

        }
    }

    Item {
        id: id_keyboard_container
        anchors.fill: parent
    }

    YDrawerLayer {
        id: id_textbook_operation_drawer_layer
        indicatorLeftMargin: 16
        indicatorRightMargin: 50
        drawerContainerRightMargin: 30
        containerWidth: id_textbook_operation_drawer_layer_item.width
        z: id_textbook_operation_content.z + 1
        property var drawerLayerType: 0 // 0 支付方式, 1 兑换验证码, 2 删除教材包

        Flickable {
            id: id_textbook_operation_drawer_layer_item
            width: 460
            height: 254
            contentHeight: id_textbook_operation_drawer_layer_loader.height

            Loader {
                id: id_textbook_operation_drawer_layer_loader
                active: id_textbook_operation_drawer_layer.state === "show"
                sourceComponent: {
                    switch (id_textbook_operation_drawer_layer.drawerLayerType) {
                    case 0:
                        return id_payment_method_component
                    case 1:
                        return id_exchange_verification_code_component
                    case 2:
                    default:
                        return id_delete_textbook_block_component
                    }
                }

                Component {
                    id: id_payment_method_component

                    Column {
                        width: id_textbook_operation_drawer_layer_item.width
                        spacing: 0

                        YSpacingForColumn {
                            implicitHeight: 24
                        }

                        YText {
                            width: parent.width
                            height: 32
                            color: YColors.grayText
                            font.pixelSize: 26
                            font.family: fontManager.fontFamilyZhCn
                            text: YTranslateText.textbookSelectPaymentMethod
                        }

                        YSpacingForColumn {
                            implicitHeight: 28
                        }

                        Item {
                            width: parent.width
                            height: 134

                            YImageButton {
                                sourceSize: Qt.size(90, 90)
                                imageName: "textbook/payment-method-wechat"
                                anchors.left: parent.left
                                anchors.leftMargin: 80

                                YText {
                                    width: contentWidth
                                    height: 32
                                    font.pixelSize: 26
                                    font.family: fontManager.fontFamilyZhCn
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.bottom
                                    anchors.topMargin: 12
                                    text: YTranslateText.textbookPaymentMethodWeChat
                                }

                                onClicked: {
                                    if (!wifiManager.internetConnect) {
                                        baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                                        return
                                    }
                                    logManager.sendHttpLog("action=textbook_purchase_wechat_click")
                                    textBookManager.queryQrcode(textbookObj.bookId, YEnum.OC_WX)
                                    paymentMethod = YEnum.OC_WX
                                    showBoughtTipDetail = false
                                    showContentState = YEnum.TB_OS_PaymentQrcode
                                    id_textbook_operation_drawer_layer.hide()
                                }
                            }

                            YImageButton {
                                sourceSize: Qt.size(90, 90)
                                imageName: "textbook/payment-method-alipay"
                                anchors.left: parent.left
                                anchors.leftMargin: 288

                                YText {
                                    width: contentWidth
                                    height: 32
                                    font.pixelSize: 26
                                    font.family: fontManager.fontFamilyZhCn
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.bottom
                                    anchors.topMargin: 12
                                    text: YTranslateText.textbookPaymentMethodAlipay
                                }

                                onClicked: {
                                    if (!wifiManager.internetConnect) {
                                        baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                                        return
                                    }
                                    logManager.sendHttpLog("action=textbook_purchase_alipay_click")
                                    textBookManager.queryQrcode(textbookObj.bookId, YEnum.OC_ALI)
                                    paymentMethod = YEnum.OC_ALI
                                    showBoughtTipDetail = false
                                    showContentState = YEnum.TB_OS_PaymentQrcode
                                    id_textbook_operation_drawer_layer.hide()
                                }
                            }
                        }
                    }
                }

                Component {
                    id: id_exchange_verification_code_component

                    Item {
                        width: id_textbook_operation_drawer_layer_item.width
                        height: id_textbook_operation_drawer_layer_item.height

                        YText {
                            id: id_exchange_verification_code_text
                            width: parent.width
                            height: 110
                            anchors.top: parent.top
                            anchors.topMargin: 30
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAnywhere
                            font.family: fontManager.fontFamilyZhCn
                            text: YTranslateText.textbookExchangeVerificationCode
                        }

                        YButton {
                            id: id_exchange_verification_code_cancel
                            anchors.top: id_exchange_verification_code_text.bottom
                            anchors.topMargin: 10
                            anchors.left: parent.left
                            anchors.leftMargin: 32
                            width: 190
                            height: 80
                            color: YColors.grayButton
                            textFamily: fontManager.fontFamilyZhCn
                            text: ("取消")

                            onValidClicked: {
                                id_textbook_operation_drawer_layer.hide()
                            }
                        }

                        YButton {
                            id: id_exchange_verification_code_confirm
                            anchors.verticalCenter: id_exchange_verification_code_cancel.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 238
                            width: 190
                            height: 80
                            textFamily: fontManager.fontFamilyZhCn
                            text: ("确认")


                            onValidClicked: {
                                if (!wifiManager.internetConnect) {
                                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                                    return
                                }
                                id_textbook_operation_drawer_layer.hide()
                                requestKeyboard()
                            }
                        }
                    }
                }

                Component {
                    id: id_delete_textbook_block_component

                    Item {
                        width: id_textbook_operation_drawer_layer_item.width
                        height: id_textbook_operation_drawer_layer_item.height

                        YText {
                            id: id_exchange_verification_code_text
                            width: parent.width
                            height: 110
                            anchors.top: parent.top
                            anchors.topMargin: 30
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAnywhere
                            font.family: fontManager.fontFamilyZhCn
                            text: ("确认删除“%1”吗？").arg(textbookObj.title)
                        }

                        YButton {
                            id: id_exchange_verification_code_cancel
                            anchors.top: id_exchange_verification_code_text.bottom
                            anchors.topMargin: 10
                            anchors.left: parent.left
                            anchors.leftMargin: 32
                            width: 190
                            height: 80
                            color: YColors.grayButton
                            textFamily: fontManager.fontFamilyZhCn
                            text: ("取消")

                            onValidClicked: {
                                id_textbook_operation_drawer_layer.hide()
                            }
                        }

                        YButton {
                            id: id_exchange_verification_code_confirm
                            anchors.verticalCenter: id_exchange_verification_code_cancel.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 238
                            width: 190
                            height: 80
                            textFamily: fontManager.fontFamilyZhCn
                            text: ("删除")

                            onValidClicked: {
                                textBookManager.remove(textbookObj.bookId)
                                id_textbook_operation_drawer_layer.hide()
                                if (0 === textbookObj.coverUrl.length && textbookObj.icon.length > 0) {
                                   textBookManager.reload()
                                   id_textbook_page.closeOperationSubPage()
                                }

                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: textBookManager
        ignoreUnknownSignals: true

        function onQrcodeReady(bookId, qrcontent, orderId) {
            if (bookId === textbookObj.bookId) {
                paymentQrContent = qrcontent
                paymentQrcodeOrderId = orderId
            }
        }

        function onPayStatusChanged(bookId, isPayed, chanel,  errCode) {
            //console.log("YTextbookOperation.qml === bookId:", bookId)
            //console.log("YTextbookOperation.qml === isPayed:", isPayed)
            //console.log("YTextbookOperation.qml === chanel:", chanel)
            //console.log("YTextbookOperation.qml === errMsg:", errMsg)
            //console.log("YTextbookOperation.qml === textbookObj.bookId:", textbookObj.bookId)
            if (bookId === textbookObj.bookId) {
                isAddingToShelf = false
                let errMsg = ""
                if (errCode.length > 0) {
                    let mapMsg = {
                        "601": YTranslateText.textbookOrderNotPay,
                        "602": YTranslateText.textbookOrderExpired,
                        "603": YTranslateText.textbookOrderMoneyback,
                        "421": YTranslateText.textbookOrderNotExist,
                        "750": YTranslateText.textbookRedeemUsed,
                        "900": YTranslateText.textbookGetRenjiaoCodeFailed,
                    }
                    if (mapMsg.hasOwnProperty(errCode)) {
                        errMsg  = mapMsg[errCode]
                    }
                }

                if (errMsg.length > 0) {
                    baseSignals.showToast(errMsg, YColors.grayButton)
                    updateShowContentState()
                } else {
                    switch (chanel) {
                    case YEnum.OC_RENJIAO:
                        baseSignals.showToast((isPayed ? YTranslateText.textbookRenjiaoSuccessful
                                                     : YTranslateText.textbookRenjiaoFailed), YColors.grayButton)
                        break
                    case YEnum.OC_REDEEM:
                        baseSignals.showToast((isPayed ? YTranslateText.textbookRedeemSuccessful
                                                     : YTranslateText.textbookRedeemFailed), YColors.grayButton)
                        break
                    case YEnum.OC_ALI:
                    case YEnum.OC_WX:
                        baseSignals.showToast((isPayed ? YTranslateText.textbookPaymentSuccessful
                                                     : YTranslateText.textbookPaymentFailed), YColors.grayButton)
                        break
                    case YEnum.OC_FREE:
                        baseSignals.showToast((isPayed ? YTranslateText.textbookFreeBuySuccessful
                                                     : YTranslateText.textbookFreeBuyFailed), YColors.grayButton)
                        break
                    }
                }

                if (isPayed) {
                    showContentState = YEnum.TB_OS_Download
                    showBoughtTipDetail = false
                }
            }
        }
    }

    Component.onCompleted: {
        // TODO 检查即将过期,设置继续购买
        if (settingManager.studyingBookId === textbookObj.bookId && id_textbook_page.isContinueBought) {
            showContentState = YEnum.TB_OS_ContinueBought
            id_textbook_page.isContinueBought = false
        }
    }
}

