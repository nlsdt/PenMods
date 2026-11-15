import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14
import QtQuick.Shapes 1.14
import BaseQml 1.0
import "../timers"
import "../i18n"

Item {
    property int showButtonArea: 62 // 显示导航条button宽度
    property int navigationWidth: 300 //导航页面宽度
    property int navigationHeight: YBaseEnum.Screen.Height //高度和屏幕高度一致
    property int cellHeight: 66
    property int rightX: 20

    id: id_navigation_item
    x: YBaseEnum.Screen.Width - rightX
    z: 1000
    width: navigationWidth
    height: navigationHeight
    state: "close"
    visible: false
    clip: true

    property bool isMove : false
    readonly property bool isOpening: ("open" === state)
    property alias fastBlurTarget: id_fast_blur.source
    property bool isShow: false
    property bool isShowload: true

    signal navigationSendToPage(var index)

    function packUpNavigation(){
        id_navigation_item.x = YBaseEnum.Screen.Width - rightX
        isShow = false
        isMove = false
    }

    function showNavigation(){
        id_navigation_item.x = YBaseEnum.Screen.Width - navigationWidth
        isShow = true
        isMove = true
    }

    function isOpen(){
        return id_navigation_item.x === YBaseEnum.Screen.Width - navigationWidth
    }

    function close() {
        if ("open" === state) {
            forceClose()
        }
    }

    function open() {
        if ("close" === state) {
            reopen()
        }
    }

    function reopen() {
        visible = true
        state = "openning"
        id_open_close_animator.to = YBaseEnum.Screen.Width - navigationWidth
        id_open_close_animator.restart()
    }

    function forceClose() {
        state = "closing"
        id_open_close_animator.to = YBaseEnum.Screen.Width - rightX
        id_open_close_animator.restart()
    }

    YMouseArea {
        anchors.fill: parent
        drag.target: id_navigation_item
        drag.axis: Drag.XAxis
        drag.minimumX: YBaseEnum.Screen.Width - navigationWidth
        drag.maximumX: YBaseEnum.Screen.Width - rightX
        objectName: "YMathExerciseNavigation.qml_YMouseArea"

        property real pressedX: 0
        onPressed: {
            pressedX = id_navigation_item.x
            id_check_timer.restart()
            isMove = true
        }

        onReleased: {
            doReleased()
        }

        onCanceled: {
            doReleased()
        }

        YTimer {
            id: id_check_timer
            interval: 300
            objectName: "YMathExerciseNavigation.qml_id_check_timer"
        }

        function doReleased() {
            isMove = true
            var thrValueX = isShow ?  YBaseEnum.Screen.Width - (navigationWidth / 4) * 3
                                   : YBaseEnum.Screen.Width - (navigationWidth / 4)
            if (id_navigation_item.x < thrValueX) {
                showNavigation()
            } else {
                packUpNavigation()
            }
        }
    }

    PropertyAnimation {
        id: id_open_close_animator
        target: id_navigation_item
        property: "x"
        from: isOpen() ? YBaseEnum.Screen.Width - navigationWidth : YBaseEnum.Screen.Width - rightX
        to:  isOpen() ? YBaseEnum.Screen.Width - rightX : YBaseEnum.Screen.Width - navigationWidth
        duration: 120
        running: false
        alwaysRunToEnd: true
        onRunningChanged: {
            if (!running) {
                if ("openning" === id_navigation_item.state) {
                    id_navigation_item.state = "open"
                } else if ("closing" === id_navigation_item.state) {
                    id_navigation_item.state = "close"
                }
            }
        }
    }

    FastBlur {
        id: id_fast_blur
        anchors.fill: parent
        radius: 16
    }
    property int selectedIndex: 0 //当前选中的的item
    property alias navigationModel: id_navigation_list_model

    ListModel {
        id: id_navigation_list_model
    }

    function setCurrentIndex(currentIndex){
        selectedIndex = currentIndex
        var cellItem = id_navigation_title_repeater.itemAt(selectedIndex)
        var nav_gY = id_rectangle_bg.mapFromItem(cellItem, 0, 0).y
        if(nav_gY >= 0 && nav_gY <= (id_rectangle_bg.height - cellHeight)){
            return
        }
        var ofsetY = id_navigation_flickble.mapFromItem(cellItem, 0, 0 + id_navigation_flickble.contentY).y
        var max_ofetY = id_navigation_flickble.contentHeight - YBaseEnum.Screen.Height
        g_nav_y = ofsetY >= max_ofetY ? max_ofetY : ofsetY
        id_nav_animator.restart()
    }

    function updateDisplayStatus(){
        visible = navigationModel.count !== 0
    }

    property int g_nav_y: 0

    PropertyAnimation {
        id: id_nav_animator
        target: id_navigation_flickble
        property: "contentY"
        from: id_navigation_flickble.contentY
        to: g_nav_y
        duration: 120
        running: false
        alwaysRunToEnd: true
    }

    Rectangle {
        id: id_rectangle_bg
        anchors.fill: parent
        color: isMove ?  "#1A1B1F" : "transparent"
        radius : 10
        Rectangle {
            anchors.left:  parent.left
            anchors.top: parent.top
            anchors.right: id_navigation_flickble.left
            anchors.bottom: parent.bottom
            color: "transparent"

            Rectangle {
                width: 6
                height: 60
                color: "#2D2E33"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                radius : width / 2
            }
        }

        Flickable {
            id: id_navigation_flickble
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: showButtonArea
            anchors.rightMargin: 48
            contentHeight: id_navigation_title_col.height

            Shape {
                width: 10
                x: 13
                visible: id_navigation_flickble.contentHeight > cellHeight + 15
                ShapePath {
                    strokeColor: "#909199"
                    strokeWidth: 1
                    strokeStyle: ShapePath.DashLine
                    startX: 0
                    startY: cellHeight / 2 + 11
                    dashPattern: [1.97, 3.95]

                    PathLine {
                        x: 0
                        y: id_navigation_flickble.contentHeight -  cellHeight / 2
                    }
                }
            }

            Column {
                id: id_navigation_title_col
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 11

                Repeater{
                    id: id_navigation_title_repeater
                    model: id_navigation_list_model

                    Rectangle {
                        width: parent.width
                        height: cellHeight
                        color: YColors.transparent

                        Rectangle {
                            id: id_status_rund_lable
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            color: YColors.transparent

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 8
                                height: 8
                                color: index === selectedIndex ? "#FF881B" : YColors.white
                                radius: width / 2
                            }

                        }

                        YText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: id_status_rund_lable.right
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.leftMargin: 20
                            text: title
                            color: index === selectedIndex ? "#FF881B" : YColors.white
                            font.pixelSize: 28
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                id_navigation_item.selectedIndex = index
                                navigationSendToPage(index)
                            }
                        }
                    }
                }

                YSpacingForColumn{
                    height: 15
                }
            }
        }
    }
}
