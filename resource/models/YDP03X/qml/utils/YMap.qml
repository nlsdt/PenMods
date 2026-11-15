import QtQuick 2.12

QtObject {
    function count() {
        return size()
    }

    function size() {
        return Object.keys(__elements).length
    }

    function isEmpty() {
        return Object.keys(__elements).length < 1
    }

    function clear() {
         __keyArray = []
        Object.keys(__elements).forEach(function (key) {
          delete __elements[key];
        });
    }

    function put(key, value) {
        if (__keyArray.indexOf(key) === -1){
              __keyArray.push(key)
        }
        __elements[key] = value
    }

    function insert(key, value) {
        put(key, value)
    }

    function remove(key) {
        let index = __keyArray.indexOf(key);
        if (index !== -1){
            __keyArray.splice(index, 1)
        }
        delete __elements[key]
    }

    function value(key) {
        return __elements[key]
    }

    function get(key) {
        return value(key)
    }

    function take(key) {
        const v = value(key)
        remove(key)
        return v
    }

    function key(value) {
        for(var key in __elements) {
            if (__elements[key] === value) {
                return key
            }
        }
        return null
    }

    function containsKey(key) {
        if (0 === size()) {
            return false
        }
        return (key in __elements)
    }

    function containsValue(value) {
        if (0 === size()) {
            return false
        }
        return (-1 !== values().indexOf(value));
    }

    function values() {
        var vals = Object.keys(__elements).map(function (key) {
            return __elements[key];
        });
        return vals;
    }

    function keys() {
        return Object.keys(__elements)
    }

    function top(key) {
        const v = take(key)
        put(key, v)
        return v
    }

    function topKey() {
        if (__keyArray.length > 0){
            return __keyArray[__keyArray.length - 1]
        }
        else if (count() > 0) {
            return keys()[count() - 1]
        }
        return null
    }

    function pop(key) {
        if ((count() > 0) && containsKey(key)) {
            return take(key)
        }
        return null
    }

    property var __keyArray: []
    readonly property var __elements: new Object
}
