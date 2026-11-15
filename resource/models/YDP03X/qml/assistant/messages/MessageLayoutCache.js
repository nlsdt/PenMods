.pragma library

var _MAX_ENTRIES = 48;
var _MAX_TOTAL_CHARS = 512 * 1024;
var _MAX_ITEM_CHARS = 32 * 1024;
var _store = {};
var _order = [];
var _totalChars = 0;

function _key(text) {
    var hash = 5381;
    for (var i = 0; i < text.length; i++)
        hash = ((hash << 5) + hash + text.charCodeAt(i)) >>> 0;
    return text.length + ":" + hash;
}

function _entry(text, create) {
    if (!text || text.length > _MAX_ITEM_CHARS)
        return null;
    var key = _key(text);
    var entry = _store[key];
    if (entry && entry.source !== text)
        entry = null;
    if (!entry && create) {
        entry = { "source": text, "blocks": null, "html": null, "heights": {} };
        _store[key] = entry;
        _order.push(key);
        _totalChars += text.length;
        _trim();
    } else if (entry) {
        var index = _order.indexOf(key);
        if (index !== -1)
            _order.splice(index, 1);
        _order.push(key);
    }
    return entry;
}

function _trim() {
    while (_order.length > _MAX_ENTRIES || _totalChars > _MAX_TOTAL_CHARS) {
        var key = _order.shift();
        var entry = _store[key];
        if (entry) {
            _totalChars -= entry.source.length;
            delete _store[key];
        }
    }
}

function get(text) {
    var entry = _entry(text, false);
    return entry ? entry.blocks : null;
}

function set(text, blocks) {
    var entry = _entry(text, true);
    if (entry)
        entry.blocks = blocks;
}

function getHtml(text) {
    var entry = _entry(text, false);
    return entry ? entry.html : null;
}

function setHtml(text, html) {
    var entry = _entry(text, true);
    if (entry)
        entry.html = html;
}

function getHeight(text, width) {
    var entry = _entry(text, false);
    if (!entry)
        return 0;
    return entry.heights[String(Math.round(width))] || 0;
}

function setHeight(text, width, height) {
    if (!height || height <= 0)
        return;
    var entry = _entry(text, true);
    if (entry)
        entry.heights[String(Math.round(width))] = height;
}
