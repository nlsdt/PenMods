.pragma library

//xml转json后顺序信息丢失，下列单词的不规形式无法按正确顺序显示，强制特殊处理
//static const QMap<QString, std::pair<QString, QString>>
var s_specialIrregular = {
    "shall": ["", "(<i>negative</i><b> shall not </b><i>short form</i><b> shan't </b>/ʃɑːnt/ <i>NAmE</i> /ʃænt/, <i>pt </i><b>should</b> /ʃʊd/, <i>negative</i><b> should not </b><i>short form</i><b> shouldn't </b>/ˈʃʊdnt/"],
    "learn": ["", "(<b>learnt</b>, <b>learnt</b> /lɜːnt/ <i>NAmE</i> /lɜːrnt/ or <b>learned</b>, <b>learned</b>)"],
    "leap": ["v", "(<b>leapt</b>, <b>leapt</b> /lept/ or <b>leaped</b>, <b>leaped</b>)"],
    "dwell": ["", "(<b>dwelt</b>, <b>dwelt</b>) or (<b>dwelled</b>, <b>dwelled</b>)"],
    "dream": ["v", "(<b>dreamt</b>, <b>dreamt</b> /dremt/) or (<b>dreamed</b>, <b>dreamed</b>)"],
    "shine": ["v", "(<b>shone</b>, <b>shone</b> /ʃɒn/ <i>US</i> /ʃoʊn/)"],
    "sit": ["", "(<b>sit·ting</b>, <b>sat</b>, <b>sat</b> /sæt/)"],
    "beget": ["", "(<b>be·get·ting</b>, <b>begot</b>, <b>begot</b> /bɪˈɡɒt/ <i>NAmE</i> /‑ɡɑːt/)<icon>HELP</icon>In sense 1 <b> begat </b>  /bɪˈgæt/ is used for the past tense, and <b> be·got·ten </b>  /bɪˈɡɒtn/  /-ˈɡɑːtn/ is used for the past participle.第1义的过去式用begat，过去分词用begotten。"],
    "bureau": ["", "(<i>pl.</i> <b>bur·eaux</b> or <b>bur·eaus</b> /‑rəʊz/ <i>NAmE</i> /‑roʊz/)"],
    "fly": ["v", "(<b>flies</b>, <b>fly·ing</b>, <b>flew</b> /fluː/, <b>flown</b> /fləʊn/ <i>NAmE</i> /floʊn/)"],
    "focus": ["n", "(<i>pl.</i> <b>fo·cuses</b> or <b>foci</b> /ˈfəʊsaɪ/ <i>NAmE</i> /ˈfoʊ‑/)"],
    "spit": ["v", "(<b>spit·ting</b>, <b>spat</b>, <b>spat</b> /spæt/)"],
    "blow": ["v", "(<b>blew</b> /bluː/, <b>blown</b> /bləʊn/ <i>NAmE</i> /bloʊn/) <icon>HELP</icon>In sense 13 <b> blowed </b> is used for the past participle. In sense 13 <b> blowed </b> is used for the past participle."],
    "retell": ["", "(<b>re·told</b>, <b>re·told</b> /‑ˈtəʊld/ <i>NAmE</i> /‑ˈtoʊld/)"],
    "shoe": ["v", "(<b>shoe·ing</b>, <b>shod</b>, <b>shod</b> /ʃɒd/ <i>NAmE</i> /ʃɑːd/)"],
    "shoot": ["v", "(<b>shot</b>, <b>shot</b> /ʃɒt/ <i>NAmE</i> /ʃɑːt/)"],
    "amphora": ["", "(<i>pl.</i> <b>am·phorae</b> /ˈæmfəriː/ <i>NAmE</i> also /æmˈfɔːriː/ or <b>am·phoras</b>)"],
    "chef-d'oeuvre": ["", "(<i>pl.</i> <b>chefs-d'oeuvre</b> /ˌʃeɪ ˈdɜːvrə/ <i>NAmE</i> also /ˈduːvrə/)"]
}

function isPtAfterX(wordText, qsPos) {
    if ((wordText === "pressure" && qsPos === "v")
        || wordText === "divulge" || wordText === "double-check"
        || wordText === "fantasize" || wordText === "fatten") {
        return true
    }
    return false
}

function isArrayFn(value) {
    if (typeof value == "object") {
        if (typeof value.length == "number") {
            return true
        }
    }
    return false
}

//去左空格;
function ltrim(s){
    return s.replace(/(^\s*)/g, "");
}
//去右空格;
function rtrim(s){
    return s.replace(/(\s*$)/g, "");
}
//去左右空格;
function trim(s){
    return s.replace(/(^\s*)|(\s*$)/g, "");
}

function formatText(text, color, weight, pixSize, familyName) {
    if (typeof text != "string" || text.length <= 0) {
        return ""
    }
    var rst = '<span style="'
    if (typeof color == "string" && color.length > 0) {
        rst += 'color: ' + color + '; '
    }
    if (typeof familyName == "string" && familyName.length > 0) {
        rst += 'font-family:' + familyName + ';'
    }
    if (typeof weight == "number" && weight > 0) {
        rst += 'font-weight:' + weight + ';'
    }
    if (typeof pixSize == "number" && pixSize > 0) {
        rst += 'font-size:' + pixSize + 'px;'
    }
    rst += '">' + text + '</span>'
    return rst
}

function formatTextFontWeight(text, weight) {
    if (typeof text != "string" || text.length <= 0) {
        return ""
    }
    var rst = ""
    if (typeof weight == "number" && weight > 0) {
        rst += '<span style="font-weight:' + weight + ';">' + text + '</span>'
    }
    return rst
}

function formatTextFontFamily(text, familyName) {
    if (typeof text != "string" || text.length <= 0) {
        return ""
    }
    var rst = ""
    if (typeof familyName == "string" && familyName.length > 0) {
        rst += '<span style="font-family:' + familyName + ';">' + text + '</span>'
    }
    return rst
}

function formatBorderText(text, pixSize) {
    if (typeof pixSize == "undefined") pixSize = 26
    if (typeof text != "string") {
        return ""
    }
    //var rst = '<span style="color: #509DEB; border:2px solid #509DEB; border-radius:4px;'
    var rst = '<span style="color:#F03043;font-weight:400;'
    rst += 'font-size:' + pixSize + 'px;">[' + text + ']</span>'
    return rst
}

function outputInfo(vData, name) {
    console.log("YDictOxfordUtilities.js === outputInfo name: ", name, ", type: ", typeof vData)
    if (typeof vData != "object") {
        console.log("YDictOxfordUtilities.js === outputInfo value: ", vData)
    } else if (typeof vData == "object") {
        if (isArrayFn(vData)) {
            console.log("YDictOxfordUtilities.js === outputInfo vData is array length :", vData.length)
            vData.forEach(function(vDataObject, index){
                outputInfo(vDataObject, name + "_arr_" + index)
            })
        } else {
            console.log("YDictOxfordUtilities.js === outputInfo vData is object keys num: ", Object.keys(vData).length)
            Object.keys(vData).forEach(function(keyName){
                outputInfo(vData[keyName], name + "_" + keyName)
            })
        }
    }
}

var s_escapeMap = {
    "&hyphen;": "-",
    "&iuml;": "ï",
    "&frac18;": "<sup>1</sup>/<sub>8</sub>",
    "&infin;": "∞",
    "&iota;": "ι",
    "&kappa;": "κ",
    "&rdquo;": "\"",
    "&reg;": "®",
    "&macr;": "¯",
    "&mu;": "μ",
    "&natur;": "L",
    "&nu;": "ν",
    "&phi;": "ø",
    "&dash;": "-",
    "&rho;": "ρ",
    "&sharp;": "♯",
    "&radic;": "√",
    "&tau;": "τ",
    "&dollar;": "$",
    "&ditto;": "\"",
    "&euro;": "€",
    "&gt;": ">",
    "&icirc;": "î",
    "&lt;": "<",
    "&oelig;": "œ",
    "&p;": "ˈ",
    "&trade;": "™"
};

function convertEscape(qsEscapeSeq){
    if (typeof s_escapeMap[qsEscapeSeq] != "undefined") {
        return s_escapeMap[qsEscapeSeq]
    }
    return ""
}

// QChar::isLetterOrNumber(ucs)
function isLetterOrNumber(ucs4) {
    return (ucs4.localeCompare("A") >= 0 && ucs4.localeCompare("z") <= 0 && (ucs4.localeCompare("a") >= 0 || ucs4.localeCompare("Z") <= 0))
            || (ucs4.localeCompare("0") >= 0 && ucs4.localeCompare("9") <= 0)
            //|| (ucs4 > 127 && QChar::isLetterOrNumber_helper(ucs4));
}

// QChar::isLetter(ucs)
function isLetter(ucs4) {
    return (ucs4.localeCompare("A") >= 0 && ucs4.localeCompare("z") <= 0 && (ucs4.localeCompare("a") >= 0 || ucs4.localeCompare("Z") <= 0))
            //|| (ucs4 > 127 && QChar::isLetter_helper(ucs4));
}

// QChar::isDigit(ucs)
function isDigit(ucs4) {
    return (ucs4.localeCompare("0") >= 0 && ucs4.localeCompare("9") <= 0)
            //|| (ucs4 > 127 && QChar::category(ucs4) == Number_DecimalDigit);
}

//处理转义字符并顺便检测是否需要处理html节点
function escapeString(qsText){
    var bHasHtmlNode = false
    var qsEscaped = ""
    var qsEscapeSeq = ""
    var bEscaping = false
    for (var i = 0; i < qsText.length; ++i) {
        var ch = qsText.charAt(i)
        if (bEscaping) {
            if (isLetterOrNumber(ch)) {
                qsEscapeSeq += ch
                continue;
            }
            bEscaping = false
            qsEscapeSeq += ch
            if (ch === ";") {
                var qsEsc = convertEscape(qsEscapeSeq)
                if (qsEsc.length > 0 && qsEsc[0] === "<") {
                    bHasHtmlNode = true;
                }
                //转义成功使用转义后字符串，否则使用原字符串
                qsEscaped += (qsEsc.length <= 0 ? qsEscapeSeq : qsEsc)
                continue
            }
            //不是转义序列
            qsEscaped += qsEscapeSeq
            continue;
        }
        if (ch === "<") {
            bHasHtmlNode = true;
        }
        if (ch === "&") {
            bEscaping = true;
            qsEscapeSeq += ch
            continue;
        }
        qsEscaped += ch
    }
    return [qsEscaped, bHasHtmlNode]
}

var HtmlTransState = Object.freeze({
    "HT_NodeContent": 0,
    "HT_HtmlNodeStartOrEnd": 1,
    "HT_HtmlNodeStart": 2,
    "HT_HtmlNodeEnd": 3,
    "HT_HtmlNodeEnd2": 4
})

var HtmlNodeType = Object.freeze({
    "NT_PlainText": 0,
    "NT_Sup": 1,
    "NT_Sub": 2,
    "NT_Img": 3,
    "NT_B": 4,
    "NT_I": 5,
    "NT_Em": 6,
    "NT_Icon": 7,
    "NT_Arrow": 8,
    "NT_Gray": 9,
    "NT_INVALID": 10
})

function createHtmlNode(nodeType, nodeText) {
    var htmlNode = new Object
    htmlNode["type"] = nodeType
    htmlNode["text"] = nodeText
    htmlNode["subNodes"] = []
    return htmlNode
}

var s_nodeNameToTypeMap = {
    "img": HtmlNodeType.NT_Img,
    "sup": HtmlNodeType.NT_Sup,
    "sub": HtmlNodeType.NT_Sub,
    "b": HtmlNodeType.NT_B,
    "i": HtmlNodeType.NT_I,
    "em": HtmlNodeType.NT_Em,
    "icon": HtmlNodeType.NT_Icon,
    "arrow": HtmlNodeType.NT_Arrow,
    "gray": HtmlNodeType.NT_Gray
}

//NT_PlainText, NT_Sup, NT_Sub, NT_Img, NT_INVALID
var s_nodeTypeToNameMap = ["", "sup", "sub", "img", "b", "i", "em", "icon", "arrow", "gray"]

function getHtmlType(qsNodeName){
    var htmlType = HtmlNodeType.NT_INVALID
    let nodeName = qsNodeName.toLowerCase()
    if (typeof s_nodeNameToTypeMap[nodeName] != "undefined") {
        htmlType = s_nodeNameToTypeMap[nodeName]
    }
    //console.log("YDictOxfordUtilities.js === getHtmlType qsNodeName: ", qsNodeName, ", htmlType: ", htmlType)
    return htmlType
}

function parseHtml(qsHtml) {
    var state = HtmlTransState.HT_NodeContent;
    var root = createHtmlNode(HtmlNodeType.NT_PlainText, "")
    var vNodeStack = [root]
    var pCurrentNode = vNodeStack[0]
    var qsHtmlNode = ""
    var qsHtmlContent = ""
    for (var i = 0; i < qsHtml.length; ++i) {
        var ch = qsHtml.charAt(i)
        //console.log("YDictOxfordUtilities.js === parseHtml ch: ", ch, ", state: ", state)
        switch (state) {
        case HtmlTransState.HT_NodeContent:
            if (ch === "<") {
                state = HtmlTransState.HT_HtmlNodeStartOrEnd;
                continue;
            }
            if (ch === "/") {
                state = HtmlTransState.HT_HtmlNodeEnd; //可能是‘/>’关闭节点
                continue;
            }
            qsHtmlContent += ch
            break;
        case HtmlTransState.HT_HtmlNodeStartOrEnd: //遇到 '<'后
            if (ch === "/") {
                state = HtmlTransState.HT_HtmlNodeEnd2; //可能是'</xxx>'关闭节点
                continue;
            }
            else if (isLetter(ch)) {
                state = HtmlTransState.HT_HtmlNodeStart;
                --i; //回退ch到qsHtml;
                continue;
            }
            //不是节点开始及关闭，继续当做节点内容处理
            qsHtmlContent += '<' + ch
            state = HtmlTransState.HT_NodeContent
            break;
        case HtmlTransState.HT_HtmlNodeStart:
            if (isLetter(ch)) {
                qsHtmlNode += ch
                continue;
            }
            var nodeType = getHtmlType(qsHtmlNode)
            if (nodeType !== HtmlNodeType.NT_INVALID) {
                if (qsHtmlContent.length > 0) {
                    pCurrentNode.subNodes.push(createHtmlNode(HtmlNodeType.NT_PlainText, qsHtmlContent))
                    qsHtmlContent = ""
                }
                pCurrentNode.subNodes.push(createHtmlNode(nodeType, ""))
                pCurrentNode = pCurrentNode.subNodes[pCurrentNode.subNodes.length - 1]
                vNodeStack.push(pCurrentNode)
            } else {
                qsHtmlNode += ch
                qsHtmlContent += '<' + qsHtmlNode
            }
            qsHtmlNode = ""
            state = HtmlTransState.HT_NodeContent
            break;
        case HtmlTransState.HT_HtmlNodeEnd: //遇到'/'
            //'/>'关闭节点
            if (ch === ">") {
                pCurrentNode.text = qsHtmlContent
                qsHtmlContent = ""
                vNodeStack.pop()
                pCurrentNode = vNodeStack[vNodeStack.length - 1]
            } else {
                qsHtmlContent += '/'
                --i;
            }
            state = HtmlTransState.HT_NodeContent;
            break;
        case HtmlTransState.HT_HtmlNodeEnd2: //after see '</'
            if (isLetter(ch)) {
                 qsHtmlNode += ch
                continue;
            }
            var endNodeType = getHtmlType(qsHtmlNode)
             //</node>
            if (ch === ">" &&  endNodeType === pCurrentNode.type) {
                //如果一个节点内没有节点就不用创建一个PlainText的节点了，直接把文本存text里
                if (pCurrentNode.subNodes.length > 0) {
                    if (qsHtmlContent.length > 0) {
                        pCurrentNode.subNodes.push(createHtmlNode(HtmlNodeType.NT_PlainText, qsHtmlContent));
                    }
                } else {
                    pCurrentNode.text = qsHtmlContent
                }
                qsHtmlContent = ""
                vNodeStack.pop()
                pCurrentNode = vNodeStack[vNodeStack.length - 1]
            } else {
                qsHtmlContent += '<' + '/' + qsHtmlNode + ch
            }
            qsHtmlNode = ""
            state = HtmlTransState.HT_NodeContent;
            break;
        }
    }
    if (state === HtmlTransState.HT_HtmlNodeStart
        || state === HtmlTransState.HT_HtmlNodeStartOrEnd
        || state === HtmlTransState.HT_HtmlNodeEnd
        || state === HtmlTransState.HT_HtmlNodeEnd2) {
        if (state === HtmlTransState.HT_HtmlNodeStart || state === HtmlTransState.HT_HtmlNodeStartOrEnd) {
            qsHtmlContent += '<'
        }
        if (state === HtmlTransState.HT_HtmlNodeEnd || state === HtmlTransState.HT_HtmlNodeEnd2) {
            qsHtmlContent += '/'
        }
        qsHtmlContent += qsHtmlNode
        state = HtmlTransState.HT_NodeContent
    }
    if (qsHtmlContent.length > 0) {
        if (pCurrentNode.subNodes.length > 0) {
            pCurrentNode.subNodes.push(createHtmlNode(HtmlNodeType.NT_PlainText, qsHtmlContent))
        } else {
            pCurrentNode.text = qsHtmlContent
        }
    }
    return root
}

//处理num^num这种指数或者interpart+分子/分母这种分数
function renderFracOrExponent(qsInterPart, qsSup, qsSub) {
    if (typeof qsInterPart != "string"
        || typeof qsSup != "string"
        || typeof qsSub != "string") {
        return ""
    }
    var vFormatted = qsInterPart
    if (qsSup.length > 0) {
        vFormatted += "<sup>" + qsSup + "</sup>"
    }
    if (qsSub.length > 0) {
        vFormatted += "/<sub>" + qsSub + "</sub>"
    }
    return vFormatted
}

//判断是<sup>num</sup>/<sub>num</sub>这种形式的节点序列
function isFracStart(pNodes, i) {
    var n = pNodes[i]
    if (n.type !== HtmlNodeType.NT_Sup || n.subNodes.length > 0 || i + 2 >= pNodes.length) {
        return false
    }
    var nNext = pNodes[i + 1]
    if (nNext.text.trim() !== "/" && nNext.text.trim() !==  "⁄") {
        return false
    }
    var nNNext = pNodes[i + 2]
    if (nNNext.type !== HtmlNodeType.NT_Sub || nNNext.subNodes.length > 0) {
        return false
    }
    return true
}

//判断是不是指数(num<sup>num</sup>)序列
function isExponentStart(pNodes, i) {
    var n = pNodes[i]
    if (n.type !== HtmlNodeType.NT_PlainText || n.text.length > 0 || i + 1 >= pNodes.length) {
        return false
    }
    if (!isDigit(n.text[n.text.length - 1])) {
        return false
    }
    var nNext = pNodes[i + 1]
    if (nNext.type !== HtmlNodeType.NT_Sup || nNext.subNodes.length > 0) {
        return false
    }
    return true
}

// a4bc123->a4bc, 123
function SplitDigit(qsText) {
    var i = qsText.length - 1;
    while (i >= 0 && isDigit(qsText[i])) {
        --i;
    }
    return [qsText.substring(0, i + 1), qsText.substring(i + 1)]
}

function getHtmlNodeTypeName(type) {
    return s_nodeTypeToNameMap[type];
}

function htmlNodeToFormatted(node){
    //outputInfo(node, "htmlNodeToFormatted_node")
    var vFormatted = ""
    if (node.subNodes.length > 0) {
        //const QFont& ftNode = FontFromNode(node.type, ft);
        //const QColor& clrNode = ColorFromNode(node.type, clr);
        for (var i = 0; i < node.subNodes.length; ++i) {
            var subNodeCur = node.subNodes[i]
            //处理<sup>1</sup>/<sub>4</sub>这样的分数
            if (isFracStart(node.subNodes, i)) {
                  var qsSub = node.subNodes[i + 2].text;
                  vFormatted += renderFracOrExponent("", subNodeCur.text, qsSub)
                  i += 2;
                  continue;
            }
            //处理指数2^4或者2又5分之一这种分数
            if (isExponentStart(node.subNodes, i)) {
                var p = splitDigit(subNodeCur.text);
                if (p[0].length > 0) {
                    vFormatted += p[0]
                }
                var qsSup = node.subNodes[i + 1].text;
                if (isFracStart(node.subNodes, i + 1)) {
                    var qsSub1 = node.subNodes[i + 3].text;
                    vFormatted += renderFracOrExponent(p[1], qsSup, qsSub1)
                    i += 3;
                } else {
                    vFormatted += renderFracOrExponent(p[1], qsSup, "")
                    i += 1;
                }
                continue;
            }
            vFormatted += htmlNodeToFormatted(subNodeCur)
        }
        return vFormatted
    }
    if (node.text.length <= 0) {
        return vFormatted;
    }
    if (node.text.startsWith(" ")) {
        node.text = node.text.replace(" ", "&nbsp;")
    }
    switch (node.type) {
    case HtmlNodeType.NT_Img: //生僻字：src='http://ydschool-online.nos.netease.com/oxford_rarelyUsed_word_EF53.gif'
        var qsAnchor = "oxford_rarelyUsed_word_";
        var anchorPos = node.text.indexOf(qsAnchor);
        if (anchorPos) {
            var qsId = ":/char/";
            qsId += node.text.substr(anchorPos + qsAnchor.length, 4)
            qsId += ".png"
            vFormatted += '<img src="' + qsId + '"/>'
            //console.log("YDictOxfordUtilities.js === htmlNodeToFormatted NT_Img.src: ", qsId)
        }
        break;
        //为了让上标显示在同一行
    case HtmlNodeType.NT_Sup:
    case HtmlNodeType.NT_Sub:
        var qsNodeName = getHtmlNodeTypeName(node.type);
        vFormatted += "<" + qsNodeName + ">" + node.text + "</" + qsNodeName + ">"
        break;
    case HtmlNodeType.NT_I:
        vFormatted += formatTextFontFamily(node.text, "Castoro") //(node.text, FontFromNode(NT_I, ft), clr, 0, alig, del);
        break;
    case HtmlNodeType.NT_B:
    case HtmlNodeType.NT_Em:
        vFormatted += formatTextFontWeight(node.text, 500) //(node.text, FontFromNode(NT_B, ft), clr, 0, alig, del);
        break;
    case HtmlNodeType.NT_Icon:
        vFormatted += formatBorderText(node.text);
        break;
    case HtmlNodeType.NT_Gray:
        vFormatted += formatText(node.text, "#909199") //(node.text, ft, s_themeTextGray, 0, alig, del);
        break;
    case HtmlNodeType.NT_PlainText:
    case HtmlNodeType.NT_Arrow:
    default:
        vFormatted += node.text //(node.text, ft, clr, 0, alig, del);
        break;
    }
    return vFormatted
}

function htmlToFormatted(qsHtml) {
    if (typeof qsHtml != "string") {
        return ""
    }
    var qsEscaped = escapeString(qsHtml)
    if (!qsEscaped[1]) {
        return qsEscaped[0]
    }
    //console.log("YDictOxfordUtilities.js === htmlToFormatted qsEscaped: ", qsEscaped[0])
    var vRoot = parseHtml(qsEscaped[0])
    var vFormatted = htmlNodeToFormatted(vRoot/*, ft, clr, alig, del*/)
    vFormatted = vFormatted.replace(/←/g, '<span style="font-family:OPPOSans;">←</span>') // "←→"
    vFormatted = vFormatted.replace(/→/g, '<span style="font-family:OPPOSans;">→</span>') // "←→"
    //console.log("YDictOxfordUtilities.js === htmlToFormatted vFormatted: ", vFormatted)
    return vFormatted
}

function phoneticToStringList(vi) {
    var qslPhonetic = []
    if (typeof vi == "undefined") {
        return qslPhonetic
    }
    let vPhonetic = []
    if (isArrayFn(vi)) {
        vPhonetic = vi
    } else {
        vPhonetic = [vi]
    }
    vPhonetic.forEach(function(vObj){
        let qsPhonetic = ""
        if (typeof vObj.g != "undefined") {
            vObj.g.forEach(function(v){
                if (qsPhonetic.length > 0) {
                    qsPhonetic += "&nbsp;"
                }
                qsPhonetic += v.g
            })
        }
        if (typeof vObj.il != "undefined")
        {
            if (qsPhonetic.length > 0) {
                qsPhonetic += "&nbsp;"
            }
            qsPhonetic += ("<i>" + vObj.il + "</i>")
        }
        if (typeof vObj.cm != "undefined")
        {
            if (qsPhonetic.length > 0) {
                qsPhonetic += "&nbsp;"
            }
            qsPhonetic += vObj.cm
        }
        if (typeof vObj.content != "undefined" && vObj.content.length > 0) {
            qsPhonetic += ' /' + vObj.content + '/ '
        }
        if (qsPhonetic.length > 0)
        {
            qslPhonetic.push(qsPhonetic);
        }
    })
    return qslPhonetic;
}

function phoneticToFormattedText(qslPhonetic, qsPos) {
    var vFormattedText = ''
    if (typeof qslPhonetic == "undefined" || qslPhonetic.length !== 2) {
        return vFormattedText
    }
    qslPhonetic[0].forEach(function(qsPhonetic){
        let format = htmlToFormatted(qsPhonetic);
        if (format.length > 0) {
            vFormattedText += format + "&nbsp;"
        }
    })
    qslPhonetic[1].forEach(function(qsPhonetic, index){
        let format = (index === 0) ? htmlToFormatted("<i>NAmE </i>" + qsPhonetic) : htmlToFormatted(qsPhonetic)
        if (format.length > 0) {
            vFormattedText += format + "&nbsp;"
        }
    })
    return vFormattedText
}

function ptToFormatted(vpt) {
    var qsPt = ""
    if (typeof vpt == "undefined") {
        return qsPt
    }
    vpt.forEach(function(vObj){
        var qs = typeof vObj.q != "undefined" ? vObj.q : ""
        var qsP = typeof vObj.pt != "undefined" ? vObj.pt : ""
        //adv./prep.这种pt需要前置‘+’号
        if (qsP.indexOf('/') >= 0) {
            qsP = " + " + qsP
        }
        if (qsPt.length > 0) {
            if (qsP.indexOf('/') < 0 || qs.length > 0) {
                qsPt += ", "
            }
        }
        qsPt += qs + (qs.length > 0 ? "&nbsp;" : '') + qsP
    })
    if (qsPt.length > 0) {
        qsPt = '[' + qsPt + ']'
        qsPt = formatText(htmlToFormatted(qsPt), "#909199")
    }
    return qsPt;
}

function pt1ToFormatted(vpt) {
    var qsPt = ""
    if (typeof vpt == "undefined") {
        return qsPt
    }
    vpt.forEach(function(vObj){
        if (qsPt.length > 0) {
            qsPt += ", "
        }
        qsPt += vObj.q + "&nbsp;" + vObj.pt1
    })
    if (qsPt.length > 0) {
        qsPt = "[ " + qsPt + " ]"
    }
    return qsPt
}

function aToFormatted(va, bTm) {
    var vFormatted = ""
    if (typeof va == "string") {
        var qsA = htmlToFormatted(va)
        if (bTm) {
            qsA += "™"
        }
        vFormatted += formatText(qsA + "&nbsp;", "#F03043")
    } else if(typeof va == "object") {
        if (isArrayFn(va)) {
            var qsStringItem = ""
            va.forEach(function(v){
                if (typeof v == "string") {
                    if (qsStringItem.length > 0) {
                        qsStringItem += ", "
                    }
                    qsStringItem += v
                } else if (typeof v == "object") {
                    if (qsStringItem.length > 0) {
                        qsStringItem += "&nbsp;"
                        vFormatted += formatText(qsStringItem, "#F03043", 500)
                        qsStringItem = ""
                    }
                    var f = aToFormatted(v, false);
                    if (f.length > 0) {
                        vFormatted += f + "&nbsp;"
                    }
                }
            })
            if (qsStringItem.length > 0) {
                vFormatted += formatText(qsStringItem, "#F03043", 500)
            }
        } else {
            vFormatted += '(' + va.q + formatText(va.content, "#F03043", 500)
            var qsGr = ""
            if (typeof va.gr != "undefined") {
                if (va.gr.gr.length > 0) {
                    qsGr = " [" + va.gr.gr + ".]"
                }
            }
            vFormatted += qsGr + ')&nbsp;'
        }
    }
    return vFormatted;
}

function vToString(vObj) {
    var qsTmp = ""
    if (typeof vObj.v == "string" && vObj.v.length > 0) {
        qsTmp += vObj.v
        if (typeof vObj.tm != "undefined") {
            qsTmp += "™"
        }
    }
    if (typeof vObj.vs == "string" && vObj.vs.length > 0) {
        qsTmp += "&nbsp;" + vObj.vs
    }
    if (typeof vObj.vc == "string" && vObj.vc.length > 0) {
        qsTmp += "&nbsp;" + vObj.vc
    }
    return qsTmp;
}

function grToString(vgr, qsName, qsSep) {
    if (typeof vgr == "undefined") {
        return ""
    }
    var qsGr = ""
    vgr.forEach(function(vObj, index){
        var qsCm = typeof vObj.cm != "undefined" ? vObj.cm.content : ""
        if (qsCm.length > 0) {
            qsGr += "&nbsp;" + qsCm + "&nbsp;"
        } else if (index > 0) {
            qsGr += qsSep
        }
        var qsQ = typeof vObj.q != "undefined" ? vObj.q : ""
        var qsObjCur = typeof vObj[qsName] != "undefined" ? vObj[qsName] : ""
        qsGr += qsQ
        if (qsQ.length > 0 && qsObjCur.length > 0) {
            qsGr += "&nbsp;"
        }
        qsGr += qsObjCur
    })
    return qsGr
}

function specialVsgToFormatted(vsg) {
    var qslV = []
    vsg.v.forEach(function(vString){
        qslV.push("<b>" + vString + "</b>")
    })
    if (qslV.length <= 0) {
        return "";
    }
    var qsIg = ""
    if (typeof vsg["i-g"] != "undefined") {
        var qslI = phoneticToStringList(vsg["i-g"].i);
        var qslY = phoneticToStringList(vsg["i-g"].y);
        var qslIY = qslI.concat(qslY)
        qsIg = qslIY.join("&nbsp;");
    }
    var qsR = ""
    if (typeof vsg.r != "undefined") {
        qsR = grToString(vsg.r, "r", "&nbsp;");
    }
    var qsG = ""
    if (typeof vsg.g != "undefined") {
        qsG = grToString(vsg.g, "g", "&nbsp;");
    }
    //xml转json后已经无法得知i-g应该放在哪里，目前被审核出有问题的单词音标都在第一个v后面，就这样处理了
    if (qsIg.length > 0) {
        qslV[0] += "&nbsp;" + qsIg
    }
    if (qsR.length > 0) {
        qslV[0] = qsR + "&nbsp;" + qslV[0]
    }
    if (qsG.length > 0) {
        qslV[0] = qsG + "&nbsp;" + qslV[0]
    }
    else if (qsR.length === 0) {
        qslV[0] += "also " + qslV[0]
    }
    return '(' + qslV.join(", ") + ')&nbsp;'
}

function isForceGenAlso(qsV) {
    var s_qslForceAlso = ["teen", "ˈtea service", "re·searches", "re·mold", "Dept.", "I daresay", "ˌmanic-deˈpressive", "damned", "m", "ˌcash up ˈfront", "tes·ta·ment", "cali·per", "draught", "mile·post"]
    return s_qslForceAlso.indexOf(qsV) >= 0
}

function isForceNotGenAlso(qsV) {
    var s_qslForceNotAlso = ["cozi·ly", "cozi·ness"]
    return s_qslForceNotAlso.indexOf(qsV) >= 0
}

function vsgToFormatted(vsg, bMean) {
    if (typeof vsg == "undefined") {
        return ""
    }
    if (typeof bMean == "undefined") bMean = true
    var qsVsg = ""
    vsg.forEach(function(vObj){
        if (typeof vObj != "object" || isArrayFn(vObj)) {
            return
        }
        var qsV = vToString(vObj);
        //xml数据转json丢失了节点的顺序信息，car的第二个释义的vs-g需要特殊处理
        if (vObj.v === "rail·car") {
            qsVsg += "(also <b>rail·car</b> both <i>NAmE</i>)";
            return
        }
        if (typeof vObj.gr1 != "undefined") {
            qsVsg += '['
            vObj.gr1.forEach(function(vGr1Obj, index){
                //特殊处理birch, fum·bling, bangs
                if (index > 0 && (qsV === "ˈbirch tree" || qsV === "bangs")) {
                    qsVsg += ", "
                }
                qsVsg += vGr1Obj.gr1
            })
            qsVsg += ']'
        }
        if (typeof vObj["g-vsg"] != "undefined") {
            qsVsg += '('
            vObj["g-vsg"].forEach(function(vGvsgObj, index){
                if (index > 0) {
                    qsVsg += ", "
                }
                qsVsg += vGvsgObj["g-vsg"]
            })
            qsVsg += ')&nbsp;'
        }
        if (typeof vObj.v != "undefined" || typeof vObj.vs != "undefined" || typeof vObj.vc != "undefined") {
            //针对v是数组的情况特殊处理
            if (isArrayFn(vObj.v)) {
                qsVsg += specialVsgToFormatted(vObj)
                return
            }
            qsVsg += '('
            var qsTmp = ""
            var bForceGenAlso = isForceGenAlso(trim(qsV)) || typeof vObj.g == "undefined"
            var bForceNotGenAlso = isForceNotGenAlso(trim(qsV))
            var qsG = ""
            if (typeof vObj.g != "undefined") {
                qsG = grToString(vObj.g, "g", bForceGenAlso ? ", " : "&nbsp;");
            }
            if (!bForceGenAlso && qsG.length > 0) {
                qsTmp += qsG + "&nbsp;"
            }
            if (typeof vObj.r != "undefined") {
                qsTmp += grToString(vObj.r, "r", "&nbsp;") + "&nbsp;"
            }
            qsTmp += "<b>" + qsV + "</b>"
            if (typeof vObj.gr != "undefined") {
                qsTmp += ' [' + grToString(vObj.gr, "gr", ", ") + ']'
            }
            if (bForceGenAlso && qsG.length > 0) {
                qsTmp += "&nbsp;" + qsG
            }

            if (typeof vObj["i-g"] != "undefined") {
                var qslI = phoneticToStringList(vObj["i-g"].i)
                var qslY = phoneticToStringList(vObj["i-g"].y)
                if (qslY.length > 0) {
                    qslI.push("<i>NAmE</i>")
                }
                var qslIY = qslI.concat(qslY)
                if (qslIY.length > 0) {
                    qsTmp += "&nbsp;" + qslIY.join("&nbsp;")
                }
            }
            if (bForceGenAlso) {
                qsVsg += "also "
            } else if (!bForceNotGenAlso) {
            } else if (!bMean || (typeof vObj.g == "undefined" && typeof vObj.r == "undefined")) {
                qsVsg += qsTmp.indexOf("&nbsp;") >= 0 ? "also " : "see "
            }
            qsVsg += qsTmp + ')&nbsp;'
        }
    })
    return qsVsg
}

function ccCfToFormatted2(vcc, vcf, qsSep) {
    var fCc = ccCfToFormatted(vcc, qsSep)
    var fCf = ccCfToFormatted(vcf, qsSep)
    if (fCc.length > 0 && fCf.length > 0) {
        fCc += formatText(qsSep, "#F03043")
    }
    fCc += fCf
    return fCc
}

function ccCfToFormatted(vc, qsSep) {
    if (typeof vc == "undefined") {
        return ""
    }
    if (typeof qsSep == "undefined") qsSep = " | "
    if (typeof vc == "string") {
        return formatText(vc, "#F03043")
    }
    var f = ""
    vc.forEach(function(vQs){
        if (typeof vQs == "string" && vQs.length > 0) {
            if (f.length > 0 && qsSep.length > 0) {
                f += formatText(qsSep, "#909199")
            }
            f += formatText(htmlToFormatted(vQs), "#F03043")
        }
    })
    return f;
}

function cmToString(vcm) {
    if (typeof vcm == "string") {
        return vcm
    } else if (typeof vcm == "object" && typeof vcm.content != "undefined") {
        if (typeof vcm.chn != "undefined" && typeof vcm.chn.content != "undefined") {
            return vcm.content + vcm.chn.content
        }
        return vcm.content
    }
    return "";
}

function ilToString(vIl) {
    var qsIl = ""
    if (typeof vIl == "object") {
        if (isArrayFn(vIl)) {
            vIl.forEach(function(vIlObj){
                if (qsIl.length > 0) {
                    qsIl += "&nbsp;"
                }
                qsIl += vIlObj.il
            })
        } else {
            qsIl = vIl.il
        }
    }
    return qsIl;
}

function grArrToFormatted(vgr, hasBracket) {
    if (typeof hasBracket == "undefined") hasBracket = true
    var qsGr = grToString(vgr, "gr", ", ");
    if (qsGr.length > 0) {
        if (hasBracket) {
            qsGr = '[' + qsGr + ']'
        }
        qsGr = formatText(qsGr, "#909199")
    }
    return qsGr;
}

function grToFormatted(v, bHasBracket, bGBeforeR) {
    if (typeof v == "undefined") {
        return ""
    }
    if (typeof bHasBracket == "undefined") bHasBracket = true
    if (typeof bGBeforeR == "undefined") bGBeforeR = true
    var vFormatted = ""
    if (typeof v.gr != "undefined") {
        vFormatted = grArrToFormatted(v.gr);
    }
    var qsG = ""
    if (typeof v.g != "undefined") {
        qsG = grToString(v.g, "g", ", ")
        //只有ab initio
        if (typeof v.s != "undefined") {
            qsG += ", <i>" + v.s.s + "</i>"
        }
    }
    var qsR = ""
    var qsCm = cmToString(v.cm)
    if (typeof v.r != "undefined") {
        qsR = grToString(v.r, "r", ", ")
        //只有carnal knowledge
        if (typeof v.s != "undefined" && typeof v.g != "undefined") {
            qsR += "&nbsp;" + qsCm + "&nbsp;" + v.s.s
        }
    }
    var qsResult = bGBeforeR ? qsG : qsR
    if (qsG.length > 0 && qsR.length > 0) {
        if (qsCm.length > 0) {
            qsResult += "&nbsp;" + qsCm + "&nbsp;"
        } else {
            qsResult += ", "
        }
    }
    qsResult += bGBeforeR ? qsR : qsG
    if (qsResult.length > 0) {
        if (bHasBracket) {
            qsResult = '(' + qsResult + ')&nbsp;'
        }
        vFormatted += formatText(htmlToFormatted(qsResult), "#909199")
    }
    return vFormatted;
}

function specialIdxForIrregualrIg(qsFirstIf) {
    if (qsFirstIf === "running")
    {
        return 1;
    }
    return -1;
}

function irregularIgPhoneticToFormattedText(v) {
    if (typeof v == "undefined") {
        return ""
    }
    var vFormattedText = ""
    var vArr = []
    if (isArrayFn(v)) {
        vArr = v
    } else {
        vArr.push(v)
    }
    vArr.forEach(function(vObj){
        if (typeof vObj.content != "string") {
            return
        }
        var qsContent = vObj.content
        var qsCm = vObj.cm
        var qsIll = vObj.il
        var qsG = grToString(vObj.g, "g", "&nbsp;");
        if (qsContent.length > 0) {
            //qsContent = "<b>/" + qsContent + "/</b>"
            qsContent = "/" + qsContent + "/"
            if (typeof qsCm == "string" && qsCm.length > 0) {
                qsContent = "&nbsp;" + qsCm + qsContent + "&nbsp;"
            }
            if (typeof qsG == "string" && qsG.length > 0) {
                qsContent = "&nbsp;" + qsG + "&nbsp;" + qsContent
            }
            if (typeof qsIll == "string" && qsIll.length > 0) {
                qsContent = "<i> " + qsIll + " </i>" + qsContent
            }
            vFormattedText += htmlToFormatted(qsContent)
        }
    })
    return vFormattedText;
}

function irregularIgToFormattedText(vIg) {
    if (typeof vIg == "undefined") {
        return ""
    }
    var formatted = grToFormatted(vIg, false);
    if (formatted.length > 0) {
        formatted += "&nbsp;"
    }
    var viFormatted = irregularIgPhoneticToFormattedText(vIg.i);
    var vyFormatted = irregularIgPhoneticToFormattedText(vIg.y);
    viFormatted += formatted
    if (vyFormatted.length > 0) {
        viFormatted += formatText(" NAmE ", "#909199", 400, 18, "Castoro")
    }
    viFormatted += vyFormatted
    return viFormatted;
}

function irregularToFormattedText(vIrrList) {
    // pixsize 26
    var vFormattedText = ""
    if (typeof vIrrList == "undefined") {
        return vFormattedText
    }
    vIrrList.forEach(function(vIrrObj) {
        if (typeof vIrrObj != "object") {
            return
        }
        var vIrrFormat = ""
        var qsCmGlobal = cmToString(vIrrObj.cm);
        vIrrObj["if-g"].forEach(function(vObj, vObjIndex){
            if (typeof vObj != "object") {
                return
            }
            if (vIrrFormat.length > 0) {
                vIrrFormat += ", "
            }
            var qsCm = cmToString(vObj.cm)
            if (qsCm.length > 0) {
                qsCm = "&nbsp;" + qsCm + "&nbsp;"
            }
            if (typeof vObj.co != "undefined") {
                vIrrFormat += vObj.co
            }
            if (typeof vObj.il != "undefined") {
                var qsIl = ilToString(vObj.il)
                if (qsIl.length > 0) {
                    vIrrFormat += formatTextFontFamily(qsIl, "Castoro") + "&nbsp;"
                }
            }
            var vgr = grToFormatted(vObj, false);
            if (vgr.length > 0) {
                vIrrFormat += vgr + "&nbsp;"
            }
            var vIg = vObj["i-g"]
            var vIgArr = []
            if (isArrayFn(vIg)) {
                vIgArr = vIg
            } else {
                vIgArr = [vIg]
            }
            //无法得知音标与"if"的确切对应关系，特殊处理
            var vIfObj = []
            if (typeof vObj["if"] != "undefined" && isArrayFn(vObj["if"])) {
                vIfObj = vObj["if"]
            }
            var iSpecIdx = vIfObj.length <= 0 ? -1 : specialIdxForIrregualrIg(vIfObj[0])
            var jIndex = 0
            var fIf = ""
            vIfObj.forEach(function(vIfObjCur, vIfIndex){
                fIf += htmlToFormatted(vIfObjCur)
                if ((jIndex < vIgArr.length && iSpecIdx < 0) || vIfIndex === iSpecIdx) {
                    fIf += "&nbsp;" + irregularIgToFormattedText(vIgArr[jIndex])
                    jIndex++
                }
                //cm显示在vIf中间，json丢失了xml中的位置信息得这样处理
                if (qsCm.length > 0 && vIfIndex === (vIfObj.length - 1) / 2) {
                    fIf += qsCm
                } else if (vIfIndex +1 < vIfObj.length) {
                    fIf += ", "
                }
            })
            //cm显示在if-g列表中间，json丢失了xml中的位置信息得这样处理
            if (qsCmGlobal === "or" && vObjIndex === (vIfObj.length - 1) / 2) {
                fIf += qsCmGlobal
                qsCmGlobal = ""
            }
            vIrrFormat += fIf
        })
        if (qsCmGlobal.length > 0) {
            vIrrFormat += "&nbsp;" + qsCmGlobal + "&nbsp;"
        }

        if (vIrrFormat.length > 0) {
            vFormattedText += "(" + vIrrFormat + ")"
        }
        if (typeof vIrrObj.help != "undefined") {
            vFormattedText += " <icon>HELP</icon>" + vIrrObj.help.content + "&nbsp;" + vIrrObj.help.chn.content
        }
    })
    return vFormattedText
}

function uToFormattedText(vu, fontFamilyNameCh) {
    if (typeof vu == "undefined") {
        return ""
    }
    var qsEn = vu.content
    var qsCh = vu.chn.content
    if (qsEn.length <= 0 && qsCh.length <= 0) {
        return ""
    }
    var vFormatted = htmlToFormatted(qsEn);
    if (vFormatted.length > 0 && qsCh.length > 0) {
        vFormatted += "&nbsp;" + formatTextFontFamily(qsCh, fontFamilyNameCh)
    }
    return vFormatted
}

function xtToFormatted(qsXt) {
    if (typeof qsXt != "string" || qsXt.length <= 0) {
        return ""
    }
    var formatted = ""
    if (qsXt === "syn" || qsXt === "opp" || qsXt === "id1")
    {
        if (qsXt === "id1") {
            formatted = formatBorderText("IDM") + '&nbsp; see &nbsp;'
        } else {
            formatted = formatBorderText(qsXt.toUpperCase()) + '&nbsp;&nbsp;'
        }
    } else {
        var qsShow = ""
        if (qsXt === "useat") {
            qsShow = "—note at "
        } else if (qsXt === "see") {
            qsShow = "—see also "
        } else if (qsXt === "cp") {
            qsShow = "—compare "
        } else if (qsXt === "eq") {
            qsShow = "= "
        } else if (qsXt === "id") {
            qsShow = "—more at "
        } else if (qsXt === "arrow") {
            qsShow = "→ "
        } else {
            qsShow = qsXt + '&nbsp;'
        }
        formatted = htmlToFormatted(qsShow)
    }
    //console.log("YDictOxfordUtilities.js === xtToFormatted formatted: ", formatted)
    return formatted;
}

function specialXrToFormatted(vXr) {
    if (typeof vXr != "object") {
        return ""
    }
    var formatted = ""
    var vxh = vXr.xh
    if (isArrayFn(vxh) && vxh.length > 0) {
        formatted += formatText(vxh[0].toString(), "#F03043") + '&nbsp;&nbsp;'
        if (vxh.length > 1) {
            if (typeof vxh[1].cm != "undefined") {
                formatted += vxh[1].cm.toString() + '&nbsp;&nbsp;'
            }
            if (typeof vxh[1].content != "undefined") {
                //formatted += formatText(vxh[1].content.toString(), "509DEB") + '&nbsp;&nbsp;'
                formatted += formatText(vxh[1].content.toString(), "F03043") + '&nbsp;&nbsp;'
            }
        }
    }
    if (typeof vXr.xp != "undefined") {
        formatted += formatTextFontFamily(vXr.xp.toString(), "Castoro");
    }
    return formatted;
}

function xsToString(vxs) {
    if (typeof vxs == "string") {
        return vxs.toString()
    } else if (typeof vxs == "number") {
        var vxsNum = parseInt(vxs)
        return vxsNum.toString()
    }
    var qsXs = ""
    if (isArrayFn(vxs)) {
        vxs.forEach(function(vxsString){
            if (qsXs.length > 0) {
                qsXs += ", "
            }
            if (typeof vxsString == "string") {
                qsXs += vxs.toString()
            } else if (typeof vxsString == "number") {
                var vxsNum = parseInt(vxsString)
                qsXs += vxsNum.toString()
            }
        })
    }
    return qsXs
}

function xrToFormatted(xrOrg, wordText) {
    //outputInfo(xrOrg, "xrToFormatted")
    if (typeof xrOrg != "object") {
        return []
    }
    var vFormatted = []
    var vXr = []
    if (isArrayFn(xrOrg)) {
        vXr = xrOrg
    } else {
        vXr = [xrOrg]
    }
    var bSpecialWord = wordText === "nest";
    vXr.forEach(function(xrObj){
        var qsXt = bSpecialWord ? "id1" : xrObj.xt
        var fXt = ""
        //数据原因，"cert.", "MS", "OS", "TA"特殊处理
        if (wordText !== "cert." && wordText !== "MS" && wordText !== "OS" && wordText !== "TA") {
            fXt = xtToFormatted(qsXt)
        }
        var bFirst = true
        var formatted = ""
        xrObj.value.forEach(function(vvObj){
            if (!bFirst) {
                formatted += ", "
            }
            var qsXh = ""
            //目前只有light n idiom 13, 特殊处理
            if (isArrayFn(vvObj.xh)) {
                if (bFirst) {
                    formatted += fXt
                }
                bFirst = false;
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + specialXrToFormatted(vvObj)
                return
            }
            var vxh = null
            if (typeof vvObj.xh == "string") {
                vxh = new Object
                vxh["xh"] = vvObj.xh
                if (typeof vvObj.xs != "undefined") {
                    vxh["xs"] = vvObj.xs
                }
                if (typeof vvObj.xp != "undefined") {
                    vxh["xp"] = vvObj.xp
                }
            } else {
                vxh = vvObj.xh
            }
            if (typeof vvObj.pt != "undefined") {
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + ptToFormatted(vvObj.pt);
            }
            if (bFirst) {
                formatted += fXt
            }
            bFirst = false;
            var bShowXw = false
            //xt = id时不显示xw
            if (typeof vvObj.xw != "undefined" && !qsXt.startsWith("id")) {
                bShowXw = true;
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText(vvObj.xw, "#F03043") + '&nbsp;'
            }
            var fcm = ""
            if (typeof vxh.cm != "undefined" || typeof vvObj.cm != "undefined") {
                qsXh = (typeof vxh.cm != "undefined" ? vxh.cm : vvObj.cm)
                fcm = htmlToFormatted(qsXh);
            }
            if (bShowXw) {
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + fcm
            }
            if (typeof vxh.content != "undefined") {
                if (typeof vxh.content == "string") {
                    qsXh = vxh.content + '&nbsp;'
                } else if (isArrayFn(vxh.content)) {
                    vxh.content.forEach(function(contentString){
                        qsXh += contentString + '&nbsp;'
                    })
                }
                //formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText(htmlToFormatted(qsXh), "#509DEB")
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText(htmlToFormatted(qsXh), "#F03043")
            }
            if (!bShowXw) {
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + fcm
            }
            qsXh = ""
            if (typeof vxh.xh != "undefined") {
                if (typeof vxh.xh == "string") {
                    qsXh = vxh.xh
                } else {
                    qsXh = vxh.xh.content.toString()
                    if (typeof vxh.xh.xhm != "undefined") {
                        qsXh += "<sup>" + vxh.xh.xhm + "</sup>"
                    }
                }
            }
            if (typeof vvObj.xhm != "undefined" || typeof vxh.xhm != "undefined") {
                var vhm = typeof vvObj.xhm != "undefined" ? vvObj.xhm : vxh.xhm
                qsXh += "<sup>" + vhm + "</sup> "
            }
            //formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText(htmlToFormatted(qsXh), "#509DEB")
            formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText(htmlToFormatted(qsXh), "#F03043")
            if (typeof vxh.xp == "string") {
                formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatTextFontFamily(vxh.xp, "Castoro")
            }
            if (typeof vxh.xs != "undefined") {
                var qsXs = xsToString(vxh.xs)
                if (qsXs.length > 0) {
                    //formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText('(' + qsXs + ')&nbsp;', "#509DEB")
                    formatted += (formatted.length > 0 ? "&nbsp;" : "") + formatText('(' + qsXs + ')&nbsp;', "#F03043")
                }
            }
        })
        vFormatted.push(formatted)
    })
    //console.log("YDictOxfordUtilities.js === xrToFormatted formatted:", vFormatted)
    return vFormatted
}

function dcToFormatted(vdc, fontFamilyNameCh) {
    if (typeof vdc == "undefined") {
        return ""
    }
    var qsEn = vdc.content
    var qsCh = typeof vdc != "undefined" ? vdc.chn.content : ""
    if (qsEn.length <= 0 && qsCh.length <= 0) {
        return ""
    }
    var vFormatted = "&nbsp;(&nbsp;"
    if (qsEn.length > 0){
        vFormatted += htmlToFormatted(qsEn)
    }
    if (qsCh.length > 0) {
        if (vFormatted.length > 0) {
            vFormatted += "&nbsp;"
        }
        vFormatted += formatTextFontFamily(qsCh, fontFamilyNameCh)
    }
    vFormatted += "&nbsp;)&nbsp;"
    return vFormatted;
}

function ngExtInfoToFormatted(ngObj, bGBeforeR, fontFamilyNameCh) {
    if (typeof ngObj == "undefined") {
        return ""
    }
    var vFormatted = ""
    if (typeof ngObj.pt != "undefined"){
        vFormatted += ptToFormatted(ngObj.pt);
    }
    //特殊处理这种情况，有cm的话r\s显示在一起中间显示cm
    if (typeof ngObj.r != "undefined" && typeof ngObj.s != "undefined" && typeof ngObj.cm != "undefined") {
        var qs = '(' + grToString(ngObj.r, "r", ", ") + "&nbsp;"
                 + ngObj.cm.content + ' <i>' + ngObj.s.s + '</i>)'
        vFormatted += htmlToFormatted(qs)
    } else {
        vFormatted += grToFormatted(ngObj, true, bGBeforeR)
        if (typeof ngObj.s != "undefined" && typeof ngObj.g == "undefined") {
            var vs = ngObj.s
            if (typeof ngObj.s.s == "string" && ngObj.s.s.length > 0) {
                var qsSS = ngObj.s.s
                if (typeof ngObj.s.q == "string") {
                    qsSS = "&nbsp;" + ngObj.s.q + qsSS
                }
                vFormatted += htmlToFormatted("(<i>" + qsSS + "</i>)")
            }
        }
//        if (typeof ngObj.cm != "undefined" && typeof ngObj.cm.content == "string") {
//            //will ablutions about等单词
//            vFormatted += formatText("&nbsp;" + ngObj.cm.content + "&nbsp;", "", 400)
//        }
    }
    if (typeof ngObj.gAll != "undefined") {
        vFormatted += formatText(htmlToFormatted(ngObj.gAll), "", 400)
    }
    if (typeof ngObj.ab != "undefined") {
        vFormatted += "(" + formatTextFontFamily("abbr. ", "Castoro")
        var qsAb = ""
        if (typeof ngObj.ab == "string") {
            qsAb += ngObj.ab
        } else if (isArrayFn(ngObj.ab)) {
            ngObj.ab.forEach(function(abObj){
                if (typeof abObj != "string") {
                    return
                }
                if (qsAb.length > 0){
                    qsAb += ", "
                }
                qsAb += abObj
            })
        }
        //vFormatted += formatText(qsAb, "#509DEB") + ")"
        vFormatted += formatText(qsAb, "#F03043") + ")"
    }
    if (typeof ngObj.p1 != "undefined") {
        var qsP = ""
        ngObj.p1.forEach(function(p1Obj){
            if (typeof p1Obj != "string") {
                return
            }
            if (qsP.length > 0) {
                qsP += "&nbsp;"
            }
            qsP += p1Obj
        })
        vFormatted += formatTextFontFamily(qsP, "Castoro")
    }
    if (typeof ngObj["ifs-g"] != "undefined") {
        vFormatted += irregularToFormattedText(ngObj["ifs-g"])
    }
    if (typeof ngObj.cf != "undefined" || typeof ngObj.cc != "undefined") {
        var qsSep = "&nbsp;" + (typeof ngObj.cm != "undefined" ? ngObj.cm.content : "|") + "&nbsp;"
        vFormatted += ccCfToFormatted2(ngObj.cc, ngObj.cf, qsSep)
    }
    if (typeof ngObj["i-g"] != "undefined") {
        vFormatted += irregularIgToFormattedText(vng["i-g"])
    }
    if (typeof ngObj.u != "undefined") {
        vFormatted += dcToFormatted(ngObj.u, fontFamilyNameCh)
    }
    if (typeof ngObj.ds != "undefined") {
        vFormatted += dcToFormatted(ngObj.ds, fontFamilyNameCh)
    }
    if (typeof ngObj.mixStr == "string") {
        vFormatted += formatText(vng.mixStr, "", 400)
    }
    if (typeof ngObj.dc != "undefined")
    {
        vFormatted += dcToFormatted(ngObj.dc, fontFamilyNameCh);
    }
    return formatText(vFormatted, "#909199")
}

function dExtInfoToFormatted(vdObj) {
    if (typeof vdObj == "undefined") {
        return ""
    }
    var vFormatted = grToFormatted(vdObj)
    if (typeof vdObj.mixStr != "undefined") {
        vFormatted += formatText(htmlToFormatted(vd.mixStr.toString()), "#909199", 400)
    }
    if (typeof vdObj.pt != "undefined") {
        vFormatted += ptToFormatted(vdObj.pt)
    }
    return vFormatted
}

function meanNgGrToFormatted(meanDataNg, wordText, qsPosCur, fontFamilyNameCh) {
    if (meanDataNg === null || typeof meanDataNg == "undefined") {
        return ""
    }
    let qsCm = typeof meanDataNg.cm != "undefined" ? (" " + meanDataNg.cm.content + " ") : ", "
    var vFormmated = ""
    var vd = typeof meanDataNg.d != "undefined" ? meanDataNg.d : (typeof meanDataNg.ud != "undefined" ? meanDataNg.ud : new Object)
    if (typeof meanDataNg.sym != "undefined") {
        vFormmated += formatText("(", "#909199")
        vFormmated += formatTextFontFamily("symbol ", "Castoro")
        vFormmated += htmlToFormatted(meanDataNg.sym) + formatText(")", "#909199")
    }
    if (typeof meanDataNg.a != "undefined") {
        vFormmated += aToFormatted(meanDataNg.a, typeof meanDataNg.tm != "undefined")
    }
    if (typeof meanDataNg["vs-g"] != "undefined") {
        vFormmated += vsgToFormatted(meanDataNg["vs-g"])
    }
    //var ngCopy = Object.create(meanDataNg)
    var ngCopy = JSON.parse(JSON.stringify(meanDataNg))
    //n-g中的gr与ng.d中的gr要显示在一起，特殊处理
    if (typeof ngCopy.gr != "undefined" && typeof vd.gr != "undefined") {
        var qsNgCopyGr = grArrToFormatted(ngCopy.gr, false)
        var qsVdGr = grArrToFormatted(vd.gr, false)
        if (qsNgCopyGr.length > 0 || qsVdGr.length > 0) {
            vFormmated += formatText("[", "#909199")
                          + qsNgCopyGr + (qsNgCopyGr.length > 0 ? formatText(qsCm, "#909199") : "")
                          + qsVdGr + formatText("]", "#909199")
        }
        delete ngCopy.gr
        delete vd.gr
    }
    //ng中的r\g与ng.d中的r\g要显示在一起，特殊处理
    if ((typeof ngCopy.g != "undefined" || typeof ngCopy.r != "undefined")
        && (typeof vd.g != "undefined" || typeof vd.r != "undefined")) {
        if (typeof ngCopy.gr != "undefined") {
            vFormmated += formatText("[" + grToString(ngCopy.gr, "gr", ", ") + "]", "#909199")
            delete ngCopy.gr
        }
        var qsNgCopy = grToFormatted(ngCopy, false)
        var qsVd = grToFormatted(vd, false)
        if (qsNgCopy.length > 0 || qsVd.length > 0) {
            vFormmated += formatText("(", "#909199")
                          + qsNgCopy + (qsNgCopy.length > 0 ? formatText(qsCm, "#909199") : "")
                          + qsVd + formatText(")", "#909199")
        }
        delete ngCopy.g
        delete ngCopy.r
        delete vd.g
        delete vd.r
    }

    //这些单词的pt显示在例句后面
    var bPtAfterX = isPtAfterX(wordText, qsPosCur)
    if (bPtAfterX) {
        delete ngCopy.pt
    }
    //xml转json丢失了g/r的顺序信息，poop需要特殊处理
    vFormmated += ngExtInfoToFormatted(ngCopy, wordText !== "poop", fontFamilyNameCh)
    vFormmated += dExtInfoToFormatted(vd)
    var qsEn = typeof vd.content == "string" ? vd.content : ""
    var qsCh = (typeof vd.chn != "undefined" && typeof vd.chn.content == "string") ? vd.chn.content : ""
    if (qsEn.length > 0) {
        if (qsCh.length > 0) {
            qsEn += "&nbsp;"
        }
        vFormmated += htmlToFormatted(qsEn);
    }
    if (qsCh.length > 0) {
        vFormmated += formatTextFontFamily(htmlToFormatted(qsCh), fontFamilyNameCh)
    }
    //console.log("YDictOxfordUtilities.js === meanNgGrToFormatted vFormmated : ", vFormmated)
    return vFormmated
}

function meanNgXrToFormatted(vObj, wordText) {
    if (typeof vObj != "object") {
        return ""
    }
    var qsXt = (wordText === "nest" || typeof vObj.xt != "string") ? "id1" : vObj.xt
    var fXt = ""
    //数据原因，"cert.", "MS", "OS", "TA"特殊处理
    if (wordText !== "cert." && wordText !== "MS" && wordText !== "OS" && wordText !== "TA") {
        fXt = xtToFormatted(qsXt)
    }
    var bFirst = true
    var formatted = ""
    vObj.value.forEach(function(vvObj, index){
        if (!bFirst) {
            formatted += ", "
        }
        var qsXh = ""
        //目前只有light n idiom 13, 特殊处理
        if (isArrayFn(vvObj.xh)) {
            if (bFirst) {
                formatted += fXt
            }
            bFirst = false
            formatted += specialXrToFormatted(vvObj)
            return
        }
        var vxhTmp = new Object
        if (typeof vvObj.xh == "string") {
            vxhTmp["xh"] = vvObj.xh
        }
        if (typeof vvObj.xs != "undefined") {
            vxhTmp["xs"] = vvObj.xs
        }
        if (typeof vvObj.xp != "undefined") {
            vxhTmp["xp"] = vvObj.xp
        }
        if (typeof vvObj.pt != "undefined") {
            formatted += ptToFormatted(vvObj.pt)
        }
        if (bFirst) {
            formatted += fXt
        }
        bFirst = false;
        var bShowXw = false
        //xt = id时不显示xw
        if (typeof vvObj.xw != "undefined" && !qsXt.startWith("id")) {
            bShowXw = true
            formatted += formatText(vvObj.xw, "#F03043") + "&nbsp;"
        }
        var fcm = ""
        var vxh = typeof vvObj.xh == "string" ? vxhTmp : vvObj.xh
        if (typeof vxh.cm != "undefined" || typeof vvObj.cm != "undefined") {
            fcm = htmlToFormatted((typeof vxh.cm != "undefined" ? vxh.cm : vvObj.cm) + "&nbsp;")
        }
        if (bShowXw) {
            formatted += fcm
        }
        if (typeof vxh.content != "undefined") {
            if (typeof vxh.content == "string") {
                qsXh = vxh.content + "&nbsp;"
            } else if (isArrayFn(vxh.content)) {
                vxh.content.forEach(function(vxhContent){
                    if (typeof vxhContent != "string") {
                        return;
                    }
                    qsXh += vxhContent + "&nbsp;"
                })
            }
            //formatted += formatText(htmlToFormatted(qsXh), "#509DEB")
            formatted += formatText(htmlToFormatted(qsXh), "#F03043")
        }
        if (!bShowXw) {
            formatted += fcm
        }
        qsXh = ""
        if (typeof vxh.xh != "undefined") {
            if (typeof vxh.xh == "string") {
                qsXh = vxh.xh
            } else {
                qsXh = vxh.xh.content
                if (typeof vxh.xh.xhm == "number") {
                    qsXh += "<sup>" + vxh.xh.xhm + "</sup>"
                }
            }
        }
        if (typeof vvObj.xhm != "undefined" || typeof vxh.xhm != "undefined") {
            var vhm = typeof vxh.xhm != "undefined" ? vxh.xhm : vvObj.xhm
            if (typeof vhm == "number") {
                qsXh += "<sup>" + vhm + "</sup>"
            }
        }
        //formatted += formatText(htmlToFormatted(qsXh), "#509DEB");
        formatted += formatText(htmlToFormatted(qsXh), "#F03043");
        if (typeof vxh.xp == "string") {
            formatted += "&nbsp;" + formatTextFontFamily(vxh.xp, "Castoro")
        }
        if (typeof vxh.xs == "string") {
            //formatted += '(' + formatText(xsToString(vxh.value("xs")), "#509DEB") + ')&nbsp;'
            formatted += '(' + formatText(xsToString(vxh.value("xs")), "#F03043") + ')&nbsp;'
        }
    })
    //console.log("YDictOxfordUtilities.js === meanNgXrToFormatted formatted: ", formatted)
    return formatted
}

function helpEnToFormatted(helpObj) {
    var rst = []
    if (helpObj === null || typeof helpObj != "object") {
        return rst
    }
    if (typeof helpObj.content == "string") {
        rst.push(helpObj.content.toString());
    } else if (isArrayFn(helpObj.content)) {
        rst = helpObj.content
    }
    //console.log("YDictOxfordUtilities.js === helpEnToFormatted qslEn : ", rst)
    return rst
}

function helpChToFormatted(helpObj) {
    var rst = ""
    if (helpObj === null || typeof helpObj != "object") {
        return rst
    }
    if (typeof helpObj.chn != "undefined" && typeof helpObj.chn.content == "string") {
        rst = helpObj.chn.content
    }
    //console.log("YDictOxfordUtilities.js === helpChToFormatted qsCh : ", rst)
    return rst
}

function idiomNgToFormatted(idiomNgObj, fontFamilyNameCh) {
    // #909199, "Nunito Sans", 28, 500
    if (typeof idiomNgObj != "object") {
        return ""
    }
    var idiomNgDObj = null
    if (typeof idiomNgObj.d == "object") {
        idiomNgDObj = idiomNgObj.d
    } else if (typeof idiomNgObj.ud == "object") {
        idiomNgDObj = idiomNgObj.ud
    } else {
        return ""
    }
    var vFormmated = ""
    if (typeof idiomNgObj.n != "undefined") {
        vFormmated += formatText('(' + idiomNgObj.n + ')&nbsp;', "#FFFFFF")
    }
    if (typeof idiomNgObj.a != "undefined") {
        vFormmated += idiomNgObj.a + "&nbsp;"
    }
    if (typeof idiomNgObj["vs-g"] != "undefined") {
        vFormmated += formatText(vsgToFormatted(idiomNgObj["vs-g"]), "#909199", 400) + "&nbsp;"
    }

    var ngCopy = JSON.parse(JSON.stringify(idiomNgObj))
    //某些习语中ng中的r\g与ng.d中的r\g要显示在一起，特殊处理
    if (typeof ngCopy.r != "undefined" && typeof idiomNgDObj.g != "undefined") {
        var fr = grToFormatted(ngCopy, false)
        var fg = grToFormatted(idiomNgDObj, false)
        vFormmated += "(" + fr + ", " + fg + ")&nbsp;"
        delete ngCopy.r
        delete idiomNgDObj.g
        delete idiomNgDObj.r
    }
    //cm在习语最开始处显示，移除避免在NgExtToFormatted 中重复处理
    delete ngCopy.cm
    vFormmated += ngExtInfoToFormatted(ngCopy, true, fontFamilyNameCh)
    let dExtInfo = dExtInfoToFormatted(idiomNgDObj)
    if (dExtInfo.length > 0) {
        if (vFormmated.length > 0) {
            vFormmated += "&nbsp;"
        }
        vFormmated += dExtInfo
    }
    var qsEn = idiomNgDObj.content
    if (qsEn.length >= 0) {
        vFormmated += formatText(htmlToFormatted(qsEn), "#FFFFFF")
    }
    var qsCh = ""
    if (typeof idiomNgDObj.chn == "object") {
        qsCh = idiomNgDObj.chn.content
    }
    if (qsCh.length >= 0) {
        if (vFormmated.length >= 0) {
            vFormmated += ("&nbsp;");
        }
        vFormmated += formatText(qsCh, "#FFFFFF", -1, -1, fontFamilyNameCh)
    }
    //console.log("YDictOxfordUtilities.js === idiomNgToFormatted vFormmated:", vFormmated)
    return vFormmated
}

function etymToFormatted(etymObj, fontFamilyNameCh) {
    if (typeof etymObj != "object") {
        return ""
    }
    var qsMeanDataNgEtymEn = etymObj.content
    let vFormmated = ""
    if (qsMeanDataNgEtymEn.length > 0) {
        qsMeanDataNgEtymEn = "<icon>ORIGIN</icon> " + qsMeanDataNgEtymEn
        vFormmated += htmlToFormatted(qsMeanDataNgEtymEn)
    }
    var qsMeanDataNgEtymCh = typeof etymObj.chn != "undefined" ? etymObj.chn.content : ""
    if (qsMeanDataNgEtymCh.length > 0) {
        if (vFormmated.length > 0) {
            vFormmated += "&nbsp;"
        }
        vFormmated += formatTextFontFamily(qsMeanDataNgEtymCh, fontFamilyNameCh)
    }
    return vFormmated
}

function illTitleToFormatted(titleObj, fontFamilyNameCh) {
    //"Nunito Sans", 28, 500 #FFFFFF
    if (typeof titleObj != "object") {
        return ""
    }
    var qsEn = typeof titleObj.tarial == "string" ? titleObj.tarial : ""
    var qsContent = typeof titleObj.content == "string" ? htmlToFormatted(titleObj.content) : ""
    if (qsContent.length > 0){
        if (qsEn.length > 0) {
            qsEn += " "
        }
        qsEn += qsContent
    }
    var qsCh = typeof titleObj.chn != "undefined" ? titleObj.chn.content : ""
    if (qsCh.length > 0) {
        qsCh = formatTextFontFamily(qsCh, fontFamilyNameCh)
    }
    var qsRst = qsEn + ((qsEn.length > 0 && qsCh.length > 0) ? " " : "") + qsCh
    //console.log("YDictOxfordUtilities.js === illTitleToFormatted qsRst:", qsRst)
    return qsRst
}

//提取派生词列表
function deriavateWordToFormatted(v) {
    var formatted = ""
    if (typeof v == "string") {
        formatted += v
    } else if (isArrayFn(v)) {
        v.forEach(function(vd){
            if (typeof vd != "string") {
                return
            }
            if (vd.length > 0 && formatted.length > 0){
                formatted += ", "
            }
            formatted += vd
        })
    }
    if (formatted.length > 0) {
        formatted = formatText(formatted, "#FFFFFF")
    }
    return formatted
}

function derivateToFormatted(vObj, fontFamilyNameCh) {
    var vFormatted = deriavateWordToFormatted(vObj.dr)
    if (typeof vObj.u != "undefined") {
        var qsU = vObj.u.content + " " + vObj.u.chn.content
        if (typeof vObj.u.chn != "undefined") {
            if (qsU.length > 0) {
                qsU += " "
            }
            qsU += formatTextFontFamily(vObj.u.chn, fontFamilyNameCh)
        }
        vFormatted += " (" + qsU + ")"
    }
    if (typeof vObj.dre == "string" && vObj.dre.length > 0) {
        if (vFormatted.length > 0) {
            vFormatted += ", "
        }
        vFormatted += formatText(vObj.dre, "#FFFFFF")
    }
    return vFormatted
}

//提取派生词的a字段
function DeriavateAToFormatted(v) {
    var qsQ = typeof v.a == "string" ? v.a : ""
    if (qsQ.length > 0) {
        qsQ += " "
    }
    var qsContent = typeof v.content == "string" ? v.content : ""
    return "(" + qsQ + formatText(qsContent, "#F03043") + ")"
}

function derivateExtInfoToFormatted(vDer/*, const QFont &ftDr, const QFont& ftPos, const QFont& ftVsg*/) {
    var vFormatted = ""
    if (typeof vDer.cf != "undefined" || typeof vDer.cc != "undefined") {
        vFormatted += ccCfToFormatted2(vDer.cc, vDer.cf, " | ");
    }
    if (typeof vDer.a != "undefined") {
        vFormatted += deriavateAToFormatted(vDer.a)
    }
    if (vFormatted.length > 0) {
        vFormatted = formatText(vFormatted, "", 400, 0, "Castoro")
    }
    if (typeof vDer["vs-g"] != "undefined") {
        vFormatted += vsgToFormatted(vDer["vs-g"], false);
    }
    if (typeof vDer.p != "undefined") {
        var vp = []
        if (isArrayFn(vDer.p)) {
            vp = vDer.p
        } else {
            vp = [vDer.p]
        }
        var qsPos = ""
        vp.forEach(function(v) {
            if (qsPos.length > 0) {
                qsPos += ", "
            }
            qsPos += v.p
        })
        vFormatted += formatText(qsPos + "&nbsp;&nbsp;", "", 400, 0, "Castoro")
    }
    vFormatted += formatText(grToFormatted(vDer), "", 400, 0, "Castoro")
    if (typeof vDer.pt != "undefined") {
        vFormatted += formatText(ptToFormatted(vDer.pt), "", 400)
    }
    return vFormatted
}

