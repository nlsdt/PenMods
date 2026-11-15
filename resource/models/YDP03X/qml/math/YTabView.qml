import QtQuick 2.12
import BaseQml 1.0

YItem {
    id: id_tab_view
    property int currentIdx: 0
    property var headerComponent: null
    property int headerViewHeight: 80
    property var headerView: null
    property var headerTitles: []
    property bool controlValidSubView: false
    property var validSubviews:[]
    default property alias contentViews: id_content_view.children
    readonly property int tabViewHeight: {
        let totalHeight = 0
        if (contentViews.length > 0) {
            totalHeight += id_tab_view.headerViewHeight + contentViews[getValidIndex()].height
        } else {
            totalHeight += id_tab_view.headerViewHeight
        }
        return totalHeight
    }


    YItem {
        id: id_header_view
        height: id_tab_view.headerViewHeight
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    YItem {
        id: id_content_view
        anchors.top: id_header_view.bottom
        anchors.bottom: id_tab_view.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    onCurrentIdxChanged: {
        updateHeaderView()
        updateContentView()
    }

    Component.onCompleted: {
        setupHeaderView()
        pinContentView()
        updateIndexes()
        updateHeaderView()
        updateContentView()
    }

    function setupHeaderView() {
        let titles = id_tab_view.headerTitles
        if (id_tab_view.headerComponent !== null) {
            let properties = {
                "titles": titles,
                "currentIdx": id_tab_view.currentIdx,
            }
            let createdHeader = id_tab_view.headerComponent.createObject(id_header_view, properties)
            createdHeader.anchors.fill = id_header_view
            createdHeader.itemClicked.connect(headerViewIdxChanged)
            id_tab_view.headerView = createdHeader
        }
    }

    // Tab 的高度是根据各个显示的 SubView 变化的, 所以不能让 SubView 四边贴紧.
    // 通过 tabViewHeight 的变化影响到 TabView 的容器, 让 TabView 可以完全展示.
    function pinContentView() {
        for (let i = 0; i < contentViews.length; ++i) {
            let itemContentView = contentViews[i]
            itemContentView.anchors.left = id_content_view.left
            itemContentView.anchors.right = id_content_view.right
            itemContentView.anchors.top = id_content_view.top
        }
    }

    function headerViewIdxChanged(idx) {
        id_tab_view.currentIdx = idx
    }

    function updateIndexes() {
        if (!controlValidSubView) {
            validSubviews = []
            for (let i = 0; i < id_content_view.children.length; ++i) {
                validSubviews.push(i)
            }
        }
    }

    function updateHeaderView() {
        if (id_tab_view.headerView !== null) {
            id_tab_view.headerView.currentIdx = id_tab_view.currentIdx
        }
    }

    function updateContentView() {
        let validIdx = 0
        for (let i = 0; i < id_content_view.children.length; ++i) {
            id_content_view.children[i].visible = (i === getValidIndex())
        }
    }

    function getValidIndex() {
        if (!controlValidSubView) {
            return currentIdx
        } else {
            let validIdx = 0
            for (let i = 0; i < id_content_view.children.length; ++i) {
                if (!validSubviews.contains(i)) {
                    continue
                }
                if (validIdx === currentIdx) { return i }
                validIdx = validIdx + 1
            }
            return currentIdx
        }
    }
}
