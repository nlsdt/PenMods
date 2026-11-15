import QtQuick 2.12

Loader {
    asynchronous: true
    active: false

    function setActive() {
        active = true
    }

    function setInactive() {
        active = false
    }

    readonly property bool isLoaded: status === YLoader.Ready
}
