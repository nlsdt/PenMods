// 跨组件 SVG LRU 缓存 + 并发请求队列
// 键格式：latex + "|" + (display ? "d" : "i")
.pragma library

// ── 状态枚举（替代字符串比较，减少 QML 绑定中的比较开销）──
var IDLE = 0;
var LOADING = 1;
var DONE = 2;
var ERROR = 3;

// ── LRU 缓存 ──
var _MAX = 80;
var _store = {};
var _order = [];

// ── 并发请求队列 ──
var _MAX_CONCURRENT = 4;            // 同一时间最多 4 个进行中的 XHR
var _requestQueue = [];           // 排队等待的请求
var _activeCount = 0;            // 当前进行中的请求数

// ── 原有 LRU 缓存接口 ──
function get(key) {
    if (!_store.hasOwnProperty(key)) return null;
    var idx = _order.indexOf(key);
    if (idx !== -1) _order.splice(idx, 1);
    _order.push(key);
    return _store[key];
}

function set(key, val) {
    if (_store.hasOwnProperty(key)) {
        _store[key] = val;
        var idx = _order.indexOf(key);
        if (idx !== -1) _order.splice(idx, 1);
        _order.push(key);
        return;
    }
    if (_order.length >= _MAX) {
        var evict = _order.shift();
        delete _store[evict];
    }
    _store[key] = val;
    _order.push(key);
}

// ── 并发请求队列 ──
// 每项: { latex, display, cacheKey, resolve }
// 限制同一时间最多 _MAX_CONCURRENT 个进行中的 XHR，其余排队等待
function enqueueRequest(latex, display, resolveCallback) {
    var cacheKey = latex + "|" + (display ? "d" : "i");
    var cached = get(cacheKey);
    if (cached !== null) {
        resolveCallback({ success: true, dataUri: cached, fromCache: true });
        return;
    }
    _requestQueue.push({
        latex: latex,
        display: display,
        cacheKey: cacheKey,
        resolve: resolveCallback
    });
    _drainQueue();
}

function _drainQueue() {
    while (_activeCount < _MAX_CONCURRENT && _requestQueue.length > 0) {
        var item = _requestQueue.shift();
        _activeCount++;
        _executeXhr(item);
    }
}

function _executeXhr(item) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "http://127.0.0.1:3000/render", true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.DONE) return;
        _activeCount--;
        if (xhr.status === 200) {
            try {
                var resp = JSON.parse(xhr.responseText);
                var dataUri = "data:image/png;base64," + resp.data;
                set(item.cacheKey, dataUri);
                item.resolve({ success: true, dataUri: dataUri });
            } catch (e) {
                item.resolve({ success: false, error: "解析响应失败" });
            }
        } else {
            try {
                var errMsg = JSON.parse(xhr.responseText).error || ("HTTP " + xhr.status);
                item.resolve({ success: false, error: errMsg });
            } catch (e) {
                item.resolve({ success: false, error: "HTTP " + xhr.status });
            }
        }
        _drainQueue(); // 处理下一个排队请求
    };
    xhr.send(JSON.stringify({ latex: item.latex, display: item.display }));
}
