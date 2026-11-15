import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_article_raw_essay_view
    objectName: "YArticleCorrectionsCompletedRawEssayView.qml"
    anchors.fill: parent
    visible: false

    property string grammerText: ""
    property string wordsText: ""
    property string normalText: ""

    function show() {
        visible = true
    }

    function backButtonClicked() {
        visible = false
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 20
        contentHeight: id_column.height

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right

            YSpacingForColumn {
                implicitHeight: 80
                YText {
                    font.pixelSize: 26
                    color: YColors.grayText
                    anchors.verticalCenter: parent.verticalCenter
                    text: YTranslateText.articleRawEssayView
                }
            }

            YTextMedium {
                id: id_raw_essay
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(paintedHeight, YEnum.Screen.Height - 100)
                font.family: qmlGlobal.fontFamilyEnUs
                wrapMode: YTextMedium.WrapAtWordBoundaryOrAnywhere
                color: YColors.white
                textFormat: YTextMedium.RichText
                text: {
                    switch (currentTabIndex) {
                    case YArticleCorrectionsCompletedDetailView.GrammarProblems:
                        return grammerText
                    case YArticleCorrectionsCompletedDetailView.WordsRecommended:
                        return wordsText
                    case YArticleCorrectionsCompletedDetailView.ScoreInstructions:
                    default:
                        return normalText
                    }
                }

                onLinkActivated: {
                    const sentInfo = link.split("_")
                    errorLinkClicked(sentInfo[0], sentInfo[1])
                    backButtonClicked()
                }
            }

            YSpacingForColumn {
                implicitHeight: 20
            }
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }
    }
}
