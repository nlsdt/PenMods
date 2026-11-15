import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Item {
    id: id_reference_root
    anchors.fill: parent

    enum ShowMode {
        OriginalNotes,          // 原文和注释
        NotesOnly,              // 仅注释
        OriginalForNotes,       // 注释的原文
        OriginalTranslation,    // 原文和译文
        TranslationOnly,        // 仅译文
        OriginalForTranslation  // 译文的原文
    }

    function show(mode, content) {
        function newComponentInit(incubatorObject) {
            incubatorObject.closeView.connect(incubatorObject.destroy)
            systemBase.homeKeyRelease.connect(incubatorObject.destroy)
            systemBase.homeKeyLongPress.connect(incubatorObject.destroy)
            systemBase.ocrStart.connect(incubatorObject.destroy)
            qmlGlobal.requestWordLargeBookAnswerResult.connect(incubatorObject.destroy)
            incubatorObject.show(mode, content)
        }

        const incubator = id_reference_view_component.incubateObject(
                            id_reference_root)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateDictTypeDtChPoemReferenceViewCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateDictTypeDtChPoemReferenceViewCount
        } else {
            newComponentInit(incubator.object)
        }
    }

    property int incubatorCreateDictTypeDtChPoemReferenceViewCount: 0

    Component {
        id: id_reference_view_component
        YBackgroundIgnoreMouseEvent {
            id: id_reference_view
            anchors.fill: parent
            visible: false

            signal closeView()

            function show(mode, contentObj) {
                currentShowMode = mode
                let originContents = []
                let orderNumber = 0
                //const contents = contentObj
                contentObj.forEach(function(content){
                    const sentences = content.sentences
                    sentences.forEach(function(sentence){
                        originContents.push(sentence.formatted.replace(/mark/g, "u"))
                        sentence.orderNumber = orderNumber
                        ++orderNumber
                    })
                })
                id_origins_repeater.model = originContents
                currentContent = contentObj
                visible = true
            }

            property int currentShowMode:
                YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes
            property var currentContent: null

            YBackButton {
                id: id_back_button
                onClicked: {
                    id_reference_view.closeView()
                }
                iconButtonBackgroundItem.anchors.horizontalCenterOffset: -2
                iconButtonBackgroundItem.anchors.verticalCenter:
                    id_back_button.verticalCenter
                objectName: "YDictTypeDtChPoemReferenceView.qml_"
                            + id_reference_view.objectName
            }

            YIconButton {
                id: id_to_top_button
                opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
                implicitWidth: 44
                implicitHeight: 44
                radius: height/2
                mouseAreaMargins: -25
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                imageName: "dict/to-top"
                visible: (id_flickable.contentY > id_flickable.height 
                || id_origins_flickable.contentY > id_origins_flickable.height)

                onValidClicked: {
                    id_flickable_moving_timer.restart()
                    id_flickable.contentY = 0
                    id_origins_flickable.contentY = 0
                }
            }

            Flickable {
                id: id_flickable
                anchors.fill: parent
                anchors.leftMargin: 90
                anchors.rightMargin: 16
                contentHeight: id_column.height

                property int currentContentIndex: 0
                signal contentsFlickabled()
                signal moveOrigin(int toIndex)

                onMovingChanged: {
                    if (!moving && !id_flickable_moving_timer.running) {
                        if (id_flickable.contentY < 5) {
                            id_origins_flickable.contentY = 0
                            id_flickable.contentY = 0
                        }
                        contentsFlickabled()
                    }
                }

                property int leftAreaWidth: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        return 302
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForTranslation:
                        return 680
                    default:
                        return 0
                    }
                }
                property int rightAreaWidth: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        return 328
                    case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                    case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                        return 680
                    default:
                        return 0
                    }
                }

                YTimer {
                    id: id_flickable_moving_timer
                    interval: 100
                }

                Column {
                    id: id_column
                    anchors.left: parent.left
                    anchors.right: parent.right

                    YSpacingForColumn {
                        implicitHeight: 20
                    }

                    YText {
                        anchors.left: parent.left
                        anchors.leftMargin: {
                            switch(currentShowMode) {
                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                                return 366
                            default:
                                return 10
                            }
                        }
                        anchors.right: parent.right
                        height: 34
                        text: {
                            switch(currentShowMode) {
                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                            case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                                return YTranslateText.poemNotes
                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                            case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                                return YTranslateText.poemTrans
                            default:
                                return YTranslateText.poemOri
                            }
                        }
                        color: "#878A99"
                    }

                    YSpacingForColumn {
                        implicitHeight: 20
                    }

                    Repeater {
                        id: id_contents_repeater
                        model: currentContent

                        Column {
                            id: id_column_sentences
                            anchors.left: parent.left
                            anchors.right: parent.right
                            property var sentencesData: model.modelData

                            Repeater {
                                id: id_sentences_repeater
                                model: sentencesData.sentences

                                Row {
                                    id: id_contents_container
                                    anchors.left: parent.left
                                    anchors.leftMargin: {
                                        switch(currentShowMode) {
                                        case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                                        case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                                        case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForNotes:
                                        case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForTranslation:
                                            return 10
                                        default:
                                            return 0
                                        }
                                    }
                                    anchors.right: parent.right
                                    spacing: {
                                        switch(currentShowMode) {
                                        case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                                        case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                                            return 64
                                        default:
                                            return 0
                                        }
                                    }
                                    height: {
                                        if (id_explanations_column.visible && id_org_txt.visible) {
                                            return Math.max(id_explanations_column.height, id_org_txt.height) + 20
                                        } else {
                                            if (id_explanations_column.visible) {
                                                return id_explanations_column.height
                                            }
                                            if (id_org_txt.visible) {
                                                return id_org_txt.height
                                            }
                                            return 0
                                        }
                                    }
                                    Component.onCompleted: {
                                        id_flickable.contentsFlickabled.connect(function(){
                                            const contentItemPos = id_contents_container.mapToItem(id_reference_view, 0, 0)
                                            if (contentItemPos.y > 0 && contentItemPos.y <= 20) {
                                                if (id_flickable.currentContentIndex !== sentence.orderNumber) {
                                                    id_flickable.currentContentIndex = sentence.orderNumber
                                                    id_flickable.moveOrigin(sentence.orderNumber)
                                                }
                                            } else if (contentItemPos.y < 0 && contentItemPos.y + height > 0) {
                                                if ((id_flickable.currentContentIndex !== (1 + sentence.orderNumber))
                                                        && ((1 + sentence.orderNumber) < id_origins_repeater.count)) {
                                                    id_flickable.currentContentIndex = (1 + sentence.orderNumber)
                                                    id_flickable.moveOrigin(1 + sentence.orderNumber)
                                                }
                                            }
                                        })
                                        id_origins_flickable.moveContent.connect(function(toIndex){
                                            if (toIndex === sentence.orderNumber && !id_flickable_moving_timer.running) {
                                                if (id_contents_container.height > 0) {
                                                    const contentItemPos = id_contents_container.mapToItem(id_column, 0, 0)
                                                    id_flickable_moving_timer.restart()
                                                    id_flickable.contentY = Math.min(Math.max(contentItemPos.y - 74, 0),
                                                                                     id_flickable.contentHeight - id_flickable.height)
                                                } else {
                                                    if (toIndex < (id_origins_repeater.count - 1)) {
                                                        id_origins_flickable.moveContent(toIndex + 1)
                                                    }
                                                }
                                            }
                                        })
                                    }

                                    readonly property var sentence: model.modelData

                                    YText {
                                        id: id_org_txt
                                        width: id_flickable.leftAreaWidth
                                        height: paintedHeight
                                        text: sentence.formatted.replace(/mark/g, "u")
                                        wrapMode: YText.Wrap
                                        textFormat: YText.RichText
                                        visible: {
                                            switch(currentShowMode) {
                                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForNotes:
                                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForTranslation:
                                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                                                return true
                                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                                                return id_contents_container.sentence.explanations.length > 0
                                            default:
                                                return false
                                            }
                                        }
                                    }

                                    Column {
                                        id: id_explanations_column
                                        width: id_flickable.rightAreaWidth
                                        spacing: id_org_txt.visible ? 20 : 0

                                        visible: {
                                            switch(currentShowMode) {
                                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                                            case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                                                return id_contents_container.sentence.explanations.length > 0
                                            case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                                            case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                                                return true
                                            default:
                                                return false
                                            }
                                        }

                                        Repeater {
                                            model: {
                                                switch(currentShowMode) {
                                                case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                                                case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                                                    return id_contents_container.sentence.explanations
                                                case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                                                case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                                                    return JSON.parse(('[{"translate":"%1"}]').arg(id_contents_container.sentence.translate))
                                                default:
                                                    return 0
                                                }
                                            }

                                            YText {
                                                anchors.left: id_explanations_column.left
                                                anchors.right: id_explanations_column.right
                                                height: paintedHeight
                                                text: {
                                                    switch(currentShowMode) {
                                                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                                                    case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                                                        return model.modelData.word + "：" + model.modelData.meaning
                                                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                                                    case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                                                        return model.modelData.translate
                                                    default:
                                                        return ""
                                                    }
                                                }
                                                wrapMode: YText.Wrap
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            YBackgroundIgnoreMouseEvent {
                width: 302
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 90
                anchors.bottom: parent.bottom
                visible: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        return true
                    default:
                        return false
                    }
                }

                Flickable {
                    id: id_origins_flickable
                    anchors.fill: parent
                    contentHeight: id_origins_column.height
                    property int currentOriginIndex: 0
                    signal originsFlickabled()
                    signal moveContent(int toIndex)
                    onMovingChanged: {
                        if (!moving && !id_origins_flickable_moving_timer.running) {
                            if (id_origins_flickable.contentY < 5) {
                                id_flickable.contentY = 0
                                id_origins_flickable.contentY = 0
                            }
                            originsFlickabled()
                        }
                    }
                    YTimer {
                        id: id_origins_flickable_moving_timer
                        interval: 100
                    }
                    Column {
                        id: id_origins_column
                        width: id_origins_flickable.width

                        YSpacingForColumn {
                            implicitHeight: 20
                        }

                        YText {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 34
                            text: YTranslateText.poemOri
                            color: "#878A99"
                        }

                        YSpacingForColumn {
                            implicitHeight: 20
                        }

                        Repeater {
                            id: id_origins_repeater
                            Item {
                                width: id_flickable.leftAreaWidth
                                height: id_origin_text.height + 20
                                YText {
                                    id: id_origin_text
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: paintedHeight
                                    text: model.modelData
                                    wrapMode: YText.Wrap
                                    textFormat: YText.RichText
                                }
                                Component.onCompleted: {
                                    id_origins_flickable.originsFlickabled.connect(function(){
                                        const originItemPos = id_origin_text.mapToItem(id_reference_view, 0, 0)
                                        if (originItemPos.y >= 0 && originItemPos.y <= 20) {
                                            if (id_origins_flickable.currentOriginIndex !== index) {
                                                id_origins_flickable.currentOriginIndex = index
                                                id_origins_flickable.moveContent(index)
                                            }
                                        } else if (originItemPos.y < 0 && originItemPos.y + id_origin_text.height > 0) {
                                            if ((id_origins_flickable.currentOriginIndex !== (1 + index))
                                                    && ((1 + index) < id_origins_repeater.count)) {
                                                id_origins_flickable.currentOriginIndex = (1 + index)
                                                id_origins_flickable.moveContent(1 + index)
                                            }
                                        }
                                    })
                                    id_flickable.moveOrigin.connect(function(toIndex){
                                        if (toIndex === index && !id_origins_flickable_moving_timer.running) {
                                            const originItemPos = id_origin_text.mapToItem(id_origins_column, 0, 0)
                                            id_origins_flickable_moving_timer.restart()
                                            id_origins_flickable.contentY = Math.min(originItemPos.y - 74,
                                                                                     id_origins_flickable.contentHeight - id_origins_flickable.height)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "#1F1F1F"
                anchors.left: parent.left
                anchors.leftMargin: 422
                implicitWidth: 4
                visible: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        return true
                    default:
                        return false
                    }
                }
            }

            YIconButton {
                implicitWidth: 44
                implicitHeight: 44
                anchors.left: parent.left
                anchors.leftMargin: 348
                anchors.top: parent.top
                anchors.topMargin: 18
                mouseAreaMargins: -18
                color: "#4D535353"
                visible: icon.length > 0
                icon: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        return "dict/unfold"
                    default:
                        return ""
                    }
                }
                onValidClicked: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.OriginalForNotes
                        break
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.OriginalForTranslation
                        break
                    default:
                        break
                    }
                }
            }

            YIconButton {
                implicitWidth: 44
                implicitHeight: 44
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: parent.top
                anchors.topMargin: 18
                mouseAreaMargins: -18
                color: "#202020" //"#4D535353"
                icon: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        return "dict/unfold"
                    default:
                        return "dict/retract"
                    }
                }
                onValidClicked: {
                    switch(currentShowMode) {
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly
                        break
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly
                        break
                    case YDictTypeDtChPoemReferenceView.ShowMode.NotesOnly:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes
                        break
                    case YDictTypeDtChPoemReferenceView.ShowMode.TranslationOnly:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation
                        break
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForNotes:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes
                        break
                    case YDictTypeDtChPoemReferenceView.ShowMode.OriginalForTranslation:
                        currentShowMode = YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation
                        break
                    default:
                        break
                    }
                }
            }

        }
    }
}
