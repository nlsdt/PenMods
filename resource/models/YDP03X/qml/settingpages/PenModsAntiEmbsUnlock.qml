import QtQuick 2.12
import "../common"

// The fourth Home press requests unlocking. Show the keyboard only after its
// release has finished closing pages, otherwise that release closes it too.
PenModsPageHost {
    id: host
    property bool unlockPending: false

    function showPendingUnlock() {
        if (!unlockPending) return;
        unlockPending = false;
        if (!antiEmbs.active || inputItem) return;
        editAntiEmbsUnlock();
    }

    onOperationFailed: baseSignals.showToast(message, YColors.yellow)

    Connections {
        target: antiEmbs
        function onDeactivationUnlockRequested() {
            if (!host.inputItem) host.unlockPending = true;
        }
        function onActiveChanged() {
            if (!antiEmbs.active) {
                host.unlockPending = false;
                host.cancelInput();
            }
        }
    }
    Connections {
        target: systemBase
        function onHomeKeyRelease() {
            if (host.unlockPending) Qt.callLater(host.showPendingUnlock);
        }
    }
}
