import QtQuick 2.12

PenModsSettingRow {
    showSwitch: true
    signal rowToggled(bool checked)
    // Keep checked bound to the backend, including failed writes and external changes.
    onClicked: rowToggled(!checked)
}
