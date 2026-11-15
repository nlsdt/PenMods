/**
 * PenMods 自造词典记录的"分块"解析：把作者给的 JSON 变成一串 block 对象，
 * 由 components/YCustomDictContentView.qml 用 QML 组件排版（词头/例句带发音按钮）。
 *
 * block 形式：
 *   {type:"head",    word, phonetic, lang}      词头 + 音标 + 发音按钮
 *   {type:"tags",    text}                      标签
 *   {type:"def",     pos, tran}                 释义
 *   {type:"example", en, zh, lang}              例句（英文侧带发音按钮）
 *   {type:"note",    text} / {type:"source", text}
 *   {type:"kv",      key, value}                其它字段（兜底）
 *   {type:"raw",     text}                      记录不是 JSON 时原样显示
 *   {type:"index",   text}                      顶层是数组时的条目编号
 *
 * 推荐 schema（别名也认）见 doc/CUSTOM_DICT_GUIDE.md。
 */

function isBlank(value) {
    if (value === null || value === undefined)
        return true
    if (typeof value === "string")
        return value.trim().length === 0
    if (Array.isArray(value))
        return value.length === 0
    if (typeof value === "object")
        return Object.keys(value).length === 0
    return false
}

function isHttpUrl(value) {
    return typeof value === "string" && /^\s*(https?:\/\/|data:)/i.test(value)
}

function firstKey(object, names) {
    for (let i = 0; i < names.length; ++i) {
        const key = names[i]
        if (object[key] !== undefined && !isBlank(object[key]))
            return object[key]
    }
    return undefined
}

function inline(value) {
    if (isBlank(value))
        return ""
    if (typeof value === "string")
        return value.trim()
    if (typeof value === "number" || typeof value === "boolean")
        return String(value)
    if (Array.isArray(value)) {
        const parts = []
        for (let i = 0; i < value.length && i < 8; ++i) {
            const text = inline(value[i])
            if (text.length)
                parts.push(text)
        }
        return parts.join(" / ")
    }
    const parts = []
    const keys = Object.keys(value)
    for (let i = 0; i < keys.length && parts.length < 6; ++i) {
        if (isHttpUrl(value[keys[i]]))
            continue
        const text = inline(value[keys[i]])
        if (text.length)
            parts.push(text)
    }
    return parts.join(" / ")
}

/** 猜语言代码（soundCenter.play 用的是 en / zh / ko / ja） */
function guessLang(text) {
    if (typeof text !== "string" || text.length === 0)
        return "en"
    if (/[\uac00-\ud7af]/.test(text))
        return "ko"
    if (/[\u3040-\u30ff]/.test(text))
        return "ja"
    if (/[\u4e00-\u9fff]/.test(text))
        return "zh"
    return "en"
}

function toStringList(value) {
    if (isBlank(value))
        return []
    if (Array.isArray(value)) {
        const out = []
        for (let i = 0; i < value.length; ++i) {
            const text = inline(value[i])
            if (text.length)
                out.push(text)
        }
        return out
    }
    if (typeof value === "string")
        return value.split(/[;；\n]/).map(function (s) { return s.trim() }).filter(function (s) { return s.length })
    return [String(value)]
}

const WORD_KEYS = ["word", "headword", "ew", "title", "词", "单词"]
const PHONETIC_KEYS = ["phonetic", "phone", "usphone", "ukphone", "pron", "pr", "音标"]
const TAG_KEYS = ["tags", "tag", "labels", "label", "标签"]
const DEF_KEYS = ["defs", "def", "definition", "definitions", "meanings", "trans", "tran", "translation",
                  "explain", "解释", "释义"]
const EXAMPLE_KEYS = ["examples", "example", "sentences", "sentence", "例句"]
const NOTE_KEYS = ["note", "notes", "usage", "tip", "备注", "说明"]
const SOURCE_KEYS = ["source", "from", "sourceName", "来源"]
const LANG_KEYS = ["lang", "language", "语言"]

function pushDefinitions(blocks, value) {
    const list = Array.isArray(value) ? value : [value]
    for (let i = 0; i < list.length && i < 20; ++i) {
        const entry = list[i]
        if (isBlank(entry))
            continue
        let pos = ""
        let tran = ""
        if (typeof entry === "string") {
            tran = entry
        } else if (typeof entry === "object") {
            pos = inline(firstKey(entry, ["pos", "part", "词性"]))
            tran = inline(firstKey(entry, ["tran", "trans", "translation", "meaning", "def", "definition",
                                           "text", "解释", "释义"]))
            if (!tran.length)
                tran = inline(entry)
        }
        if (pos.length || tran.length)
            blocks.push({"type": "def", "pos": pos, "tran": tran})
    }
}

function pushExamples(blocks, value, defaultLang) {
    const list = Array.isArray(value) ? value : [value]
    for (let i = 0; i < list.length && i < 6; ++i) {
        const entry = list[i]
        if (isBlank(entry))
            continue
        let en = ""
        let zh = ""
        if (typeof entry === "string") {
            en = entry
        } else if (typeof entry === "object") {
            en = inline(firstKey(entry, ["en", "source", "sentence", "example", "text", "英文", "例句"]))
            zh = inline(firstKey(entry, ["zh", "translation", "target", "meaning", "中文", "翻译"]))
            if (!en.length && !zh.length)
                en = inline(entry)
        }
        if (!en.length && !zh.length)
            continue
        blocks.push({"type": "example", "en": en, "zh": zh,
                     "lang": (en.length ? guessLang(en) : defaultLang)})
    }
}

function pushKeyValues(blocks, value, prefix, depth) {
    if (blocks.length > 80 || depth > 2)
        return
    const keys = Object.keys(value)
    for (let i = 0; i < keys.length; ++i) {
        const key = keys[i]
        const item = value[key]
        if (isBlank(item) || isHttpUrl(item))
            continue
        const label = prefix.length ? (prefix + "." + key) : key
        if (Array.isArray(item)) {
            if (item.length && typeof item[0] === "object") {
                for (let k = 0; k < item.length && k < 8; ++k)
                    pushKeyValues(blocks, item[k], label + "[" + (k + 1) + "]", depth + 1)
            } else {
                const text = inline(item)
                if (text.length)
                    blocks.push({"type": "kv", "key": label, "value": text})
            }
        } else if (item !== null && typeof item === "object") {
            pushKeyValues(blocks, item, label, depth + 1)
        } else {
            blocks.push({"type": "kv", "key": label, "value": String(item)})
        }
    }
}

/** @return block 数组；空数组表示没东西可显示 */
function blocks(record) {
    const out = []
    if (record === null || record === undefined)
        return out

    if (Array.isArray(record)) {
        for (let i = 0; i < record.length && i < 10; ++i) {
            if (i > 0)
                out.push({"type": "index", "text": (i + 1) + "."})
            const one = blocks(record[i])
            for (let k = 0; k < one.length; ++k)
                out.push(one[k])
        }
        return out
    }

    if (typeof record !== "object")
        return [{"type": "raw", "text": String(record)}]

    const keys = Object.keys(record)
    let known = false
    for (let i = 0; i < keys.length; ++i) {
        if (WORD_KEYS.concat(PHONETIC_KEYS, TAG_KEYS, DEF_KEYS, EXAMPLE_KEYS, NOTE_KEYS, SOURCE_KEYS,
                             LANG_KEYS).indexOf(keys[i]) >= 0) {
            known = true
            break
        }
    }
    if (!known) {
        pushKeyValues(out, record, "", 0)
        return out
    }

    const word = inline(firstKey(record, WORD_KEYS))
    const phonetic = inline(firstKey(record, PHONETIC_KEYS))
    const declaredLang = inline(firstKey(record, LANG_KEYS))
    const lang = declaredLang.length ? declaredLang : guessLang(word)
    if (word.length || phonetic.length)
        out.push({"type": "head", "word": word, "phonetic": phonetic, "lang": lang})

    const tags = toStringList(firstKey(record, TAG_KEYS))
    if (tags.length)
        out.push({"type": "tags", "text": tags.join(" · ")})

    pushDefinitions(out, firstKey(record, DEF_KEYS))
    pushExamples(out, firstKey(record, EXAMPLE_KEYS), lang)

    const note = inline(firstKey(record, NOTE_KEYS))
    if (note.length)
        out.push({"type": "note", "text": note})

    const rest = {}
    let hasRest = false
    for (let i = 0; i < keys.length; ++i) {
        const key = keys[i]
        if (WORD_KEYS.concat(PHONETIC_KEYS, TAG_KEYS, DEF_KEYS, EXAMPLE_KEYS, NOTE_KEYS, SOURCE_KEYS,
                             LANG_KEYS).indexOf(key) < 0) {
            rest[key] = record[key]
            hasRest = true
        }
    }
    if (hasRest)
        pushKeyValues(out, rest, "", 0)

    const source = inline(firstKey(record, SOURCE_KEYS))
    if (source.length)
        out.push({"type": "source", "text": source})

    return out
}
