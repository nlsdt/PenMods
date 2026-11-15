import QtQuick 2.12

YTouchFollowReadingAudioPlayBase {
    id: id_answer_question_delegate_item
    width: PathView.view.width
    visible: PathView.isCurrentItem

    property string answerResult: ""
    property string selectedAnswerContentGroup: ""
    property bool selectabled: true
    property bool isBrowseMode: false

    signal selectedResult()
}
