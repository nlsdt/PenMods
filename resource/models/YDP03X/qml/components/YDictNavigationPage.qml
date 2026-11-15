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
    property int cellHeight: 60
    property int rightX: 20
    property alias isShowLoadMoreButton: id_loadMor_button.visible
    id: id_navigation_item
    x: YBaseEnum.Screen.Width - rightX
    z: 1000
    width: navigationWidth
    height: navigationHeight
    state: "close"
    visible: false
    clip: true

    property bool isMove : false

    signal navigationSendToDictPageItem(var title, var type, var subType, var dictNode)

    readonly property bool isOpening: ("open" === state)

    property alias fastBlurTarget: id_fast_blur.source

    property bool isShow: false

    property bool isShowload: true

    property int resDictNum: 0
    Connections{
        enabled: true
        ignoreUnknownSignals: true
        target: resultManager
        function onIsAllLoadedDicts( isAllLoaded ){
            isShowload = isAllLoaded
        }

        function onSearchDictResultsChenged( dictSize ){
            resDictNum = dictSize
        }
    }

    function packUpDictNav(){
        console.log("seven:packUpDictNav")
        id_navigation_item.x = YBaseEnum.Screen.Width - rightX
        isShow = false
        isMove = false
    }

    function showDictNav(){
        id_navigation_item.x = YBaseEnum.Screen.Width - navigationWidth
        isShow = true
        isMove = true
        console.log("seven:showDictNav")
        dictNodeAdjust()
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

    //词典节点矫正（可能某些节点在动态加载释被隐藏）
    function dictNodeAdjust(){
        var arr = []
        for(var i = 0; i < id_dictNavigationModel.count ; ++i){
//            console.log("seven:dictNodeAdjust")
            var Node = id_dictNavigationModel.get(i)
            console.log("seven:dictNodeAdjust:",":dictNode:",Node.dictNode,"type:",Node.type,":subType:",Node.subType,":title:",Node.title)
            if((Node.dictNode == null) || (Node.subType === 1 && Node.dictNode.visible === false)) {
                id_dictNavigationModel.remove(i,1)
                --i
                console.log("seven:dictNodeAdjust:item removed,","type:",Node.type,":subType:",Node.subType,":title:",Node.title)
            }
        }

    }

    YMouseArea {
        anchors.fill: parent
        drag.target: id_navigation_item
        drag.axis: Drag.XAxis
        drag.minimumX: YBaseEnum.Screen.Width - navigationWidth
        drag.maximumX: YBaseEnum.Screen.Width - rightX
        objectName: "YDictNavigationPage.qml_YMouseArea"

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
            objectName: "YDictNavigationPage.qml_id_check_timer"
        }

        function doReleased() {
            console.log("seven:mouseX",mouseX)
            isMove = true
            var thrValueX = isShow ?  YBaseEnum.Screen.Width - (navigationWidth / 4) * 3 : YBaseEnum.Screen.Width - (navigationWidth / 4)
            if(id_navigation_item.x < thrValueX){
                showDictNav()
            }else{
                packUpDictNav()
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
    property int selectedIndex: 0//当前选中的的item
    property alias dictNavigationModel: id_dictNavigationModel//id_dict_title_repeater.model

    ListModel {
        id: id_dictNavigationModel
    }

    function clearDictItems(){
        var dictItems = []
        dictNavigationModel = dictItems
    }
    function addDictItem( title, ofsetY){
        dictNavigationModel.append({"title":title,"ofsetY":ofsetY})
    }

    function setCurrentIndex(currentIndex){
        selectedIndex = currentIndex
        var cellItem = id_dict_title_repeater.itemAt(selectedIndex)
        var nav_gY = id_dict_reactagle.mapFromItem(cellItem, 0, 0).y
        if(nav_gY >= 0 && nav_gY <= (id_dict_reactagle.height - cellHeight)){
            return
        }
        var ofsetY = id_dictList_Flickble.mapFromItem(cellItem, 0, 0 + id_dictList_Flickble.contentY).y
        var max_ofetY = id_dictList_Flickble.contentHeight - YBaseEnum.Screen.Height
        /*id_dictList_Flickble.contentY*/g_nav_y = ofsetY >= max_ofetY ? max_ofetY : ofsetY
        id_dict_nav_animator.restart()
    }

    function updateDisplayStatus(){
        visible = dictNavigationModel.count !== 0
    }

    property int g_nav_y: 0
    PropertyAnimation {
        id: id_dict_nav_animator
        target: id_dictList_Flickble
        property: "contentY"
        from: id_dictList_Flickble.contentY
        to: g_nav_y
        duration: 120
        running: false
        alwaysRunToEnd: true
    }

    Rectangle {
        id: id_dict_reactagle
        anchors.fill: parent
        color: isMove ?  "#1A1B1F" : "transparent"
//        color: "red"
        radius : 10
        Rectangle{
            anchors.left:  parent.left
            anchors.top: parent.top
            anchors.right: id_dictList_Flickble.left
            anchors.bottom: parent.bottom
            color: "transparent"

            Rectangle{
                width: 6
                height: 60
                color: "#2D2E33"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                radius : width / 2
            }
        }

        Flickable{
            id: id_dictList_Flickble
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: showButtonArea
            anchors.rightMargin: 48
//            width: parent.width - showButtonArea
            contentHeight: id_dict_title_colum.height

            Shape {
                width: 10
                x: 13
                ShapePath {
                    strokeColor: "#909199"
                    strokeWidth: 1
                    dashPattern: [1.97, 3.95]
                    strokeStyle: ShapePath.DashLine
                    startX: 0
                    startY: cellHeight / 2
                    PathLine {
                        x: 0
                        y: {
//                            var lastOfsetY = id_dictList_Flickble.mapFromItem(0,0,id_dictNavigationModel[id_dictNavigationModel.count - 1].dictNode)
                            if(isShowload)
                                return id_dictList_Flickble.contentHeight -  cellHeight / 2
                            else
                                return id_dictList_Flickble.contentHeight -  cellHeight / 2 - 41 - 70
                        }
                    }
                }
            }
            Column{
                id: id_dict_title_colum
                width: parent.width
//                spacing: 20
                Repeater{
                    id: id_dict_title_repeater
//                    model: ["1231","2312","123231243"]
                    model: id_dictNavigationModel
                    Rectangle{
                        width: parent.width
                        height: cellHeight
                        color: YColors.transparent
                        Rectangle{
                            id: id_status_rund_lable
//                            anchors.verticalCenter: parent.verticalCenter
//                            anchors.left: parent.left
//                            width: subType ===0 ? 10 : 6
//                            height: width
//                            color: index === selectedIndex ? "#FF881B" : "#FFFFFF"
//                            radius: width / 2
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            width: 26
                            color: YColors.transparent

                            Rectangle {
                                id: id_dictType_status
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: parent.width
                                color: index === selectedIndex ? "#FF881B" : "#FFFFFF"
                                radius: 4
                                visible: subType === 0

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: -5
                                    height: 3
                                    radius: 1.5
                                    color: "#E6000000"
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: 5
                                    height: 3
                                    radius: 1.5
                                    color: "#E6000000"
                                }


                            }

                            Rectangle {
                                id: id_dictSubType_status
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 8
                                height: 8
                                color: index === selectedIndex ? "#FF881B" : "#909199"
                                radius: width / 2
                                visible: !id_dictType_status.visible
                            }

                        }
                        YText{
                            id: id_feedBack_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: id_status_rund_lable.right
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.leftMargin: 20
                            text: title
                            color:{
                                if (subType === 0){
                                    return index === selectedIndex ? "#FF881B" : "#FFFFFF"
                                }else {
                                    return index === selectedIndex ? "#FF881B" : "#A8AAB2"
                                }
                            }
                            font.pixelSize: 28//subType === 0 ? 28 : 26
                            verticalAlignment:Text.AlignVCenter
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                id_navigation_item.selectedIndex = index
                                navigationSendToDictPageItem(title ,
                                                             type,
                                                             subType,
                                                             dictNode)
                            }
                        }
                    }
                }

                Rectangle{
                    id: id_loadMor_button
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: -33
                    anchors.rightMargin: -16
                    height: 70
                    color: "#2D2E33"
                    radius: 7
                    visible: !isShowload//dictItemCount > 3 ? true : false
                    YText{
                        id: id_loadMor_title
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        textFormat: YText.RichText
                        text: YTranslateText.navTotal.arg(resDictNum)
                        color: "#FF881B"
                        font.pixelSize: 24
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment : Text.AlignHCenter
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
//                            id_loadMor_button.visible = false
                            resultManager.loadAllDicts()
                            dictNodeAdjust()
                        }
                    }

                }


                YSpacingForColumn{
                    height: 41
                    visible: id_loadMor_button.visible
                }
            }
        }
    }
}
