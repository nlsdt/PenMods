pragma Singleton

import QtQuick 2.12

// global color defineds, use as colorDefineds

QtObject {

    readonly property string black: "#000000"
    readonly property string white: "#FFFFFF"
    readonly property string transparent: "transparent"

    readonly property string red: "#F03043"
    readonly property string orange: "#FF8B20"

    readonly property Gradient redDict: Gradient {
        GradientStop { position: 0.0; color: "#FA423C" }
        GradientStop { position: 1.0; color: "#F03043" }
    }
    readonly property Gradient yellowDict: Gradient {
        GradientStop { position: 0.0; color: "#FF8B20" }
        GradientStop { position: 1.0; color: "#FF7E08" }
    }

    readonly property Gradient transParentDict: Gradient {
        GradientStop { position: 0.0; color: "transparent" }
        GradientStop { position: 1.0; color: "transparent" }
    }

    readonly property string green: "#13B876"

    readonly property string yellow: "#E9900C"

    readonly property string blueText: "#509DEB"
    readonly property string blueRect: "#2D73DC"
    readonly property string wordBlue: "#5B7FFF"

    readonly property string grayText: "#909199"
    readonly property string grayNormal: "#1A1B1F"
    readonly property string graySwitchOff: "#515259"
    readonly property string grayButton: "#2D2E33"
    readonly property string switchOff: "#41434D"
    readonly property string switchOn: "#5687FF"

    readonly property string touchReadingBg: "#151626"
    readonly property string highlight: "#644FEC"
    readonly property string confirm: "#FF7E08"

    readonly property string touchRegulatorBackgroundPressed: "#0AFFFFFF"
    readonly property string touchRegulatorBackground: "#222328"
    readonly property string touchRegulatorForeground: "#FF7E08"
    readonly property string touchRegulatorProgressDirection: "#4DFFFFFF"

    readonly property string buttonNormal: "#36373D"
    readonly property string buttonDisabled: "#1A1B1F"
    readonly property string settingItemBackground: "#BE1A1B1F"

    readonly property string audioRepeatProgressBar: "#644FEC"
    readonly property string audioProgressBarBackGround: "#484848"

}
