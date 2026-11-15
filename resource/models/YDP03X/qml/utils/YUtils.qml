pragma Singleton
import QtQuick 2.12

// 内部方法，尽量不要使用
QtObject {
    // 缓存主动要求缓存的页面
    property QtObject globalMap: null

    // 缓存栈中的页面对象
    property QtObject stackMap: null

    // 栈视图对象
    property QtObject stackView: null

    // 当前显示的栈 id
    property string currentPopId: ""

    function clearStackView() {
        YUtils.stackMap.clear()
        YUtils.currentPopId = ""
    }

    function removeKey(key, notLoadTop) {
        if ((key.length > 0) && stackMap.containsKey(key)) {
            console.warn("YUtils.qml===removeKey: ", key)
            const item = stackMap.pop(key)
            if ((typeof notLoadTop == "undefined") || !notLoadTop) {
                if (null !== item) {
                    const v = stackMap.topKey()
                    currentPopId = (v !== null) ? v : ""
                } else {
                    currentPopId = ""
                }
            }
            console.warn("YUtils.qml===currentPopId: ", currentPopId)
        }
    }
}
