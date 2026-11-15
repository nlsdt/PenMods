function formattedChineseTextBetweenSpecificSymble(qsText, startSymble, endSymble) {
    let qsTextRst = qsText
    let posCatchS = qsTextRst.indexOf(startSymble, 0)
    while(posCatchS >= 0) {
        let posCatchE = qsTextRst.indexOf(endSymble, posCatchS + startSymble.length)
        if (posCatchE < 0) {
            break
        }
        let qsMid = qsTextRst.substring(posCatchS + startSymble.length, posCatchE)
        if (0 === qmlTranslator.guessTextLang(qsMid)) { // 0 is YEnum.ZH_CN
            qsTextRst = qsTextRst.substring(0, posCatchS + startSymble.length)
                        + '<span style="font-family:' + fontManager.fontFamilyZhCn + ', DejaVu Sans;">' + qsMid + '</span>'
                        + qsTextRst.substring(posCatchE)
        }
        posCatchS = qsTextRst.indexOf(startSymble, posCatchE + endSymble.length)
    }
    return qsTextRst
}

function formattedChineseText(qsText){
    if (typeof qsText != "string" || qsText.length <= 0) {
        return ""
    }
    let qsTextRst = formattedChineseTextBetweenSpecificSymble(qsText, "“", "”")
    qsTextRst = formattedChineseTextBetweenSpecificSymble(qsTextRst, "(", ")")
    return qsTextRst
}

function replaceSpecificSymble(qsText){
    if (typeof qsText != "string" || qsText.length <= 0) {
        return ""
    }
    //特殊字符无法显示，替换为可显示字符
    return qsText.replace(/󰡒/g, "“").replace(/󰡓/g, "”").replace(/･/g, "·")
}
