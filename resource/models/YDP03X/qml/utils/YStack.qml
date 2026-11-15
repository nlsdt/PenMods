import QtQuick 2.12

QtObject {
    property var __private_items: []

    function size() {
        return __private_items.length
    }

    // count(): 获取栈中元素的个数
    function count() {
        return size()
    }

    function isEmpty() {
        return 0 === size()
    }

    // push()：给 Stack 类添加元素
    function push(element) {
        __private_items.push(element)
    }

    // pop(): 从栈顶取出元素
    function pop() {
        if (isEmpty()) {
            return null
        }
        return __private_items.pop()
    }

    // get(index): 从栈中取出指定元素
    function get(index) {
        if (index >= 0 && index < size()) {
            let element = __private_items[index]
            return element
        }
        return null
    }

    // remove(index): 从栈中移除指定元素
    function remove(index) {
        return __private_items.splice(index, 1)
    }

    // toString(): 以字符串形式输出栈内数据
    function toString() {
        let resultString = ''
        for (const i of __private_items){
            resultString += i + ' '
        }
        return resultString
    }

    // shift(): 从栈底取出元素
    function shift() {
        if (isEmpty()) {
            return null
        }
        return __private_items.shift()
    }

    // clear(callback): 清空栈，callback(item, index)
    function clear(callback) {
        if (!isEmpty()) {
            if (typeof callback != "undefined") {
                let index = 0
                for (let item of __private_items){
                    callback(item, index)
                    ++index
                }
            }
        }
        __private_items = []
    }

    function filter(callback) {
        if (isEmpty()) {
            return null
        }
        return __private_items.filter(callback)
    }

    function indexOf(item) {
        if (isEmpty()) {
            return -1
        }
        return __private_items.indexOf(item)
    }

    function top(item) {
        const i = indexOf(item)
        push(remove(i))
    }

    function take(item) {
        const i = indexOf(item)
        return remove(i)
    }

    function getTopValue() {
        if (count() > 0) {
            return get(count() - 1)
        }
        return null
    }
}
