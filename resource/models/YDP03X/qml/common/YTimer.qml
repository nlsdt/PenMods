import QtQuick 2.12

Timer {
    // objectName needs to be set
    onRunningChanged: {
        console.log("YTimer.qml===child===timer===objectName: ",
                    objectName, "===running: ", (running ? "start" : "stop"))
    }
}
