import QtQuick 2.12
import BaseQml 1.0

Item {
    id: root
    objectName: "CapturePreviewPage.qml"
    anchors.fill: parent
    z: 2000

    readonly property int phaseWaiting: 0
    readonly property int phaseCropping: 1
    readonly property int phaseOverview: 2
    readonly property int maxFrames: 8
    readonly property int maxStoredBase64Chars: 16 * 1024 * 1024

    property int phase: phaseWaiting
    property bool pageActive: false
    property bool processing: false
    property real zoomLevel: 1.0
    property string capturedImageBase64: ""
    property var capturedImages: []
    property string currentComposite: ""
    property int compositeFrameCount: 0
    property string stitchDirection: ""
    property string pendingDirection: ""
    property string displaySource: ""
    property int operationSeq: 0
    property int activeRequestId: 0
    property string pendingOperation: ""

    readonly property bool imageLoaded: phase === phaseCropping && capturedImageBase64 !== ""
    readonly property bool compositeReady: currentComposite !== "" && compositeFrameCount === capturedImages.length
    readonly property bool needsDirection: capturedImages.length >= 2 && !compositeReady

    // 裁剪框参数 (0~1 比例, 相对于视口)
    property real cropX: 0.05
    property real cropY: 0.05
    property real cropW: 0.9
    property real cropH: 0.9
    readonly property real minCrop: 0.1

    property real imageBaseWidth: 0
    property real imageBaseHeight: 0
    readonly property real fitScale: imageBaseWidth > 0 && imageBaseHeight > 0 && flickable.width > 0 && flickable.height > 0
                                     ? Math.min(flickable.width / imageBaseWidth, flickable.height / imageBaseHeight)
                                     : 1.0
    readonly property real displayScale: fitScale * zoomLevel

    signal backButtonClicked()
    signal captureConfirmed(string base64Data)
    signal captureCancelled()

    // -------------------- 生命周期 --------------------
    function show() {
        pageActive = true;
        if (typeof qmlGlobal !== 'undefined' && qmlGlobal !== null)
            keyBoard.inputPageShowing = true;
        resetAll();
    }

    function cleanup() {
        pageActive = false;
        invalidateProcessing();
        if (typeof qmlGlobal !== 'undefined' && qmlGlobal !== null)
            keyBoard.inputPageShowing = false;
        if (typeof cameraCapture !== 'undefined' && cameraCapture !== null)
            cameraCapture.captureEnabled = false;
    }

    Component.onDestruction: cleanup()

    function updateCaptureEnabled() {
        if (typeof cameraCapture === 'undefined' || cameraCapture === null)
            return;
        cameraCapture.captureEnabled = pageActive && phase === phaseWaiting && !processing
                                       && capturedImages.length < maxFrames;
    }

    function invalidateProcessing() {
        operationSeq++;
        activeRequestId = 0;
        pendingOperation = "";
        pendingDirection = "";
        processing = false;
    }

    function resetAll() {
        invalidateProcessing();
        capturedImages = [];
        currentComposite = "";
        compositeFrameCount = 0;
        stitchDirection = "";
        phase = phaseWaiting;
        capturedImageBase64 = "";
        displaySource = "";
        cropX = 0.05; cropY = 0.05; cropW = 0.9; cropH = 0.9;
        zoomLevel = 1.0;
        imageBaseWidth = 0;
        imageBaseHeight = 0;
        flickable.contentX = 0;
        flickable.contentY = 0;
        updateCaptureEnabled();
    }

    function showError(message) {
        console.error("CapturePreviewPage:", message);
        if (typeof qmlGlobal !== 'undefined' && qmlGlobal !== null && typeof qmlGlobal.showToast === 'function')
            qmlGlobal.showToast(message, YColors.yellow);
    }

    function capturedDataSize(images) {
        var total = 0;
        for (var i = 0; i < images.length; ++i)
            total += images[i].length;
        return total;
    }

    function refreshOverviewSource() {
        if (compositeReady)
            displaySource = "data:image/jpeg;base64," + currentComposite;
        else if (capturedImages.length > 0)
            displaySource = "data:image/jpeg;base64," + capturedImages[capturedImages.length - 1];
        else
            displaySource = "";
    }

    function resetCropAndViewport() {
        cropX = 0.05; cropY = 0.05; cropW = 0.9; cropH = 0.9;
        zoomLevel = 1.0;
        Qt.callLater(function() {
            flickable.contentX = Math.max(0, (flickable.contentWidth - flickable.width) / 2);
            flickable.contentY = Math.max(0, (flickable.contentHeight - flickable.height) / 2);
        });
    }

    function setZoom(newZoom) {
        var oldWidth = Math.max(1, flickable.contentWidth);
        var oldHeight = Math.max(1, flickable.contentHeight);
        var centerRatioX = (flickable.contentX + flickable.width / 2) / oldWidth;
        var centerRatioY = (flickable.contentY + flickable.height / 2) / oldHeight;
        zoomLevel = Math.max(1.0, Math.min(5.0, newZoom));
        Qt.callLater(function() {
            flickable.contentX = Math.max(0, Math.min(flickable.contentWidth - flickable.width,
                                                       centerRatioX * flickable.contentWidth - flickable.width / 2));
            flickable.contentY = Math.max(0, Math.min(flickable.contentHeight - flickable.height,
                                                       centerRatioY * flickable.contentHeight - flickable.height / 2));
        });
    }

    function cropCurrentImage() {
        var vpW = flickable.width;
        var vpH = flickable.height;
        if (vpW <= 0 || vpH <= 0) return "";

        var iw = imageBaseWidth;
        var ih = imageBaseHeight;
        if (iw <= 0 || ih <= 0) return "";

        var imgLeft = imagePreview.x - flickable.contentX;
        var imgTop  = imagePreview.y - flickable.contentY;
        var imgRight = imgLeft + imagePreview.width;
        var imgBottom = imgTop + imagePreview.height;
        var cropLeft = cropX * vpW;
        var cropTop = cropY * vpH;
        var cropRight = (cropX + cropW) * vpW;
        var cropBottom = (cropY + cropH) * vpH;
        var intersectionLeft = Math.max(cropLeft, imgLeft);
        var intersectionTop = Math.max(cropTop, imgTop);
        var intersectionRight = Math.min(cropRight, imgRight);
        var intersectionBottom = Math.min(cropBottom, imgBottom);

        if (intersectionRight <= intersectionLeft || intersectionBottom <= intersectionTop)
            return null;

        var px = Math.round((intersectionLeft - imgLeft) / displayScale);
        var py = Math.round((intersectionTop - imgTop) / displayScale);
        var pw = Math.round((intersectionRight - intersectionLeft) / displayScale);
        var ph = Math.round((intersectionBottom - intersectionTop) / displayScale);

        px = Math.max(0, Math.min(iw - 1, px));
        py = Math.max(0, Math.min(ih - 1, py));
        pw = Math.max(1, Math.min(iw - px, pw));
        ph = Math.max(1, Math.min(ih - py, ph));
        return { "x": px, "y": py, "w": pw, "h": ph };
    }

    function onSaveCurrent() {
        if (!imageLoaded || !capturedImageBase64 || processing) return;
        var cropRect = cropCurrentImage();
        if (!cropRect) {
            showError("裁剪区域未覆盖图片");
            return;
        }
        if (typeof cameraCapture === 'undefined' || cameraCapture === null
                || typeof cameraCapture.cropImageAsync !== 'function') {
            showError("裁剪服务不可用");
            return;
        }

        processing = true;
        pendingOperation = "crop";
        activeRequestId = ++operationSeq;
        updateCaptureEnabled();
        cameraCapture.cropImageAsync(activeRequestId, capturedImageBase64,
                                     cropRect.x, cropRect.y, cropRect.w, cropRect.h);
    }

    function onAbandonCurrent() {
        if (processing) return;
        capturedImageBase64 = "";
        if (capturedImages.length === 0) {
            phase = phaseWaiting;
            displaySource = "";
        } else {
            phase = phaseOverview;
            refreshOverviewSource();
        }
        resetCropAndViewport();
        updateCaptureEnabled();
    }

    function onFinish() {
        if (processing) return;
        if (capturedImages.length === 0) {
            root.cleanup();
            root.captureCancelled();
            root.backButtonClicked();
            return;
        }
        if (!compositeReady) {
            phase = phaseOverview;
            refreshOverviewSource();
            showError("请先完成图片拼接");
            return;
        }
        var result = currentComposite;
        root.cleanup();
        root.captureConfirmed(result);
        root.backButtonClicked();
    }

    function onDirectionSelected(dir) {
        if (processing || capturedImages.length < 2) return;
        if (typeof cameraCapture === 'undefined' || cameraCapture === null
                || typeof cameraCapture.stitchImagesAsync !== 'function') {
            showError("拼接服务不可用");
            return;
        }

        processing = true;
        pendingOperation = "stitch";
        pendingDirection = dir;
        activeRequestId = ++operationSeq;
        updateCaptureEnabled();
        cameraCapture.stitchImagesAsync(activeRequestId, capturedImages.slice(), dir);
    }

    function onClear() {
        if (processing) return;
        resetAll();
    }

    function onContinueCapture() {
        if (processing) return;
        if (capturedImages.length >= maxFrames) {
            showError("最多可拍摄 " + maxFrames + " 帧");
            return;
        }
        capturedImageBase64 = "";
        displaySource = "";
        phase = phaseWaiting;
        resetCropAndViewport();
        updateCaptureEnabled();
    }

    function onReturnToOverview() {
        if (processing || capturedImages.length === 0) return;
        phase = phaseOverview;
        refreshOverviewSource();
        resetCropAndViewport();
        updateCaptureEnabled();
    }

    function updateImageBaseSize() {
        if (imagePreview.status === Image.Ready && imagePreview.implicitWidth > 0 && imagePreview.implicitHeight > 0) {
            imageBaseWidth = imagePreview.implicitWidth;
            imageBaseHeight = imagePreview.implicitHeight;
            resetCropAndViewport();
        }
    }

    onPhaseChanged: updateCaptureEnabled()
    onProcessingChanged: updateCaptureEnabled()

    // -------------------- 裁剪覆盖组件 (内联) --------------------
    Component {
        id: cropOverlayComponent
        Item {
            id: overlayRoot
            anchors.fill: parent
            z: 10

            // 遮罩
            Rectangle { x: 0; y: 0; width: parent.width; height: root.cropY * parent.height; color: "#75000000" }
            Rectangle { x: 0; y: (root.cropY + root.cropH) * parent.height; width: parent.width; height: parent.height - y; color: "#75000000" }
            Rectangle { x: 0; y: root.cropY * parent.height; width: root.cropX * parent.width; height: root.cropH * parent.height; color: "#75000000" }
            Rectangle { x: (root.cropX + root.cropW) * parent.width; y: root.cropY * parent.height; width: parent.width - x; height: root.cropH * parent.height; color: "#75000000" }

            // 裁剪框边框 (1px 等宽 #4CAF50, Youdao 风格)
            Rectangle {
                x: root.cropX * parent.width; y: root.cropY * parent.height
                width: root.cropW * parent.width; height: root.cropH * parent.height
                color: "transparent"; border.width: 1; border.color: "#4CAF50"
            }

            // 四边拖拽条 (阻止 Flickable 抢手势)
            Item {
                x: root.cropX * parent.width + 10; y: root.cropY * parent.height - 8
                width: Math.max(1, root.cropW * parent.width - 20); height: 16
                MouseArea {
                    anchors.fill: parent; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        var ny = Math.max(0, Math.min(root.cropY + root.cropH - root.minCrop, pt.y / overlayRoot.height));
                        root.cropH = (root.cropY + root.cropH) - ny;
                        root.cropY = ny;
                    }
                }
            }
            Item {
                x: root.cropX * parent.width + 10; y: (root.cropY + root.cropH) * parent.height - 8
                width: Math.max(1, root.cropW * parent.width - 20); height: 16
                MouseArea {
                    anchors.fill: parent; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        root.cropH = Math.max(root.minCrop, Math.min(1.0 - root.cropY, pt.y / overlayRoot.height - root.cropY));
                    }
                }
            }
            Item {
                x: root.cropX * parent.width - 8; y: root.cropY * parent.height + 10
                width: 16; height: Math.max(1, root.cropH * parent.height - 20)
                MouseArea {
                    anchors.fill: parent; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        var nx = Math.max(0, Math.min(root.cropX + root.cropW - root.minCrop, pt.x / overlayRoot.width));
                        root.cropW = (root.cropX + root.cropW) - nx;
                        root.cropX = nx;
                    }
                }
            }
            Item {
                x: (root.cropX + root.cropW) * parent.width - 8; y: root.cropY * parent.height + 10
                width: 16; height: Math.max(1, root.cropH * parent.height - 20)
                MouseArea {
                    anchors.fill: parent; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        root.cropW = Math.max(root.minCrop, Math.min(1.0 - root.cropX, pt.x / overlayRoot.width - root.cropX));
                    }
                }
            }

            // 四角手柄 (标准 8px radius, Youdao 风格)
            Rectangle {
                x: root.cropX * parent.width - 8; y: root.cropY * parent.height - 8
                width: 16; height: 16; radius: 8; color: "white"; border.width: 1.5; border.color: "#2B5278"
                MouseArea {
                    anchors.fill: parent; anchors.margins: -10; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        var nx = Math.max(0, Math.min(root.cropX + root.cropW - root.minCrop, pt.x / overlayRoot.width));
                        var ny = Math.max(0, Math.min(root.cropY + root.cropH - root.minCrop, pt.y / overlayRoot.height));
                        root.cropW = (root.cropX + root.cropW) - nx; root.cropH = (root.cropY + root.cropH) - ny;
                        root.cropX = nx; root.cropY = ny;
                    }
                }
            }
            Rectangle {
                x: (root.cropX + root.cropW) * parent.width - 8; y: root.cropY * parent.height - 8
                width: 16; height: 16; radius: 8; color: "white"; border.width: 1.5; border.color: "#2B5278"
                MouseArea {
                    anchors.fill: parent; anchors.margins: -10; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        var rX = pt.x / overlayRoot.width;
                        var nW = Math.max(root.minCrop, Math.min(1.0 - root.cropX, rX - root.cropX));
                        var ny = Math.max(0, Math.min(root.cropY + root.cropH - root.minCrop, pt.y / overlayRoot.height));
                        root.cropH = (root.cropY + root.cropH) - ny; root.cropY = ny; root.cropW = nW;
                    }
                }
            }
            Rectangle {
                x: root.cropX * parent.width - 8; y: (root.cropY + root.cropH) * parent.height - 8
                width: 16; height: 16; radius: 8; color: "white"; border.width: 1.5; border.color: "#2B5278"
                MouseArea {
                    anchors.fill: parent; anchors.margins: -10; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        var nx = Math.max(0, Math.min(root.cropX + root.cropW - root.minCrop, pt.x / overlayRoot.width));
                        var nH = Math.max(root.minCrop, Math.min(1.0 - root.cropY, pt.y / overlayRoot.height - root.cropY));
                        root.cropW = (root.cropX + root.cropW) - nx; root.cropX = nx; root.cropH = nH;
                    }
                }
            }
            Rectangle {
                x: (root.cropX + root.cropW) * parent.width - 8; y: (root.cropY + root.cropH) * parent.height - 8
                width: 16; height: 16; radius: 8; color: "white"; border.width: 1.5; border.color: "#2B5278"
                MouseArea {
                    anchors.fill: parent; anchors.margins: -10; preventStealing: true
                    onPositionChanged: {
                        if (root.processing) return;
                        var pt = mapToItem(overlayRoot, mouse.x, mouse.y);
                        root.cropW = Math.max(root.minCrop, Math.min(1.0 - root.cropX, pt.x / overlayRoot.width - root.cropX));
                        root.cropH = Math.max(root.minCrop, Math.min(1.0 - root.cropY, pt.y / overlayRoot.height - root.cropY));
                    }
                }
            }
        }
    }

    // -------------------- UI 布局 --------------------
    // 扫描提示层
    Rectangle {
        id: id_scan_hint
        anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 36 }
        color: "#1C1C1E"
        visible: phase === phaseWaiting && displaySource === ""
        z: 0

        Column {
            anchors.centerIn: parent
            spacing: 4
            Text { font.family: fontManager.fontFamily; anchors.horizontalCenter: parent.horizontalCenter; text: "📷"; font.pixelSize: 18 }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: capturedImages.length > 0 ? "已抓取 " + capturedImages.length + " 页，请继续扫描..." : "请扫描以捕获图片..."
                color: "#8899AA"; font.pixelSize: 11; font.family: fontManager.fontFamilyZhCn
            }
        }
    }

    // 主图片浏览区
    Flickable {
        id: flickable
        anchors { top: parent.top; topMargin: 44; left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 36 }
        contentWidth: Math.max(width, imagePreview.width)
        contentHeight: Math.max(height, imagePreview.height)
        interactive: contentWidth > width + 0.5 || contentHeight > height + 0.5
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        z: 1
        visible: !id_scan_hint.visible

        Item {
            id: imageContainer
            width: flickable.contentWidth
            height: flickable.contentHeight

            Image {
                id: imagePreview
                anchors.centerIn: parent
                width: imageBaseWidth * displayScale
                height: imageBaseHeight * displayScale
                source: phase === phaseCropping && capturedImageBase64 !== ""
                        ? "data:image/jpeg;base64," + capturedImageBase64 : displaySource
                fillMode: Image.PreserveAspectFit
                smooth: true
                cache: false
                visible: source != ""
                onImplicitWidthChanged: updateImageBaseSize()
                onImplicitHeightChanged: updateImageBaseSize()
                onStatusChanged: updateImageBaseSize()
            }
        }
    }

    // 加载指示器 (忙碌状态)
    Rectangle {
        anchors.centerIn: parent
        width: 80; height: 80; radius: 10
        color: "#AA000000"
        visible: processing
        z: 20

        Item {
            anchors.centerIn: parent
            width: 32; height: 32
            Item {
                id: spinner
                anchors.centerIn: parent
                width: 28; height: 28
                visible: processing

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: "transparent"
                    border.width: 2
                    border.color: "#55616A"
                }
                Rectangle {
                    anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: -1 }
                    width: 6; height: 6; radius: 3
                    color: "#4CAF50"
                }
                NumberAnimation on rotation {
                    from: 0; to: 360; duration: 800; loops: Animation.Infinite; running: processing
                }
            }
        }
        Text {
            font.family: fontManager.fontFamily
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 4 }
            text: "处理中..."
            color: "white"; font.pixelSize: 11
        }
    }

    // 裁剪覆盖层 (固定于视口，active 联动 visible 实现懒加载)
    Loader {
        id: cropLoader
        anchors.fill: flickable
        sourceComponent: cropOverlayComponent
        z: 5
        visible: root.phase === root.phaseCropping && root.imageLoaded && !root.processing
        active: visible
    }

    // 放大提示箭头 (仅当放大时)
    Item {
        anchors.fill: flickable
        visible: flickable.interactive && imagePreview.visible && !processing
        z: 6

        // 上
        Rectangle { x: parent.width / 2 - 8; y: 4; width: 16; height: 16; radius: 8; color: "#88000000"
            Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "▲"; color: "white"; font.pixelSize: 8 } }
            // 下
            Rectangle { x: parent.width / 2 - 8; y: parent.height - 20; width: 16; height: 16; radius: 8; color: "#88000000"
                Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "▼"; color: "white"; font.pixelSize: 8 } }
                // 左
                Rectangle { x: 4; y: parent.height / 2 - 8; width: 16; height: 16; radius: 8; color: "#88000000"
                    Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "◀"; color: "white"; font.pixelSize: 8 } }
                    // 右
                    Rectangle { x: parent.width - 20; y: parent.height / 2 - 8; width: 16; height: 16; radius: 8; color: "#88000000"
                        Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "▶"; color: "white"; font.pixelSize: 8 } }
    }

    // 左侧历史缩略图条 (使用 sourceSize 限制内存)
    Flickable {
        anchors { left: parent.left; leftMargin: 3; top: flickable.top; bottom: flickable.bottom }
        width: 22
        contentWidth: width
        contentHeight: thumbnailColumn.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        visible: phase === phaseOverview && capturedImages.length > 0 && displaySource !== "" && !processing
        z: 7

        Column {
            id: thumbnailColumn
            width: parent.width
            height: childrenRect.height
            spacing: 2
            Repeater {
                model: capturedImages
                Rectangle {
                    width: 20; height: 14; radius: 1; color: "#333333"
                    border.width: 1; border.color: index === capturedImages.length - 1 ? "#4CAF50" : "#555555"
                    Image {
                        anchors.fill: parent; anchors.margins: 1
                        source: "data:image/jpeg;base64," + modelData
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        sourceSize.width: 40; sourceSize.height: 30  // 解码小尺寸以节省内存
                    }
                }
            }
        }
    }

    // 顶部导航栏
    Item {
        id: topNavBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 50
        z: 10

        YBackButton {
            width: 46
            isPositionLeftBar: true
            anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 0 }
            onClicked: { root.cleanup(); root.captureCancelled(); root.backButtonClicked(); }
        }

        Text {
            anchors { left: parent.left; leftMargin: 50; verticalCenter: parent.verticalCenter }
            text: phase === phaseCropping ? "裁剪第 " + (capturedImages.length + 1) + " 帧"
                                          : (phase === phaseWaiting
                                             ? (capturedImages.length > 0 ? "等待第 " + (capturedImages.length + 1) + " 帧" : "扫描中")
                                             : (needsDirection ? "选择拼接方向"
                                                               : (capturedImages.length > 1 ? "拼图总览" : "图片预览")))
            color: YColors.grayText
            font.pixelSize: 16; font.family: fontManager.fontFamilyZhCn
        }
    }

    // 底部操作栏 (YButton 原生风格)
    Rectangle {
        id: bottomNavBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 30
        color: "#CC000000"
        z: 10
        visible: (imageLoaded || capturedImages.length > 0) && !processing

        // 场景 A：裁剪新帧
        Item {
            anchors.fill: parent
            visible: phase === phaseCropping && imageLoaded

            YButton {
                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                width: 50; height: 22; pixelSize: 10; color: "#3A2E2E"
                border.width: 1; border.color: "#5A3E3E"
                text: "放弃"; textColor: "#FF453A"
                onClicked: onAbandonCurrent()
            }

            Row {
                anchors.centerIn: parent; spacing: 12
                Rectangle {
                    width: 32; height: 20; radius: 10; color: "#2B5278"
                    Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "−"; color: "white"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: {
                        setZoom(zoomLevel - 0.25);
                    }}
                }
                Text { anchors.verticalCenter: parent.verticalCenter; text: Math.round(zoomLevel * 100) + "%"; color: "white"; font.pixelSize: 10; font.family: fontManager.fontFamilyZhCn }
                Rectangle {
                    width: 32; height: 20; radius: 10; color: "#2B5278"
                    Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "+"; color: "white"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: {
                        setZoom(zoomLevel + 0.25);
                    }}
                }
            }

            YButton {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 64; height: 22; pixelSize: 10; color: "#2B5278"
                border.width: 0
                text: "确认裁剪 ✓"; textColor: "white"
                onClicked: onSaveCurrent()
            }
        }

        // 场景 B：等待拼接方向
        Row {
            anchors.centerIn: parent; spacing: 10
            visible: phase === phaseOverview && needsDirection

            YButton {
                width: 64; height: 22; pixelSize: 10; color: "#909199"
                border.width: 1; border.color: "#2B5278"
                text: "水平拼接"; textColor: "white"
                onClicked: onDirectionSelected("horizontal")
            }
            YButton {
                width: 64; height: 22; pixelSize: 10; color: "#909199"
                border.width: 1; border.color: "#2B5278"
                text: "竖直拼接"; textColor: "white"
                onClicked: onDirectionSelected("vertical")
            }
            YButton {
                width: 44; height: 22; pixelSize: 10; color: "#2E1A1A"
                border.width: 1; border.color: "#4A2A2A"
                text: "清空"; textColor: "#FF453A"
                onClicked: onClear()
            }
        }

        // 场景 C：单图或已完成拼接的总览
        Item {
            anchors.fill: parent
            visible: phase === phaseOverview && compositeReady

            YButton {
                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                width: 44; height: 22; pixelSize: 10; color: "#2E1A1A"
                border.width: 1; border.color: "#4A2A2A"
                text: "清空"; textColor: "#FF453A"
                onClicked: onClear()
            }

            YButton {
                anchors.centerIn: parent
                width: 64; height: 22; pixelSize: 10; color: "#2B5278"
                border.width: 0
                text: "继续拍摄"; textColor: "white"
                enabled: capturedImages.length < maxFrames
                onClicked: onContinueCapture()
            }

            YButton {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 54; height: 22; pixelSize: 10; color: "#4CAF50"
                border.width: 0
                text: "完成保存"; textColor: "white"
                onClicked: onFinish()
            }
        }

        // 场景 D：等待下一次扫描时允许返回或直接完成
        Item {
            anchors.fill: parent
            visible: phase === phaseWaiting && capturedImages.length > 0

            YButton {
                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                width: 64; height: 22; pixelSize: 10; color: "#909199"
                border.width: 1; border.color: "#2B5278"
                text: "返回预览"; textColor: "white"
                onClicked: onReturnToOverview()
            }

            YButton {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: 54; height: 22; pixelSize: 10; color: "#4CAF50"
                border.width: 0
                text: "完成保存"; textColor: "white"
                onClicked: onFinish()
            }
        }
    }

    // 连接相机捕获信号
    Connections {
        target: typeof cameraCapture !== 'undefined' && cameraCapture !== null ? cameraCapture : null
        ignoreUnknownSignals: true
        function onImageCaptured(base64Data) {
            if (!pageActive || processing || phase !== phaseWaiting)
                return;
            if (!base64Data || base64Data.length > maxStoredBase64Chars) {
                showError("捕获图片过大或数据无效");
                return;
            }
            capturedImageBase64 = base64Data;
            displaySource = "";
            phase = phaseCropping;
            zoomLevel = 1.0;
            flickable.contentX = 0;
            flickable.contentY = 0;
            updateCaptureEnabled();
        }

        function onCropImageCompleted(requestId, base64Data, errorMessage) {
            if (requestId !== activeRequestId || pendingOperation !== "crop")
                return;

            activeRequestId = 0;
            pendingOperation = "";
            processing = false;
            if (errorMessage !== "" || base64Data === "") {
                showError(errorMessage !== "" ? errorMessage : "裁剪失败");
                return;
            }

            var newList = capturedImages.slice();
            newList.push(base64Data);
            if (newList.length > maxFrames || capturedDataSize(newList) > maxStoredBase64Chars) {
                showError("已达到图片数量或大小上限");
                return;
            }

            capturedImages = newList;
            capturedImageBase64 = "";
            phase = phaseOverview;
            resetCropAndViewport();

            if (capturedImages.length === 1) {
                currentComposite = capturedImages[0];
                compositeFrameCount = 1;
                refreshOverviewSource();
            } else if (stitchDirection !== "") {
                refreshOverviewSource();
                onDirectionSelected(stitchDirection);
            } else {
                currentComposite = "";
                compositeFrameCount = 0;
                refreshOverviewSource();
            }
            updateCaptureEnabled();
        }

        function onStitchImagesCompleted(requestId, base64Data, errorMessage) {
            if (requestId !== activeRequestId || pendingOperation !== "stitch")
                return;

            var completedDirection = pendingDirection;
            activeRequestId = 0;
            pendingOperation = "";
            pendingDirection = "";
            processing = false;
            if (errorMessage !== "" || base64Data === "") {
                refreshOverviewSource();
                showError(errorMessage !== "" ? errorMessage : "图片拼接失败，请重试");
                return;
            }

            currentComposite = base64Data;
            compositeFrameCount = capturedImages.length;
            stitchDirection = completedDirection;
            phase = phaseOverview;
            refreshOverviewSource();
            resetCropAndViewport();
            updateCaptureEnabled();
        }
    }
}
