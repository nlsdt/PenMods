import QtQuick 2.12

Rectangle {
    id: id_cursor_context
    implicitWidth: 3
    implicitHeight: 32
    opacity: 0
    color: YColors.blueText

    property alias running: id_id_cursor_context_animation.running

    SequentialAnimation {
        id: id_id_cursor_context_animation
        running: false
        loops: SequentialAnimation.Infinite
        ScriptAction { script: id_cursor_context.opacity = 1 }
        PauseAnimation { duration: 600 }
        ScriptAction { script: id_cursor_context.opacity = 0 }
        PauseAnimation { duration: 600 }
    }
}
