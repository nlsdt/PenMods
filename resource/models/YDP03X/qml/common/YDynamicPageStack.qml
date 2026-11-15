import QtQuick 2.12

Item {
    id: root

    property string logTag: "YDynamicPageStack"
    property var popItemObject: null
    property int count: 0
    property int pendingCount: 0
    property var _pageStack: []
    property var _activeObjects: ({})
    property var _connectionCleanups: ({})
    property var _pendingCreates: ({})

    signal closeSameItem(string popStackId)

    function updateStackInfo() {
        count = _pageStack.length
        popItemObject = _pageStack.length > 0
                ? _pageStack[_pageStack.length - 1] : null
    }

    function _updatePendingCount() {
        pendingCount = Object.keys(_pendingCreates).length
    }

    function _isCurrentPending(popStackId, pending) {
        return !pending.cancelled && _pendingCreates[popStackId] === pending
    }

    function _finishPending(popStackId, pending) {
        if (_pendingCreates[popStackId] !== pending)
            return false

        delete _pendingCreates[popStackId]
        _updatePendingCount()
        return true
    }

    function _destroyPendingComponent(pending) {
        if (!pending.component)
            return

        const component = pending.component
        pending.component = null
        try {
            component.destroy()
        } catch (error) {
            console.warn(logTag + " component cleanup failed:", error)
        }
    }

    function _discardPendingObject(pending, incubatorObject) {
        if (incubatorObject) {
            try {
                if (incubatorObject.hasOwnProperty("visible"))
                    incubatorObject.visible = false
                incubatorObject.destroy(1)
            } catch (error) {
                console.warn(logTag + " stale page cleanup failed:", error)
            }
        }
        _destroyPendingComponent(pending)
    }

    function _cancelPending(popStackId) {
        const pending = _pendingCreates[popStackId]
        if (!pending)
            return

        delete _pendingCreates[popStackId]
        pending.cancelled = true
        _updatePendingCount()

        if (pending.componentStatusCallback && pending.component) {
            try {
                pending.component.statusChanged.disconnect(
                            pending.componentStatusCallback)
            } catch (error) {}
            pending.componentStatusCallback = null
        }

        // An active incubator must finish before its Component can be released.
        if (!pending.incubator)
            _destroyPendingComponent(pending)
    }

    function _cleanupConnections(popStackId) {
        if (!_connectionCleanups.hasOwnProperty(popStackId))
            return

        const cleanups = _connectionCleanups[popStackId]
        delete _connectionCleanups[popStackId]
        for (let i = 0; i < cleanups.length; ++i) {
            try {
                cleanups[i]()
            } catch (error) {
                console.warn(logTag + " cleanup failed:", error)
            }
        }
    }

    function _removeFromStack(incubatorObject) {
        const index = _pageStack.indexOf(incubatorObject)
        if (index >= 0)
            _pageStack.splice(index, 1)
    }

    function _releaseObject(incubatorObject, popStackId) {
        if (_activeObjects[popStackId] !== incubatorObject)
            return false

        delete _activeObjects[popStackId]
        _removeFromStack(incubatorObject)
        updateStackInfo()
        _cleanupConnections(popStackId)
        return true
    }

    function _safeDestroy(incubatorObject) {
        if (!incubatorObject)
            return

        const popStackId = incubatorObject.popStackId || ""
        if (!_releaseObject(incubatorObject, popStackId))
            return

        try {
            incubatorObject.visible = false
            incubatorObject.destroy(1)
        } catch (error) {
            console.warn(logTag + " destroy failed:", error)
        }
    }

    function _registerObject(incubatorObject, popStackId, cleanups) {
        if (!incubatorObject || !popStackId)
            return false

        if (_activeObjects[popStackId]
                && _activeObjects[popStackId] !== incubatorObject) {
            _safeDestroy(_activeObjects[popStackId])
        }

        if (typeof incubatorObject.popStackId === "undefined") {
            Object.defineProperty(incubatorObject, "popStackId", {
                enumerable: false,
                configurable: false,
                writable: false,
                value: popStackId
            })
        }

        _activeObjects[popStackId] = incubatorObject
        _connectionCleanups[popStackId] = cleanups || []
        _pageStack.push(incubatorObject)
        updateStackInfo()

        incubatorObject.Component.destruction.connect(function() {
            _releaseObject(incubatorObject, popStackId)
        })
        return true
    }

    function registerPage(incubatorObject, popStackId, options) {
        if (!incubatorObject)
            return false

        const config = options || {}
        const cleanups = config.cleanups ? config.cleanups.slice() : []

        if (typeof config.pageIndex === "number" && config.pageIndex >= 0) {
            const onRequestShowPage = function(index, cachePage) {
                if (config.pageIndex !== index)
                    root._safeDestroy(incubatorObject)
            }
            qmlGlobal.requestShowPage.connect(onRequestShowPage)
            cleanups.push(function() {
                qmlGlobal.requestShowPage.disconnect(onRequestShowPage)
            })
        }

        if (incubatorObject.hasOwnProperty("backButtonClicked")) {
            const onBackButtonClicked = function() {
                root._safeDestroy(incubatorObject)
            }
            incubatorObject.backButtonClicked.connect(onBackButtonClicked)
            cleanups.push(function() {
                incubatorObject.backButtonClicked.disconnect(onBackButtonClicked)
            })
        }

        if (config.closeOnHomeRelease) {
            const onHomeKeyRelease = function() {
                root._safeDestroy(incubatorObject)
            }
            systemBase.homeKeyRelease.connect(onHomeKeyRelease)
            cleanups.push(function() {
                systemBase.homeKeyRelease.disconnect(onHomeKeyRelease)
            })
        }

        if (config.closeOnHomeLongPress) {
            const onHomeKeyLongPress = function() {
                root._safeDestroy(incubatorObject)
            }
            systemBase.homeKeyLongPress.connect(onHomeKeyLongPress)
            cleanups.push(function() {
                systemBase.homeKeyLongPress.disconnect(onHomeKeyLongPress)
            })
        }

        if (config.component) {
            cleanups.push(function() {
                config.component.destroy()
            })
        }

        return _registerObject(incubatorObject, popStackId, cleanups)
    }

    function createPage(componentUrl, popStackId, options, properties, onReady) {
        closeSameItem(popStackId)

        const component = Qt.createComponent(componentUrl)
        const pending = {
            "cancelled": false,
            "component": component,
            "componentStatusCallback": null,
            "incubator": null
        }
        _pendingCreates[popStackId] = pending
        _updatePendingCount()

        function initializePage(incubatorObject) {
            if (!_isCurrentPending(popStackId, pending)) {
                _discardPendingObject(pending, incubatorObject)
                return null
            }

            _finishPending(popStackId, pending)
            if (!incubatorObject) {
                _destroyPendingComponent(pending)
                return null
            }

            const config = {}
            const sourceOptions = options || {}
            Object.keys(sourceOptions).forEach(function(key) {
                config[key] = sourceOptions[key]
            })
            config.component = component

            if (!registerPage(incubatorObject, popStackId, config)) {
                incubatorObject.destroy(1)
                _destroyPendingComponent(pending)
                return null
            }

            if (typeof incubatorObject.show === "function")
                incubatorObject.show()
            else if (incubatorObject.hasOwnProperty("visible"))
                incubatorObject.visible = true

            if (typeof onReady === "function")
                onReady(incubatorObject)
            return incubatorObject
        }

        function incubatePage() {
            if (!_isCurrentPending(popStackId, pending))
                return null

            const incubator = component.incubateObject(root, properties || {})
            pending.incubator = incubator
            if (incubator.status === Component.Ready)
                return initializePage(incubator.object)
            if (incubator.status === Component.Error) {
                _finishPending(popStackId, pending)
                _destroyPendingComponent(pending)
                return null
            }

            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready)
                    initializePage(incubator.object)
                else if (status === Component.Error) {
                    _finishPending(popStackId, pending)
                    _destroyPendingComponent(pending)
                }
            }
            return null
        }

        if (component.status === Component.Ready)
            return incubatePage()

        if (component.status === Component.Loading) {
            const onComponentStatusChanged = function() {
                if (component.status === Component.Loading)
                    return

                component.statusChanged.disconnect(onComponentStatusChanged)
                pending.componentStatusCallback = null
                if (!_isCurrentPending(popStackId, pending)) {
                    _destroyPendingComponent(pending)
                    return
                }

                if (component.status === Component.Ready)
                    incubatePage()
                else {
                    console.error(logTag + " component error:",
                                  component.errorString())
                    _finishPending(popStackId, pending)
                    _destroyPendingComponent(pending)
                }
            }
            pending.componentStatusCallback = onComponentStatusChanged
            component.statusChanged.connect(onComponentStatusChanged)
            return null
        }

        console.error(logTag + " component error:", component.errorString())
        _finishPending(popStackId, pending)
        _destroyPendingComponent(pending)
        return null
    }

    function closeCurrentPage() {
        _safeDestroy(popItemObject)
    }

    function closeAllPages() {
        const pendingKeys = Object.keys(_pendingCreates)
        for (let pendingIndex = 0; pendingIndex < pendingKeys.length;
             ++pendingIndex) {
            _cancelPending(pendingKeys[pendingIndex])
        }

        const pages = _pageStack.slice()
        for (let i = pages.length - 1; i >= 0; --i)
            _safeDestroy(pages[i])
    }

    onCloseSameItem: {
        _cancelPending(popStackId)
        _safeDestroy(_activeObjects[popStackId])
    }
}
