import QtQuick 2.12
import BaseQml 1.0
import "../common"

YSettingItemPage {
    id: page
    property string title: ""
    default property alias settingsContent: form.data
    readonly property alias pageHost: host

    function openPage(name, properties) { host.openPage(name, properties); }
    function editText(prompt, initial, accepted, secret, allowEmpty) {
        host.editText(prompt, initial, accepted, secret, allowEmpty);
    }
    function confirmAction(message, accepted) { host.confirmAction(message, accepted); }

    data: [
        Flickable {
            id: scroll
            anchors.fill: parent
            anchors.leftMargin: 90
            anchors.rightMargin: 16
            clip: true
            contentWidth: width
            contentHeight: heading.height + form.height
            boundsBehavior: Flickable.StopAtBounds
            YSettingItemTitle {
                id: heading
                title: page.title
            }
            Column {
                id: form
                anchors.top: heading.bottom
                width: scroll.width
                spacing: 8
            }
        },
        PenModsPageHost {
            id: host
            anchors.fill: parent
            z: 10
            onOperationFailed: baseSignals.showToast(message, YColors.yellow)
        }
    ]
}
