.pragma library

function OxfordModelObject() {
    this.wordText = ""
    this.wordListCount = 0
    this.posList = []
    this.bCoreWordList = []
    this.qsWordHeadList = []
    this.qsHeadEnd = []
    this.headPosList = []
    this.vPhoneticList = []
    this.vIrregularList = []
    this.vGlobalIrrList = []
    this.vGlobalGrList = []
    this.vGlobalU = []
    this.vGlobalVsgList = []
    this.vGlobalPtList = []
    this.vGlobalXr = []
    this.vGlobalA = []
    this.vGlobalCf = []
    this.vGlobalMixStr = []
    this.vGlobalAbbr = []
    this.vGlobalS = []
    this.vMeanList = []
    this.vIdiomList = []
    this.vPhraseList = []
    this.vIllustrationList = []
    this.vDerivates = []
    this.vGlobalHelp = []
    this.vGlobalCm = []
    this.vOrigins = []
    this.vFamily = []
}

function createOxfordModel() {
    var oxfordModel = new OxfordModelObject()
    return oxfordModel
}

function createOxfordModelByJsonData(dictJson) {
    if (dictJson === null) {
        console.log("YDictOxfordModel.js === createOxfordModelByJsonData() dictJson === null")
        return new OxfordModelObject()
    }

    var oxfordModel = new OxfordModelObject()
    oxfordModel.wordText = dictJson.wordList[0].Name
    oxfordModel.wordListCount = dictJson.wordList.length

    let i = 0;
    dictJson.wordList.forEach(function(wordListObject, wordListIndex){
        oxfordModel.posList[i] = parsePosList(wordListObject)
        oxfordModel.bCoreWordList[wordListIndex] = typeof wordListObject.core != "undefined" && wordListObject.core === "y"
        oxfordModel.qsWordHeadList[wordListIndex] = ""
        if (typeof wordListObject["h-g"] != "undefined") {
            let qsWordHeadCur = wordListObject["h-g"].h
            if (typeof wordListObject["h-g"].h2 != "undefined") {
                if (isArrayFn(wordListObject["h-g"].h2)) {
                    wordListObject["h-g"].h2.forEach(function(h2Object){
                        qsWordHeadCur += ",&nbsp;" + h2Object
                    })
                } else {
                    qsWordHeadCur += ",&nbsp;" + wordListObject["h-g"].h2
                }
            }
            if (typeof wordListObject["h-g"].hs != "undefined") {
                qsWordHeadCur = wordListObject["h-g"].hs + "&nbsp;" + qsWordHeadCur
            }
            oxfordModel.qsHeadEnd[wordListIndex] = typeof wordListObject["h-g"].he != "undefined" ? wordListObject["h-g"].he : ""
            if (qsWordHeadCur.length <= 0) {
                qsWordHeadCur = oxfordModel.wordText
            }
            if (typeof wordListObject["h-g"].tm != "undefined"
                    && wordListObject["h-g"].tm === "[TM]") {
                qsWordHeadCur += "™"
            }
            oxfordModel.qsWordHeadList[wordListIndex] = qsWordHeadCur
            if (isArrayFn(wordListObject["h-g"].p)) {
                oxfordModel.headPosList[wordListIndex] = wordListObject["h-g"].p
            } else {
                oxfordModel.headPosList[wordListIndex] = [wordListObject["h-g"].p]
            }
        }
        oxfordModel.vPhoneticList[i] = parsePhoneticList(wordListObject, oxfordModel.posList[i])
        oxfordModel.vIrregularList[i] = parseIrregularList(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalIrrList[i] = parseGlobalIrregularList(wordListObject)
        oxfordModel.vGlobalGrList[i] = parseGlobalGrList(wordListObject, oxfordModel.posList[i], oxfordModel.wordText)
        oxfordModel.vGlobalU[i] = parseGlobalU(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalVsgList[i] = parseGlobalVsgList(wordListObject, oxfordModel.posList[i], oxfordModel.wordText)
        oxfordModel.vGlobalPtList[i] = parseGlobalPtList(wordListObject, oxfordModel.posList[i], oxfordModel.wordText)
        oxfordModel.vGlobalXr[i] = parseGlobalXr(wordListObject, oxfordModel.posList[i], oxfordModel.wordText)
        oxfordModel.vGlobalA[i] = parseGlobalA(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalCf[i] = parseGlobalCf(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalMixStr[i] = parseGlobalMixStr(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalAbbr[i] = parseGlobalAbbr(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalS[i] = parseGlobalS(wordListObject, oxfordModel.posList[i])
        oxfordModel.vMeanList[i] = parseMeanList(wordListObject, oxfordModel.posList[i], oxfordModel.wordText, oxfordModel.posList[i])
        oxfordModel.vIdiomList[i] = parseIdiomList(wordListObject, oxfordModel.posList[i], oxfordModel.wordText, oxfordModel.posList[i])
        oxfordModel.vPhraseList[i] = parsePhraseList(wordListObject, oxfordModel.posList[i], oxfordModel.wordText, oxfordModel.posList[i])
        oxfordModel.vIllustrationList[i] = parseIllustrationList(wordListObject)
        oxfordModel.vDerivates[i] = parseDerivateList(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalHelp[i] = parseGlobalHelp(wordListObject, oxfordModel.posList[i])
        oxfordModel.vGlobalCm[i] = parseGlobalCm(wordListObject, oxfordModel.posList[i])
        oxfordModel.vOrigins[i] = parseOrigins(wordListObject, oxfordModel.posList[i])
        oxfordModel.vFamily[i] = parseFamilyGroup(wordListObject, oxfordModel.posList[i])

        // 此判断目前无意义
        if (oxfordModel.wordListCount > 1 && hasEffectData(oxfordModel, i)) {
            ++i;
        }
    })
    if (oxfordModel.wordListCount > 1) {
        if (i === 0) {
            return new OxfordModelObject()
        }
        oxfordModel.wordListCount = i;
    }

    //如果只有一个释义组删除掉没有释义的词性
    if (oxfordModel.wordListCount === 1) {
        let qslPos = []
        oxfordModel.posList[0].forEach(function(pos, index){
            // 此判断无意义先注掉
            if (hasEffectData(oxfordModel, index)) {
                qslPos.push(pos);
            }
        })
        if (qslPos.length <= 0) {
            return new OxfordModelObject()
        }
        oxfordModel.posList[0] = qslPos;
    }
    return oxfordModel
}

var MeanBlockType = Object.freeze({
    "MbtMeaning": 0,
    "MbtIdiom": 1,
    "MbtPhrase": 2,
    "MbtWhichWord": 3,
    "MbtSynonym": 4,
    "MbtGrammar": 5,
    "MbtMoreAbout": 6,
    "MbtVocab": 7,
    "MbtBA": 8,
    "MbtDerivate": 9,
    "MbtOrigin": 10,
    "MbtWordFamily": 11,
    "MbtCount": 12
})

function getMenuList(oxfordModel, currentMeanIdx) {
    var menuList = []
    if (hasMeans(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtMeaning})
    }
    if (hasIdioms(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtIdiom})
    }
    if (hasPhrase(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtPhrase})
    }
    if (hasWhichWord(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtWhichWord})
    }
    if (hasSynonyms(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtSynonym})
    }
    if (hasGrammar(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtGrammar})
    }
    if (hasMoreAbout(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtMoreAbout})
    }
    if (hasVocabulary(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtVocab})
    }
    if (hasBAData(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtBA})
    }
    if (hasDerivate(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtDerivate})
    }
    if (hasOrigin(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtOrigin})
    }
    if (hasWordFamily(oxfordModel, currentMeanIdx)) {
        menuList.push({"type": MeanBlockType.MbtWordFamily})
    }
    return menuList
}

//是否有当前可展示数据
function hasEffectData(oxfordModel, meanIdx) {
    return oxfordModel.wordListCount > 0;
    // ??? 判断注释掉了，为什么 ？？？ guohq
    //   && (hasMeans(meanIdx) || hasIdioms(meanIdx) || hasPhrase(meanIdx) || hasWhichWord(meanIdx) || hasSynonyms(meanIdx)
    //         || hasGrammar(meanIdx) || hasMoreAbout(meanIdx) || hasVocabulary(meanIdx) || hasBAData(meanIdx) || hasDerivate(meanIdx)
    //         || hasOrigin(meanIdx) || hasWordFamily(meanIdx));
}

//是否有当前可展示释义
function hasMeans(oxfordModel, meanIdx) {
    return hasData(oxfordModel, oxfordModel.vMeanList, meanIdx)
}
//是否有当前可展示习语
function hasIdioms(oxfordModel, meanIdx) {
    return hasData(oxfordModel, oxfordModel.vIdiomList, meanIdx);
}
//是否有当前可展示短语动词
function hasPhrase(oxfordModel, meanIdx) {
    return hasData(oxfordModel, oxfordModel.vPhraseList, meanIdx);
}
//是否有当前可展示词语辨析
function hasWhichWord(oxfordModel, meanIdx) {
    return hasIllustration(oxfordModel, "which_word", meanIdx);
}
//是否有当前可展示同近义词辨析
function hasSynonyms(oxfordModel, meanIdx) {
    return hasIllustration(oxfordModel, "synald7", meanIdx)
           || hasIllustration(oxfordModel, "synonyms", meanIdx);
}
//是否有当前可展示语法说明
function hasGrammar(oxfordModel, meanIdx) {
    return hasIllustration(oxfordModel, "grammar", meanIdx);
}
//是否有当前可展示补充说明
function hasMoreAbout(oxfordModel, meanIdx) {
    return hasIllustration(oxfordModel, "more_about", meanIdx);
}
//是否有当前可展示词汇扩充
function hasVocabulary(oxfordModel, meanIdx) {
    return hasIllustration(oxfordModel, "vocab", meanIdx);
}
//是否有当前可展示英国/美国英语
function hasBAData(oxfordModel, meanIdx) {
    return hasIllustration(oxfordModel, "british_american", meanIdx);
}
//是否有当前可展示派生词
function hasDerivate(oxfordModel, meanIdx) {
    return hasData(oxfordModel, oxfordModel.vDerivates, meanIdx);
}
//是否有当前可展示词源
function hasOrigin(oxfordModel, meanIdx) {
    return hasData(oxfordModel, oxfordModel.vOrigins, meanIdx);
}
//是否有当前可展示词族
function hasWordFamily(oxfordModel, meanIdx) {
    return hasData(oxfordModel, oxfordModel.vFamily, meanIdx);
}
//获取词性列表
function getPosList(oxfordModel, currentMeanIdx) {
    if (oxfordModel.posList.length <= 0) {
        return []
    }
    var idx = oxfordModel.wordListCount > 1 ? currentMeanIdx : 0
    return oxfordModel.posList[idx]
}
//从词性获取释义列表
function getMeanList(oxfordModel, qsPos, currentMeanIdx) {
    if (oxfordModel.vMeanList.length <= 0) {
        return []
    }
    var idx = oxfordModel.wordListCount > 1 ? currentMeanIdx : 0
    return oxfordModel.vMeanList[idx][qsPos];
}
//获取词语辨析, ill->type = which_word
function getWhichWordList(oxfordModel, meanIdx) {
    return fetchIllustration(oxfordModel, "which_word", meanIdx);
}
//获取同近义词辨析 ill->type = synonyms | SYNALD7
function getSynonymsList(oxfordModel, meanIdx) {
    return fetchIllustration(oxfordModel, "synonyms", meanIdx, "synald7");
}
//获取语法说明 ill->type = grammar
function getGrammarList(oxfordModel, meanIdx) {
    return fetchIllustration(oxfordModel, "grammar", meanIdx);
}
//获取补充说明 ill->type = more_abount
function getMoreAboutList(oxfordModel, meanIdx) {
    return fetchIllustration(oxfordModel, "more_about", meanIdx);
}
//获取词汇扩充 ill->type = vocab
function getVocabList(oxfordModel, meanIdx) {
    return fetchIllustration(oxfordModel, "vocab", meanIdx);
}
//获取英国/美国英语 ill->type = british_american
function getBAList(oxfordModel, meanIdx) {
    return fetchIllustration(oxfordModel, "british_american", meanIdx);
}
//释义需要通过点击“查看更多释义”来展开
function isExpandable(oxfordModel, currentMeanIdx) {
    if (oxfordModel.wordListCount > 1) {
        return true
    }
    //有除释义外其他数据则需要展开
    var rst = false
    let qslPos = getPosList(oxfordModel, currentMeanIdx)
    qslPos.forEach(function(qsPos, index){
        if (rst) {
            return
        }
        var bExpandable = (hasIdioms(oxfordModel, index)
                            || hasPhrase(oxfordModel, index)
                            || hasWhichWord(oxfordModel, index)
                            || hasSynonyms(oxfordModel, index)
                            || hasGrammar(oxfordModel, index)
                            || hasMoreAbout(oxfordModel, index)
                            || hasVocabulary(oxfordModel, index)
                            || hasBAData(oxfordModel, index)
                            || hasDerivate(oxfordModel, index)
                            || hasOrigin(oxfordModel, index)
                            || hasWordFamily(oxfordModel, index))
        if (bExpandable) {
            rst = true
        }
    })
    if (rst) {
        return true
    }
    qslPos.forEach(function(qsPos){
        if (rst) {
            return
        }
        let meanList = getMeanList(oxfordModel, qsPos, currentMeanIdx)
        //释义有多条，需要展开
        if (meanList.length > 1) {
            rst = true
            return
        }
        if (meanList.length === 0) {
            return
        }
        //非展开时只显示了一个n-g块，如果有多个n-g块，需要展开
        let vng = meanList[0]["n-g"]
        if (vng.length > 1) {
            rst = true
            return
        }
        if (vng.length === 0) {
            return
        }
        //非展开时只显示了一个例句块，如果有多个例句块，需要展开
        if (typeof vng[0].x != "undefined" && vng[0].x.length > 1) {
            rst = true
            return
        }
    })
    return rst
}

function hasData(oxfordModel, data, meanIdx) {
    if (oxfordModel.wordListCount === 1) {
        var qsPos = oxfordModel.posList[0][meanIdx]
        var vData = data[0]
        if (typeof vData[qsPos] != "undefined") {
            return Object.keys(vData[qsPos]).length > 0
        }
    } else {
        return (data.length > meanIdx) && (Object.keys(data[meanIdx]).length > 0)
    }
    return false
}

function hasIllustration(oxfordModel, qsType, meanIdx) {
    var idx = oxfordModel.wordListCount === 1 ? 0 : meanIdx
    var rst = false
    oxfordModel.vIllustrationList[idx].forEach(function(vIll){
        if (rst || typeof vIll.value == "undefined") {
            return
        }
        if (vIll.value.type === qsType) {
            rst = true
        }
    })
    return rst
}

function fetchIllustration(oxfordModel, qsType, meanIdx, qsAlias) {
    var idx = oxfordModel.wordListCount === 1 ? 0 : meanIdx
    if (typeof qsAlias == "undefined") qsAlias = ""
    var arr = []
    oxfordModel.vIllustrationList[idx].forEach(function(vIll){
        let qsCurType = vIll.value.type
        if (qsCurType === qsType || (qsAlias.length > 0 && qsCurType === qsAlias)) {
            arr.push(vIll)
        }
    })
    return arr
}

function parsePgPos(vData) {
    let qsPos = ""
    if (typeof vData == "undefined" || typeof vData.p == "undefined") {
        return qsPos
    }
    vData.p.forEach(function(v, index){
        if (qsPos.length > 0)
        {
            qsPos += " & "
        }
        qsPos += v.p
    })
    return qsPos
}

function parsePosList(vData) {
    let vhg = vData["h-g"]
    let qslDefPos = []
    if (isArrayFn(vhg.p)) {
        vhg.p.forEach(function(v, index){
            qslDefPos.push(v.p)
        })
    }
    let qslPos = []
    if (typeof vData["p-g"] != "undefined") {
        var i = 0;
        vData["p-g"].forEach(function(v, index){
            let qsPos = parsePgPos(v);
            if (qsPos.length <= 0 && i < qslDefPos.length)
            {
                qsPos = qslDefPos[i++]
            }
            if (qslPos.indexOf(qsPos) >= 0)//如will有两个"v"词性，添加‘*’号区分
            {
                qsPos = '*' + qsPos
            }
            qslPos.push(qsPos);
        })
    } else {
        qslPos = [qslDefPos.join(", ")];
    }
    if (qslPos.length <= 0) {
        qslPos = [""];
    }
    return qslPos;
}

function phoneticToStringListPair(vData) {
    if (typeof vData == "undefined") {
        return [[], []]
    }
    var qslUk = typeof vData.i != "undefined" ? phoneticToStringList(vData.i) : []
    var qslUs = typeof vData.y != "undefined" ? phoneticToStringList(vData.y) : []
    //into特殊处理
    if (typeof vData.il != "undefined" && vData.il.il.length > 0) {
        qslUk.splice(1, 0, "<i>" + vData.il.il + "</i>")
    }
    var qsG = ""
    if (typeof vData.g != "undefined") {
        vData.g.forEach (function(v){
            if (qsG.length > 0) {
                qsG += ' '
            }
            qsG += v.g
        })
    }
    if (qsG.length > 0) {
        qsG += ' '
        if (qslUs.length > 0) {
            qslUs[0] = qsG + qslUs[0]
        } else {
            qslUs.push(qsG);
        }
    }
    return [qslUk, qslUs]
}

function parsePhoneticList(vData, qslPos) {
    let phoneticList = new Map()
    if (qslPos.length <= 0) return phoneticList
    //如果只有一个词性，或者所有词性发音相同时音标在h-g->i-g中，否则在p-g的各个成员中
    let vhg = vData["h-g"]
    let defPhonetic = phoneticToStringListPair(vhg["i-g"])
    if (qslPos.length === 1)
    {
        phoneticList[qslPos[0]] = defPhonetic
        return phoneticList;
    }
    var vpg = []
    if (isArrayFn(vData["p-g"])) {
        vpg = vData["p-g"]
    } else //if (vpg.isObject())//contemptive的p-g是object
    {
        vpg = [vpg]
    }
    if (vpg.length > qslPos.length) {
        return phoneticList;
    }
    vpg.forEach(function(vEleObj, index){
        var phonetic = phoneticToStringListPair(vEleObj["i-g"]);
        if (phonetic[0].length <= 0) {
            phonetic[0] = defPhonetic[0]
        }
        if (phonetic[1].length <= 0) {
            phonetic[1] = defPhonetic[1]
        }
        phoneticList[qslPos[index]] = phonetic
    })
    return phoneticList;
}

function parseIrregularList(vData, qslPos) {
    var irregularList = new Map()
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return irregularList
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj["ifs-g"] != "undefined" && typeof vObj.d == "undefined") {
                irregularList[qslPos[index]] = vObj["ifs-g"]
            }
        })
    }
    return irregularList;
}

function parseGlobalIrregularList(vData) {
    if (typeof vData["h-g"]["ifs-g"] != "undefined") {
        return vData["h-g"]["ifs-g"]
    }
    return [];
}

function fExtract(vObj, vGr) {
    if (typeof vGr == "undefined") {
        return
    }
    if (typeof vObj.d == "undefined") {
        if (typeof vObj.gr != "undefined") {
            vGr["gr"] = vObj.gr
        }
        //if (typeof vObj["n-g"] == "undefined") {
            if (typeof vObj.g != "undefined") {
                vGr["g"] = vObj.g
            }
            if (typeof vObj.r != "undefined") {
                vGr["r"] = vObj.r
            }
        //}
    }
    if (typeof vObj.cm != "undefined") {
        vGr["cm"] = vObj.cm
    }
    //return JSON.parse(JSON.stringify(vGr))
}

function parseGlobalGrList(vData, qslPos, qsWord) {
    var vGrList = new Map()
    var vhg = vData["h-g"]
    var vGr = new Object
    fExtract(vhg, vGr)
    var s_specialWord = ["carnal knowledge", "ab initio"]
    //xml转json丢失了不少信息，carnal knowledge\ab initio这些词s要给r显示在一起，特殊处理
    if (s_specialWord.indexOf(qsWord) >= 0) {
        vGr["s"] = vhg.s
        vGr["cm"] = vhg.cm
    }

    if (typeof vData["p-g"] == "undefined") {
        qslPos.forEach(function(qsPos){
            vGrList[qsPos] = vGr
        })
        return vGrList;
    } else {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vGrList
        }
        vpg.forEach(function(vObj, index){
            //var vGrTmp = Object.create(vGr)
            var vGrTmp = Object.keys(vGr).length > 0 ? JSON.parse(JSON.stringify(vGr)) : (new Object)
            //if (typeof vObj["n-g"] == "undefined") {
                fExtract(vObj, vGrTmp)
            //}
            if (Object.keys(vGrTmp).length > 0) {
                vGrList[qslPos[index]] = vGrTmp
            }
        })
    }
    return vGrList;
}

function parseGlobalU(vData, qslPos) {
    var vU = new Map()
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vU
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj.d == "undefined" && typeof vObj.u != "undefined") {
                vU[qslPos[index]] = vObj.u
            }
        })
    } else if (typeof vData["h-g"] != "undefined") {
        var vhg = vData["h-g"]
        if (typeof vhg.d == "undefined" && typeof vhg.u != "undefined")
        {
            vU[qslPos[0]] = vhg.u
        }
    }
    return vU;
}

function parseMeanExtInfo(vData, qslPos, qsInfo, qsWord) {
    var meanExtInfo = new Map
    var bGot = false
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length <= qslPos.length) {
            vpg.forEach(function(vObj, index){
                //pressure, 词性为v的pt不全局显示，特殊处理
                if (qsInfo === "pt" && qsWord === "pressure" && qslPos[index] === "v") {
                    return
                }
                //vs-g不合并到已经存在的n-g中typeof vObj.d == "undefined"
                if (typeof vObj[qsInfo] != "undefined" && typeof vObj.d == "undefined"
                        && (typeof vObj["n-g"] == "undefined" || qsInfo === "pt" || qsInfo === "vs-g"))
                {
                    bGot = true;
                    meanExtInfo[qslPos[index]] = vObj[qsInfo]
                }
            })
        }
    }
    if (!bGot) {
        var vhg = vData["h-g"]
        if (typeof vhg[qsInfo] != "undefined" && typeof vhg.d == "undefined") {
            meanExtInfo[qslPos[0]] = vhg[qsInfo]
        }
    }
    return meanExtInfo;
}

function parseGlobalVsgList(vData, qslPos, qsWord) {
    return parseMeanExtInfo(vData, qslPos, "vs-g", qsWord)
}

function parseGlobalPtList(vData, qslPos, qsWord) {
    return parseMeanExtInfo(vData, qslPos, "pt", qsWord)
}

function parseGlobalXr(vData, qslPos, qsWord) {
    return parseMeanExtInfo(vData, qslPos, "xr", qsWord)
}

function parseGlobalA(vData, qslPos) {
    var vA = new Map
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vA
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj.a != "undefined") {
                vA[qslPos[index]] = vObj.a
            }
        })
    } else {
        var vhg = vData["h-g"]
        if (typeof vhg.a != "undefined") {
            vA[qslPos[0]] = vhg.a
        }
    }
    return vA;
}

function parseGlobalCf(vData, qslPos) {
    var vCf = new Map
    var vhg = vData["h-g"]
    if (typeof vhg.cf != "undefined" && typeof vhg.d == "undefined") {
        qslPos.forEach(function(qsPos){
            vCf[qsPos] = vhg.cf
        })
        return vCf;
    }
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vCf
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj.cf != "undefined" && typeof vObj.d == "undefined") {
                vCf[qslPos[index]] = vObj.cf
            }
        })
    }
    return vCf;
}

function parseGlobalMixStr(vData, qslPos) {
    var vM = new Map()
    var bGot = false
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vM
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj.mixStr != "undefined" && typeof vObj.d == "undefined") {
                bGot = true;
                vM[qslPos[index]] = vObj.mixStr
            }
        })
    }
    if (!bGot) {
        var vhg = vData["h-g"]
        vM[qslPos[0]] = vhg.mixStr
    }
    return vM;
}

function parseHgInfo(vData, qslPos, qsInfo) {
    var vRst = new Map()
    var vhg = vData["h-g"]
    if (typeof vhg.d == "undefined" && typeof vhg[qsInfo] != "undefined") {
        vRst[qslPos[0]] = vhg[qsInfo]
    }
    return vRst;
}

function parseGlobalAbbr(vData, qslPos) {
    return parseHgInfo(vData, qslPos, "ad")
}

function parseGlobalS(vData, qslPos) {
    return parseHgInfo(vData, qslPos, "s")
}

function parseMean(vData, qsWord, qslPos) {
    var sdg = []
    //sdg的n-g也可能被“打散”了，需要处理一下
    if (typeof vData["sd-g"] != "undefined") {
        vData["sd-g"].forEach(function(vObj, index){
            if (typeof vObj["n-g"] != "undefined") {
                var vng = fixNgByType(vObj, s_meanBlockType.MbtMeaning, qsWord, qslPos)
                if (vng !== null)
                {
                    vObj["n-g"] = [vng]
                }
            }
            sdg.push(vObj);
        })
        return sdg;
    }
    var objWrapper = new Object
    if (typeof vData.sd != "undefined") {
        objWrapper["sd"] = vData.sd
    }
    if (typeof vData["n-g"] != "undefined") {
        //把sd-g中除sd以外的字段合并到n-g中
        var vngArr = []
        if (isArrayFn(vData["n-g"])) {
            vngArr = vData["n-g"]
        } else {
            vngArr = [vData["n-g"]]
        }
        if (vngArr.length > 0) {
            //fixNg(vData, vngArr[0])
            objWrapper["n-g"] = vngArr
        }
    } else {
        var vng2 = fixNgByType(vData, s_meanBlockType.MbtMeaning, qsWord, qslPos)
        if (vng2 !== null) {
            objWrapper["n-g"] = [vng2]
        }
    }
    if (Object.keys(objWrapper).length > 0) {
        sdg.push(objWrapper);
    }
    return sdg;
}

function parseMeanList(vData, qslPos, qsWord, qslPos) {
    var meanList = new Map()
    if (qslPos.length <= 0) {
        return meanList
    }
    //如果只有一个词性(除contemplative, do和entrance外), 释义在h-g中，否则在p-g中
    //先考察是否有p-g字段, 否则依次去h-g字段中寻找sd-g\n-g\d字段
    var bGot = false
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return meanList
        }
        vpg.forEach(function(vObj, index){
            bGot = true;
            meanList[qslPos[index]] = parseMean(vObj, qsWord, qslPos)
        })
    }
    //没有p-g，或者p-g没有数据在h-g中寻找释义
    if (!bGot) {
        meanList[qslPos[0]] = parseMean(vData["h-g"], qsWord, qslPos)
    }
    return meanList;
}

function tidyIdiomList(idiomList, qsWord, qslPos) {
    var vTidy = []
    if (!isArrayFn(idiomList)) {
        return vTidy
    }
    idiomList.forEach(function(vObj){
        if (typeof vObj["n-g"] != "undefined") {
            vTidy.push(vObj)
            return
        }
        var objTidy = new Object
        objTidy["id"] = vObj.id
        if (typeof vObj.cm != "undefined") {
            objTidy["cm"] = vObj.cm
        }
        var vng = fixNgByType(vObj, s_meanBlockType.MbtIdiom, qsWord, qslPos)
        if (vng !== null) {
            objTidy["n-g"] = [vng]
        }
        vTidy.push(objTidy)
    })
    return vTidy
}

function parseIdiomList(vData, qslPos, qsWord, qslPos) {
    var idiomList = new Map()
    if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return idiomList
        }
        vpg.forEach(function(vObj, index){
            var vId = tidyIdiomList(vObj["id-g"], qsWord, qslPos)
            if (vId.length > 0) {
                idiomList[qslPos[index]] = vId
            }
        })
    } else {
        var vId = tidyIdiomList(vData["h-g"]["id-g"], qsWord, qslPos)
        if (vId.length > 0) {
            idiomList[qslPos[0]] = vId
        }
    }
    return idiomList;
}

function fixNg(vData, vng) {
    var qsMarks = ["gr", "g", "r", "pt", "cf"]
    qsMarks.forEach(function(qsMark){
        if (typeof vData[qsMark] != "undefined") {
            vng[qsMark] = vData[qsMark]
        }
    })
}

function tidyPhraseList(vPhraseLists, qsWord, qslPos) {
    var vTidy = []
    vPhraseLists.forEach(function(vpObj)
    {
        if (typeof vpObj["pv-g"] != "undefined" && vpObj["pv-g"].length > 0) {
            vpObj["pv-g"].forEach(function(vObj){
                if (typeof vObj.pv == "undefined") {
                    return
                }
                if (typeof vObj["n-g"] != "undefined") {
                    vTidy.push(vObj)
                    return
                }
                var objTidy = new Object
                objTidy["pv"] = vObj.pv
                if (typeof vObj.gr != "undefined") {
                    objTidy["gr"] = vObj.gr
                }
                if (typeof vObj.g != "undefined" && typeof vObj.d == "undefined") {
                    objTidy["g"] = vObj.g
                }
                //有d字段vs-g合并到n-g中
                if (typeof vObj["vs-g"] != "undefined" && typeof vObj.d == "undefined") {
                    objTidy["vs-g"] = vObj["vs-g"]
                }
                var vng = fixNgByType(vObj, s_meanBlockType.MbtPhrase, qsWord, qslPos)
                if (vng !== null) {
                    objTidy["n-g"] = [vng]
                }
                vTidy.push(objTidy)
            })
        }
    })
    return vTidy;
}

function parsePhrase(vData) {
    var vpvpArr = []
    if (typeof vData["pv-g"] != "undefined" && vData["pv-g"].length > 0)
    {
        var vWrapper = new Object
        vWrapper["pv-g"] = vData["pv-g"]
        vpvpArr.push(vWrapper);
    }
    if (typeof vData["pvp-g"] != "undefined" && vData["pvp-g"].length > 0) {
        vpvpArr = vpvpArr.concat(vData["pvp-g"])
    }
    return vpvpArr
}

function parsePhraseList(vData, qslPos, qsWord, qslPos) {
    var phraseList = new Map
    if (typeof vData["p-g"] != "undefined")
    {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return phraseList
        }
        vpg.forEach(function(vObj, index){
            var vPhrase = tidyPhraseList(parsePhrase(vObj), qsWord, qslPos);
            if (vPhrase.length > 0) {
                phraseList[qslPos[index]] = vPhrase
            }
        })
    } else {
        var vPhrase = tidyPhraseList(parsePhrase(vData["h-g"]), qsWord, qslPos)
        if (vPhrase.length > 0) {
            phraseList[qslPos[0]] = vPhrase
        }
    }
    return phraseList;
}

function parseIllustrationList(vData) {
    if (typeof vData.ill != "undefined") {
        return vData.ill
    }
    return []
}

function parseDerivateList(vData, qslPos) {
    var vDerivateList = new Map()
    var vhg = vData["h-g"]
    var vDerivate = null
    if (typeof vData["dr-g"] != "undefined") {
        vDerivate = vData["dr-g"]
    } else if (typeof vhg["dr-g"] != "undefined") {
        vDerivate = vhg["dr-g"]
    }
    if (vDerivate !== null) {
        if (isArrayFn(vDerivate)) {
            vDerivateList[qslPos[0]] = vDerivate
        } else {
            vDerivateList[qslPos[0]] = [vDerivate]
        }
    }
    else if (typeof vData["p-g"] != "undefined")
    {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vDerivateList
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj["dr-g"] != "undefined")
            {
                var vDerivate = vObj["dr-g"]
                if (isArrayFn(vDerivate)) {
                    vDerivateList[qslPos[index]] = vDerivate
                } else {
                    vDerivateList[qslPos[index]] = [vDerivate]
                }
            }
        })
    }
    return vDerivateList;
}

function commPosDataParser(vData, qslPos, qsKey) {
    var vResult = new Map()
    var vhg = vData["h-g"]
    if (typeof vhg[qsKey] != "undefined") {
        vResult[qslPos[0]] = vhg[qsKey]
    } else if (typeof vData["p-g"] != "undefined") {
        var vpg = []
        if (isArrayFn(vData["p-g"])) {
            vpg = vData["p-g"]
        } else {
            vpg = [vData["p-g"]]
        }
        if (vpg.length > qslPos.length) {
            return vResult
        }
        vpg.forEach(function(vObj, index){
            if (typeof vObj[qsKey] != "undefined") {
                vResult[qslPos[index]] = vObj[qsKey]
            }
        })
    }
    return vResult;
}

function parseGlobalHelp(vData, qslPos) {
    return commPosDataParser(vData, qslPos, "help");
}

function parseGlobalCm(vData, qslPos) {
    return commPosDataParser(vData, qslPos, "cm");
}

function parseOrigins(vData, qslPos) {
    return commPosDataParser(vData, qslPos, "etym");
}

function parseFamilyGroup(vData, qslPos) {
    return commPosDataParser(vData, qslPos, "wf-g");
}

function fixNgByType(vData, dataType, qsWord, qslPos) {
    var vng = new Object
    if (typeof vData.d != "undefined")
    {
        vng["d"] = vData.d
    }
    else if (typeof vData.ud != "undefined")
    {
        vng["d"] = vData.ud
    }
    if (typeof vData.u != "undefined" && typeof vng.d != "undefined")
    {
        vng["u"] = vData.u
    }
    if (typeof vData.x != "undefined")
    {
        vng["x"] = vData.x
    }
    else if (typeof vData.help != "undefined" && typeof vng.d != "undefined")
    {
        var vx = new Object
        vx["help"] = vData.help
        vng["x"] = vx
    }
    if (typeof vData.r != "undefined" && (typeof vng.d != "undefined" || dataType !== s_meanBlockType.MbtMeaning && dataType !== s_meanBlockType.MbtPhrase))
    {
        vng["r"] = vData.r
    }
    if (typeof vData.g != "undefined" && (typeof vng.d != "undefined" || dataType !== s_meanBlockType.MbtMeaning && dataType !== s_meanBlockType.MbtPhrase))
    {
        vng["g"] = vData.g
    }
    if (typeof vData.cf != "undefined" && typeof vng.d != "undefined")
    {
        vng["cf"] = vData.cf
    }
    if (typeof vData.cc != "undefined" && typeof vng.d != "undefined")
    {
        vng["cc"] = vData.cc
    }
    if (typeof vData.n != "undefined")
    {
        vng["n"] = vData.n
    }
    if (typeof vData.s != "undefined" && typeof vng.d != "undefined")
    {
        vng["s"] = vData.s
    }
    if (typeof vData.ds != "undefined")
    {
        vng["ds"] = vData.ds
    }
    if (typeof vData.mixStr != "undefined")
    {
        vng["mixStr"] = vData.mixStr
    }
    if (typeof vData.xr != "undefined" && (typeof vng.d != "undefined" || dataType !== s_meanBlockType.MbtMeaning))
    {
        vng["xr"] = vData.xr
    }
    if (typeof vData.dc != "undefined")
    {
        vng["dc"] = vData.dc
    }
    if (typeof vData.sym != "undefined")
    {
        vng["sym"] = vData.sym
    }
    if (typeof vData.ab != "undefined")
    {
        vng["ab"] = vData.ab
    }
    if (typeof vData.a1 != "undefined")
    {
        vng["a"] = vData.a1
    }
    if (typeof vData["vs-g"] != "undefined" && typeof vng.d != "undefined")
    {
        vng["vs-g"] = vData["vs-g"]
    }
    if (typeof vData.gr != "undefined" && (typeof vng.d != "undefined" || dataType !== s_meanBlockType.MbtMeaning))
    {
        vng["gr"] = vData.gr
    }
    if (typeof vData.etym != "undefined" && typeof vng.d != "undefined")
    {
        vng["etym"] = vData.etym
    }
    if (typeof vData.gAll != "undefined")
    {
        vng["gAll"] = vData.gAll
    }
    if (typeof vData.cm != "undefined" && typeof vng.d != "undefined")
    {
        vng["cm"] = vData.cm
    }
    if (typeof vData.pt != "undefined" && (typeof vng.d != "undefined" || qsWord === "pressure"))//pressure的v的pt要显示在例句后面
    {
        vng["pt"] = vData.pt
    }
    if (typeof vData.pt1 != "undefined")
    {
        vng["pt1"] = vData.pt1
    }
    if (typeof vData["ifs-g"] != "undefined" && qslPos.length > 1)
    {
        vng["ifs-g"] = vData["ifs-g"]
    }
    if (Object.keys(vng).length > 0)
    {
        return vng
    }
    return null
}

var s_meanBlockType = {
    "MbtMeaning": 0,
    "MbtIdiom": 1,
    "MbtPhrase": 2,
    "MbtWhichWord": 3,
    "MbtSynonym": 4,
    "MbtGrammar": 5,
    "MbtMoreAbout": 6,
    "MbtVocab": 7,
    "MbtBA": 8,
    "MbtDerivate": 9,
    "MbtOrigin": 10,
    "MbtWordFamily": 11,
    "MbtCount": 12
}

//--------copy from YDictOxfoedUtilities.js start--------
function isArrayFn(value) {
    if (typeof value == "object") {
        if (typeof value.length == "number") {
            return true
        }
    }
    return false
}

function outputInfo(vData, name) {
    console.log("YDictOxfordModel.js === outputInfo name: ", name, ", type: ", typeof vData)
    if (typeof vData != "object") {
        console.log("YDictOxfordModel.js === outputInfo value: ", vData)
    } else if (typeof vData == "object") {
        if (isArrayFn(vData)) {
            console.log("YDictOxfordModel.js === outputInfo vData is array length :", vData.length)
            vData.forEach(function(vDataObject, index){
                outputInfo(vDataObject, name + "_arr_" + index)
            })
        } else {
            console.log("YDictOxfordModel.js === outputInfo vData is object keys num: ", Object.keys(vData).length)
            Object.keys(vData).forEach(function(keyName){
                outputInfo(vData[keyName], name + "_" + keyName)
            })
        }
    }
}

function phoneticToStringList(vi) {
    var qslPhonetic = []
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
                    qsPhonetic += ' '
                }
                qsPhonetic += v.g
            })
        }
        if (typeof vObj.il != "undefined")
        {
            if (qsPhonetic.length > 0) {
                qsPhonetic += ' '
            }
            qsPhonetic += ("<i>" + vObj.il + "</i>")
        }
        if (typeof vObj.cm != "undefined")
        {
            if (qsPhonetic.length > 0) {
                qsPhonetic += ' '
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
//--------copy from YDictOxfoedUtilities.js  end --------

