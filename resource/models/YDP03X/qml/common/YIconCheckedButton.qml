import QtQuick 2.12

YIconButton {
    id: id_icon_checked_button

    property bool checked: false
    property string checkedIcon: ""
    property string icon: "" // override

    onValidClicked: {
        checked = !checked
    }

    Component.onCompleted: {
        buttonTimer.interval = 300
        buttonIconItem.imageName = Qt.binding(function(){
            return checked ? checkedIcon : icon
        })
    }
}
