pragma Singleton
import QtQuick 2.12
import BaseQml 1.0

Item {
    function delayCall( interval, callback ) {
        const delayCaller = id_delay_caller_component.createObject(
                              null, { "interval": interval } );
        delayCaller.triggered.connect( function () {
            if (typeof delayCaller.destroy != "undefined") {
                callback();
                delayCaller.destroy();
            }
        } );
        delayCaller.start();
    }

    Component {
        id: id_delay_caller_component
        YTimer {
            objectName: "id_delay_caller_timer"
        }
    }
}
