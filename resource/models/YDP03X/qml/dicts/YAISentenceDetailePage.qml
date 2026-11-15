import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Shapes 1.14
import QtGraphicalEffects 1.14
import BaseQml 1.0
import "../i18n"
Item {
//    anchors.fill: parent
    property var aiSentenceJson: null // 数据原型(网络请求原始数据)
    property var sentenceLables: [] //句子标签
    property string sentensTras: "" //句子翻译
    property var sentenceProperties: [] //句子属性
    property var docImportant: [] //重点词汇
    property int currentSelectedIndex: 0 //当前选中的句子
    property int aiSentenUiLayerIndex: 0 //当前句子分析层级

    property var sentence_elements: [] //句子按照单词拆分

    property var aiSentenceStack : [] //句子层级栈(用于分析第几层)

    property var currentAiSentenceJson : null //表示当前句子模型

    property int ai_sentence_analysis: 0 //分析结果 0 处理结果是可以的  1  对自己的解析结果不够自信 2 无法处理的

    property string org_sentence_content: "" //原句子

    //原始上报句子 (整段短文中句子)
    property string src_sentence: ""


    //带圈字符0的unicode编码是24EA， 带圈字符1-20的unicode编码是2460~2473 带圈字符21-35的unicode编码是3251-325F
    property var cirNums: ['\u2460','\u2461','\u2462','\u2463','\u2464','\u2465','\u2466','\u2467','\u2468','\u2469','\u2470','\u2471']
    function getCirculNum(index) {
        if(cirNums.length - 1 >= index)
            return cirNums[index]
        return ''
    }

    function getHighlightedColor(key,color){
        var tmp_key = key
        var temp_content = ""
        temp_content += ("<font color=" + color + ">")
        temp_content += tmp_key
        temp_content += "</font>"
        return " "+temp_content
    }

    //句子属性值映射
    //句子类型
    property var sentence_type: {
        "Unk" :"不知道是什么句子类型",
        "SimpleSent" : "简单句",
        "CompoundSent" :"并列句",
        "ComplexSent" :"复合句",
    }

    //句子结构
    property var sentence_struct: {

    }

    //时态
    property var sentence_tense: {
        "Unk" :"不知道是什么时态",
        "PresentSimple" : "一般现在时",
        "PresentProgressive": "现在进行时",
        "PresentPerfectSimple": "现在完成时",
        "PresentPerfectProgressive": "现在完成进行时",
        "PastSimple":"一般过去时",
        "PastProgressive":"过去进行时",
        "PastPerfectSimple": "过去完成时",
        "PastPerfectProgressive":"过去完成进行时",
        "FutureSimple": "一般将来时",
        "FutureProgressive":"将来进行时",
        "FuturePerfectSimple":"将来完成时",
        "FuturePerfectProgressive":"将来完成进行时",
        "PastFutureSimple":"过去将来时",
        "PastFutureProgressive":"过去将来进行时",
        "PastFuturePerfectSimple":"过去将来完成时",
        "PastFuturePerfectProgressive":"过去将来完成进行时"
    }

    //语态
    property var sentence_voice: {
        "Unk" :"不知道是什么语态",
        "Active" : "主动语态",
        "Passive" :"被动语态",
    }

    //从句类型
    property var clause_type: {
        "Unk" : "从句",//"不知道是什么从句类型",
        "SubjectClause" : "主语从句",
        "ObjectClause" : "宾语从句",
        "PredicativeClause" : "表语从句",
        "AppositionClause" : "同位语从句",
        "AttributeClause" : "定语从句",
        "AdverbialClause" : "状语从句",
    }

    //句子成分拆分
    property var sentence_elementsMap: {
        "subjects" : "主语",
        "predicates" : "谓语",
        "objects" : "宾语",
        "copulas" : "系动词",
        "predicatives" : "表语",
        "attribute" : "定语",
        "adverbial" : "状语",
        "complement" : "补语",
        "appositive" : "同位语",
        "parenthesis" : "插入语",
        "subjectsComp" : "主语补语",
        "subjectsAttr" : "主语定语",
        "indirectObjs" : "间接宾语",
        "objectsComp" : "宾语补语",
        "objectsAttr" : "宾语定语",
        "nonElements" : "无结构",
        //strucElm  备用(算法组备用方案)
//        "structSubjects" :"主语",
//        "structPredicates":"谓语",
//        "structObjects":"宾语",
//        "structCopulas":"系动词",
//        "structPredicatives":"表语",
//        "structIndirectObjs":"间接宾语",
//        "structObjectsComp":"宾语补语",
//        "nonStructElements" : "无结构",
        "conjunction" : "conjunction", //并列句
        "conjunction_word" : "conjunction_word" //并列连词
    }

    //颜色
    property var sentence_word_colos: {
        "主语" : "#588CF1" ,
        "谓语" : "#25A672" ,
        "表语" : "#C3621B" ,
        "定语" : "#A84FC9" ,
        "宾语" : "#D26060" ,
        "状语" : "#BD860D" ,
        "连词" : "#FFFFFF" ,
        //系词(UI缺少暂时 自己定义)
        "系动词" : "#25A672",

        "从句" : "#909199",

        "主语从句" : "#588CF1" ,
        "宾语从句" : "#D26060" ,
        "表语从句" : "#C3621B" ,
        "同位语从句" : "#25A672" ,
        "定语从句" : "#A84FC9" ,
        "状语从句" : "#BD860D" ,

        "无结构" : "#909199" ,

        //并列句
        "conjunction" : "#2DB3FF",
        "conjunction_word" : "white"
    }

    //网络数据到来时在这里做处理
    Connections {
        target: httprequestManager
        ignoreUnknownSignals: true
        enabled: id_ai_sentence_analusis.visible
        function onFnished(errCode){
            console.log("seven:finshed:errCode:",errCode)
            baseSignals.hideLoading()
            if(errCode === 0){
                console.log("seven:ai:results:====:",httprequestManager.getaiSentenceResults())
                aiSentenceJson =JSON.parse(httprequestManager.getaiSentenceResults())
                if(aiSentenceJson.data.code !== 0){
                    console.log("seven:ai:results:====:", aiSentenceJson.data.reason)
//                    baseSignals.showToastEx(aiSentenceJson.data.reason, "#2D2E33", 1500)
                    aiSentenceJson.data.data = [
                                {
                                    "docImportant" : [],
                                    "rawDoc" : resultManager.currentQuery,
                                    "docTran" : resultManager.currentQuery,
                                    "doc" : resultManager.currentQuery,
                                    "status" : {"msg" : "OK", "explain" : aiSentenceJson.data.reason, "code" : 3},
//                                    "sents" :
                                }
                            ]
                }
                createSententLables()
                lablesChangedIndex(0)

            }
        }
    }

    //UI数据重置
    function resetUiData(){
        sentensTras = ""
        sentenceProperties = []
        docImportant = []
        sentence_elements = []
    }

    //改变量防止UI重新刷新
    property var temp_sentenceLables: []
    property var temp_sentensTras : value
    property var temp_sentenceProperties: []
    property var temp_docImportant: []
    property var temp_sentence_elements: []
    property var temp_aiSentenceStack : []
    property string temp_org_sentence_content : ""

    function getCurrentSentens(){
        if(aiSentenceStack.length > 0) return aiSentenceStack[aiSentenceStack.length - 1].text
        return org_sentence_content

    }

    function getCurrentParentSenten(){
        if(aiSentenceStack.length === 1) return aiSentenceStack[aiSentenceStack.length - 1].text
        else if(aiSentenceStack.length > 1) return aiSentenceStack[aiSentenceStack.length - 2].text
        else return org_sentence_content
    }

    function getLableSentence(){
        return org_sentence_content
    }

    //构建句子标签
    function createSententLables(){
        temp_sentenceLables = []
        aiSentenceJson.data.data.forEach(function(sentenceObj){
            temp_sentenceLables.push({"code" : sentenceObj.status.code,
                                      "msg": sentenceObj.status.msg})
        })
        sentenceLables = temp_sentenceLables
    }

    function lablesChangedIndex(index){
        if(aiSentenceJson.data.data.length - 1 >= index){
            currentAiSentenceJson = aiSentenceJson.data.data[index]
            //翻译
            sentensTras = ""
            if(currentAiSentenceJson.docTran)
                sentensTras = currentAiSentenceJson.docTran
//            sentensTras = temp_sentensTras
            //原句子
            org_sentence_content = ""
            if(currentAiSentenceJson.rawDoc) org_sentence_content = currentAiSentenceJson.rawDoc
//            temp_org_sentence_content = currentAiSentenceJson.doc
//            org_sentence_content = temp_org_sentence_content
            //分析结果
            ai_sentence_analysis =  currentAiSentenceJson.status.code
            console.log("seven:ai_sentence_analysis:",ai_sentence_analysis)
            switch(ai_sentence_analysis){
            case 0:
                break
            case 1:
                baseSignals.showToastEx(/*"疑似句子不完整，分析可能不准确"*/currentAiSentenceJson.status.explain, "#2D2E33", 1500)
                break
            case 2:
            case 3:
                id_sub_sentence_text.visible = false
                resetUiData()
                baseSignals.showToastEx(/*"句子错误"*/currentAiSentenceJson.status.explain, "#2D2E33", 1500)
                break
            default:

            }

            currentAiSentenceJson.sents.forEach(function(sentObj){
                if(sentObj.text === currentAiSentenceJson.doc){
                    aiSentenceStack = [] //切换句子标签需要清除栈
                    createSentenceStruct(sentObj)
                    pushStack({
                                  "start" : sentObj.start,
                                  "end" : sentObj.end,
                                  "text" : sentObj.text
                              }, false);
                }
            })

            id_results_statement.visible = true
        }
    }

    function pushStack(stens,isFind){
        temp_aiSentenceStack = aiSentenceStack
        temp_aiSentenceStack.push(stens)
        if(isFind){
            console.log("seven:temp_stents:1",JSON.stringify(stens))
            var temp_stents = new Object()
            findSentenceLary(temp_aiSentenceStack[temp_aiSentenceStack.length - 1], currentAiSentenceJson.sents ,temp_stents)
            console.log("seven:temp_stents:2",JSON.stringify(temp_stents.obj))
            createSentenceStruct(temp_stents.obj)
        }
        aiSentenceStack = temp_aiSentenceStack
    }

    function popStach(){
        id_aisentence_flickble.contentY = 0
        if(aiSentenceStack.length <= 1) return 1
        temp_aiSentenceStack = aiSentenceStack
        aiSentenceStack = []
        temp_aiSentenceStack.pop()
        aiSentenceStack = temp_aiSentenceStack
        var temp_stents = new Object()
        findSentenceLary(temp_aiSentenceStack[temp_aiSentenceStack.length - 1], currentAiSentenceJson.sents, temp_stents)
        console.log("seven:temp_stents:",JSON.stringify(temp_stents.obj))
        createSentenceStruct(temp_stents.obj)
        return aiSentenceStack.length + 1
    }

    function getStentencenum(){
        return aiSentenceStack[aiSentenceStack.length - 1].stentencenum
    }

    function findSentenceLary(stens,orgSentens,destSents){
        console.log("seven:temp_stents:3",stens.start,stens.end)
        for(var i = 0; i < orgSentens.length; ++i){
            var orgObj = orgSentens[i]
            console.log("seven:temp_stents:4",orgObj.start,orgObj.end,orgObj.text)
            if(/*stens.text === orgObj.text &&*/
               stens.start === orgObj.start &&
               stens.end === orgObj.end ){
                console.log("seven:temp_stents:5",orgObj.start,orgObj.end)
//                return orgObj
                destSents.obj = orgObj
            }
            if(orgObj.sepSents) /*return*/ findSentenceLary(stens,orgObj.sepSents,destSents)
            if(orgObj.subSents) /*return*/ findSentenceLary(stens,orgObj.subSents,destSents)
        }
//        return null
    }

    function createSentenceStruct(/*sents*/sentObj){
        //句子属性 ||||| 句子类型/从句类型/句子结构/特殊句式/句子结构拆分/时态/语态/
        temp_docImportant = []
        temp_sentenceProperties = []
        temp_sentence_elements = []
//        sents.forEach(function(sentObj){//////////////////////
            var color_string = "#A8AAB2"
//            //类型
            if(sentObj.sentType && sentObj.sentType !== "Unk")
                temp_sentenceProperties.push({
                                                 "title" : getHighlightedColor("类型：", color_string),
                                                 "content" : sentence_type[sentObj.sentType]
                                             })
            //时态
            if(sentObj.tense && sentObj.tense !== "Unk")
                temp_sentenceProperties.push({
                                                 "title" : getHighlightedColor("时态：", color_string),
                                                 "content" : sentence_tense[sentObj.tense]
                                             })

            //语态
            if(sentObj.voice && sentObj.voice !== "Unk")
                temp_sentenceProperties.push({
                                                 "title" : getHighlightedColor("语态：", color_string),
                                                 "content" : sentence_voice[sentObj.voice]
                                             })

            if(sentObj.conjunction){
                var conJunction_str = ""
                var index = 0
                sentObj.conjunction.forEach(function(conjunctionObj){
                    if(index !== sentObj.conjunction.length - 1) conJunction_str += (conjunctionObj.text + "、")
                    else conJunction_str += conjunctionObj.text
                    index ++
                })
                temp_sentenceProperties.push({
                                                 "title" : getHighlightedColor("并列连词：", color_string),
                                                 "content" : conJunction_str
                                             })
            }

            //重点词汇
            sentObj.docImportant.forEach(function(docImportantObj){
                temp_docImportant.push({"origin" : docImportantObj.origin, "explain" : docImportantObj.explain})
            })

            //句子结构
            var sent_Type = sentObj.sentType
            switch (sent_Type){
                case "SimpleSent":
                    breakWord(sentObj.elements)
                    break;
                case "ComplexSent":
                    breakWord(sentObj.elements, sentObj.subSents)
                    break;
                case "CompoundSent":
                    breakWord(sentObj.elements, sentObj.subSents, sentObj.sepSents, sentObj.conjunction)
                    break;
                default:
            }

//        })/////////////////////////////
        sentenceProperties = temp_sentenceProperties
        docImportant = temp_docImportant
    }

    ListModel {
        id: sentence_world_listmodel
    }

    function breakWord(elements,subSents,sepSents,conjunction){
        console.log("seven:breakWord:subSents")
        var temp_sentence_elements = []
        sentence_world_listmodel.clear()
        for(var key in elements){
            console.log("seven:elements:key:",key)
            if(!(key === "objectsAttr" ||
                 key === "objectsComp" ||
                 key === "indirectObjs" ||
                 key === "subjectsAttr" ||
                 key === "subjectsComp" ||
                 key === "parenthesis" ||
                 key === "appositive" ||
                 key === "complement" ))
                if(elements[key].length > 0){
                    elements[key].forEach(function(tmp_element){
                        var temp_sub_sentenc = tmp_element.text
                        var tmp_end = tmp_element.end
                        var isPush = true
                        if(subSents){
                            subSents.forEach(function(subSentObj){
                                if(subSentObj.start <= tmp_element.start && subSentObj.end >= tmp_element.end) {
                                    isPush = false
//                                    break
                                }

                                if(subSentObj.start >= tmp_element.start && subSentObj.start <= tmp_element.end){
                                    temp_sub_sentenc = temp_sub_sentenc.substring(0, subSentObj.start - tmp_element.start)
                                    tmp_end = subSentObj.start
                                }
                            })
                        }
                        if(temp_sub_sentenc !== "" && isPush)
                            temp_sentence_elements.push({
                                                  "element" : key ,
                                                  "start" : tmp_element.start,
                                                  "end" : tmp_end/*tmp_element.end*/,
                                                  "title" : temp_sub_sentenc/*tmp_element.text*/,
                                                  "isLink" : false
                                              })
                    })
                }

        }
        if(subSents){
            subSents.forEach(function(subSentObj){
                var isPush  = true
                for(var index = 0; index < temp_sentence_elements.length; ++index){
                    var temp_wordJson = temp_sentence_elements[index]
                    if(temp_wordJson.start === subSentObj.start &&
                       temp_wordJson.end === subSentObj.end){
                        isPush = false
                        temp_wordJson.element = subSentObj.clauseType
                        temp_wordJson.start = subSentObj.start
                        temp_wordJson.end = subSentObj.end
                        temp_wordJson.title = subSentObj.text
                        temp_wordJson.isLink = true
                        break
                    }
                }
                if(isPush)
                    temp_sentence_elements.push({
                                          "element" : subSentObj.clauseType ,
                                          "start" : subSentObj.start,
                                          "end" : subSentObj.end,
                                          "title" : subSentObj.text,
                                          "isLink" : true
                                      })

            })

        }

        if(sepSents){
            sepSents.forEach(function(subSentObj){

                temp_sentence_elements.push({
                                      "element" : "conjunction" ,
                                      "start" : subSentObj.start,
                                      "end" : subSentObj.end,
                                      "title" : subSentObj.text,
                                      "isLink" : true,
                                  })

            })
            //并列句可能是无序的,所以得先排好序 然后编号

            temp_sentence_elements.sort(function(a, b){
                return a.start - b.start
            })
            var index = 0;
            temp_sentence_elements.forEach(function(sentenceObj){
                var number = getCirculNum(index ++)
                sentenceObj.title = (number)  + " " + sentenceObj.title
                sentenceObj.stentencenum = number
            })
            if(conjunction){
                conjunction.forEach(function(conjunctionObj){
                    temp_sentence_elements.push({
                                                    "element" : "conjunction_word" ,
                                                    "start" : conjunctionObj.start,
                                                    "end" : conjunctionObj.end,
                                                    "title" : conjunctionObj.text,
                                                    "isLink" : false
                                                })
                })
            }
        }

        temp_sentence_elements.sort(function(a, b){
            return a.start - b.start
        })
        var tmp_words = []
        temp_sentence_elements.forEach(function(elmObj){
            console.log("seven:Index:",elmObj.start)
            var words = elmObj.title.split(" ")
            var wordsCount = words.length
            var isCharcterLength = elmObj.title.length + wordsCount //单词数量
            var index = 0
            var isLastIndex = 0
            words.forEach(function(wStr){
                var isCenter = false
                var elnName = getElementName(elmObj.element)
                var sentence_word_color = sentence_word_colos[elnName] ? sentence_word_colos[elnName] : "red"
                var isLink = elmObj.isLink
                var isMultiple = wordsCount === 1//isCharcterLength < elnName.length
                if(wordsCount - 1 === index)
                    isCenter = true
                index ++
                sentence_world_listmodel.append({
                                   "element" :  elnName,
                                   "israngCenter" : isCenter,
                                   "colorEx" : sentence_word_color,
                                   "title" : wStr,
                                   "isLink" : isLink,
                                   "isMultiple" :isMultiple,
                                   "isNext" : false,
                                   "orgText" : elmObj.title,
                                   "orgStart" : elmObj.start,
                                   "orgEnd" : elmObj.end,
                                   "stentencenum" : elmObj.stentencenum
                               })
                isCenter = false
                if(wordsCount - 1 === index)
                    isCenter = true
                index ++
                sentence_world_listmodel.append({
                                   "element" : elnName ,
                                   "israngCenter" : isCenter,
                                   "colorEx" : sentence_word_color,
                                   "title" : " ",
                                   "isLink" : isLink,
                                   "isMultiple" :isMultiple,
                                   "isNext" : false,
                                   "orgText" : elmObj.title,
                                   "orgStart" : elmObj.start,
                                   "orgEnd" : elmObj.end,
                                   "stentencenum" : elmObj.stentencenum
                               })
                isLastIndex ++
                if(isLink && isLastIndex === wordsCount){
                    sentence_world_listmodel.append({
                                       "element" : elnName ,
                                       "israngCenter" : false,
                                       "colorEx" : sentence_word_color,
                                       "title" : "＞",//"     ",
                                       "isLink" : isLink,
                                       "isMultiple" :isMultiple,
                                       "isNext" : true,
                                       "orgText" : elmObj.title,
                                       "orgStart" : elmObj.start,
                                       "orgEnd" : elmObj.end,
                                       "stentencenum" : elmObj.stentencenum
                                   })
                }

            })
        })

//        sentence_elements = tmp_words//temp_sentence_elements
    }

    //获取句子结构映射关系
    function getElementName(key){
        var enlType = sentence_elementsMap[key]
        if(enlType) return enlType
        return clause_type[key]
    }

    Flickable {
        id: id_aisentence_flickble
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight:id_content_colum.height
//        clip: true
//        visible: !id_err_title.visible
        Column {
            id: id_content_colum
            width: parent.width
            YSpacingForColumn {
                height: 20
                visible: true
            }
            //句子标签
            Flickable {
                id: id_sentence_lables_filclable
                width: parent.width
                height: 52
                contentWidth: id_sentence_lables.width
                flickableDirection: Flickable.HorizontalFlick
                visible: {
                    if(sentenceLables.length > 1 && aiSentenceStack.length > 1) return false
                    return sentenceLables.length > 1
                }
                clip: true
                Row{
                    id: id_sentence_lables
                    height: parent.height
                    spacing: 10
                    anchors.bottom: parent.bottom
                    Repeater {
                        id: id_sentence_lables_repeater
                        model: sentenceLables
                        Rectangle{
                            height: id_sentence_lables.height
                            width: id_sentence_text.contentWidth + 20
                            radius: 16
                            color: {
                                currentSelectedIndex === index ? "#F03043" : "#1A1B1F"
                            }
                            YText {
                                id: id_sentence_text
                                font.family: fontManager.fontFamilyXinHuaXiHei
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment  : Text.AlignHCenter
                                height: 26
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                font.pixelSize: 26
                                color: currentSelectedIndex === index ? "white" : "#909199"
                                text: {
                                    return "句子" + (index + 1)
                                }
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    currentSelectedIndex = index
    //                                var sentenceObj = id_sentence_lables_repeater.model[index]
                                    lablesChangedIndex(currentSelectedIndex)
                                }
                            }
                        }
                    }
                }
            }

            YSpacingForColumn {
                height: 16
                visible: id_sentence_lables_filclable.visible
            }

            //分句标签
            YText {
                id: id_sub_sentence_text
                width: parent.width
                font.pixelSize: 26
                wrapMode: YText.WordWrap
                verticalAlignment: Text.AlignVCenter
                color: "#909199"
                visible: {
                    return !(aiSentenceStack[aiSentenceStack.length - 1].stentencenum === undefined)
                }
                text: {
                    if(aiSentenceStack[aiSentenceStack.length - 1].stentencenum) return aiSentenceStack[aiSentenceStack.length - 1].stentencenum + "分句"
                    return ""
                }
            }

            YSpacingForColumn {
                height: 16
                visible: id_sub_sentence_text.visible
            }



            //句子结构
            Flow {
//                width: parent.width - 40
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                flow: Flow.LeftToRight
                layoutDirection: Qt.LeftToRight
                visible: !id_err_sentence_text.visible
//                spacing: 10
                Repeater {
                    id: id_rich_text
                    model: sentence_world_listmodel//sentence_elements

                    Rectangle {

                        width: id_cell_text_colum.width
                        height: id_cell_text_colum.height
                        color: "transparent"
                        Column {
                            id: id_cell_text_colum
                            width: {
                                return id_cell_text.width
                            }
                            YText {
                                id: id_cell_text
                                height: 38
                                width: {
                                    if(israngCenter && isMultiple){
                                        return contentWidth >id_cell_element_lable.item.contentWidth ? contentWidth : id_cell_element_lable.item.contentWidth
                                    }
                                    return contentWidth
                                }
                                font.italic: isLink
                                font.pixelSize: 28
                                color: colorEx
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment  : Text.AlignHCenter
                                text: title
                                visible :{
                                    return !isNext
                                }
                            }
                            YLoader {
                                asynchronous: false
                                active: isNext
                                sourceComponent:id_next_icon
                            }
                            Component {
                                id: id_next_icon
                                Rectangle {
                                    width: 38
                                    height: 38
                                    color: "transparent"//colorEx
//                                    visible: {
//                                        return isNext
//                                    }
                                    YImage {
                                        width: 38
                                        height: 38
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        sourceSize: Qt.size(38, 38)
                                        imageName: "dict/dict_ai_sentence_next_icon"
                                        onLoaded : {
                                            parent.color = colorEx
                                        }
                                    }
                                }
                            }

                            YLoader {
                                width: parent.width
                                asynchronous: false
                                active: {
                                    if(isNext) return false
                                    return isLink
                                }
                                sourceComponent:id_linke_line
                            }
                            Component{
                                id: id_linke_line
                                Rectangle {
//                                    width: parent.width
                                    height: 1
                                    color: colorEx
//                                    visible: {
//                                        if(isNext) return false
//                                        return isLink
//                                    }
                                }
                            }


                            YSpacingForColumn {
                                height: 8
                                visible: id_cell_element_lable.active
                            }

                            YLoader{
                                id: id_cell_element_lable
                                width: id_cell_text.width
                                asynchronous: fasle
                                active: {
                                    if(element === "conjunction" ||
                                       element === "conjunction_word" ||
                                       element === "无结构") return false
                                    return israngCenter
                                }
                                sourceComponent:id_cell_element_componenet
                            }
                            Component{
                                id: id_cell_element_componenet
                                YText {
                                    id: id_cell_element_text
                                    height: 26
//                                    width: id_cell_text.width
                                    font.pixelSize: 20
                                    color: colorEx
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment  : Text.AlignHCenter
//                                    visible:{
//                                        if(element === "conjunction" ||
//                                           element === "conjunction_word" ||
//                                           element === "无结构") return false
//                                        return israngCenter
//                                    }
                                    text: {
//                                        if(element === "conjunction" ||
//                                           element === "conjunction_word" ||
//                                           element === "无结构") return ""
                                        return element
                                    }
                                }
                            }

                        }
                        MouseArea{
                            anchors.fill: {
//                                console.log("seven:orgInfo:0",title)
                                return parent
                            }
                            z: 1000
                            onClicked: {
//                                var orgInfo = id_rich_text.model[index]
                                console.log("seven:orgInfo:1",isLink,orgText)
                                if(!isLink) return
                                console.log("seven:orgInfo:2", title)
                                var sentObj
                                try {
                                    sentObj = {
                                        "start" : orgStart,
                                        "end" : orgEnd,
                                        "text" : orgText,
                                        "stentencenum" : stentencenum
                                    }
                                }catch (err){
                                    console.log("seven:orgInfo:3", err)
                                    sentObj = {
                                        "start" : orgStart,
                                        "end" : orgEnd,
                                        "text" : orgText,
//                                        "stentencenum" : stentencenum
                                    }
                                    pushStack(sentObj,true)
                                }

                                console.log("seven:orgInfo:3", stentencenum)
                                pushStack(sentObj,true)

                            }
                        }
                    }
                }
            }

            YSpacingForColumn {
                height: 16
                visible: !id_err_sentence_text.visible
            }

            //错误句子
            YText {
                id: id_err_sentence_text
                width: parent.width
                font.pixelSize: 28
                wrapMode: YText.WordWrap
                color: "#909199"
                visible: ai_sentence_analysis === 2 || ai_sentence_analysis === 3//id_err_title.visible
                text: org_sentence_content
            }

            //翻问,句子属性等
            Rectangle {
                id: id_sentence_property_rectangle
                width: parent.width
                height: id_trans_colum.height
                color: "#1A1B1F"
                radius: 16
                visible: {
                    if(id_err_sentence_text.visible) return false
                    return sentensTras.length !== 0 || sentenceProperties.length !== 0
                }
                Column {
                    id: id_trans_colum
                    width: parent.width
                    function isProperty(){
                        return sentensTras.length && sentenceProperties.length && (aiSentenceStack.length < 2)
                    }
                    //译文
                    Rectangle {
                        width: parent.width
                        height: id_trans_content_text.contentHeight +  20 * 2
                        color: "transparent"
                        visible: sentensTras.length && (aiSentenceStack.length < 2)
                        YText {
                            id: id_trans_title_text
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 20
                            anchors.leftMargin: 24
                            font.pixelSize: 24
                            wrapMode: YText.WordWrap
                            color: "#A8AAB2"
                            text: YTranslateText.translation + "："
                        }
                        YText {
                            id: id_trans_content_text
                            anchors.top: parent.top
                            anchors.left: id_trans_title_text.right
                            anchors.right: parent.right
                            anchors.topMargin: 20
                            anchors.rightMargin: 24
                            font.pixelSize: 24
                            wrapMode: YText.WordWrap
                            color: "white"
                            text: sentensTras
                        }
                    }
                    //分割线
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "transparent"
                        visible: {
//                            if(sentenceProperties.length === 0) return false
//                            return !(aiSentenceStack.length > 1)
                            return id_trans_colum.isProperty()
                        }
                        Shape {
                            width: parent.width
                            ShapePath {
                                strokeColor: "#2D2E33"
                                strokeWidth: 2
                                strokeStyle: ShapePath.DashLine
                                startX: 24
                                startY: 0
                                PathLine {
                                    x: id_sentence_property_rectangle.width - 24
                                    y: 0
                                }
                            }
                        }
                    }

                    YSpacingForColumn {
                        height: 20
                        visible: {//true
                            if(aiSentenceStack.length > 1) return true
                            return sentensTras.length && sentenceProperties.length
                        }
                    }

                    //属性
                    Flow {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 24
                        anchors.rightMargin: 24
                        flow: Flow.LeftToRight
                        layoutDirection: Qt.LeftToRight
                        Repeater {
                            id: id_senten_property_model
                            width: parent.width
                            model: sentenceProperties//[1,2,3,4,5,6]
                            YText {
                                width: parent.width / 2
                                height: 36
                                font.pixelSize: 24
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                textFormat: Text.RichText
                                text: {
                                    var proJson = id_senten_property_model.model[index]
                                    return proJson.title + proJson.content
                                }
                            }
                        }
                    }

                    YSpacingForColumn {
                        height: 20
                        visible: sentenceProperties.length//true
                    }
                }
            }

            YSpacingForColumn {
                height: 30
                visible: docImportant.length
            }

            //重点词汇
            Rectangle {
                width: parent.width
                height: 26
                color: "transparent"
                visible: {
                    return docImportant.length
                }
                Row {
                    anchors.fill: parent
                    spacing: 10
                    Rectangle {
                        y: (parent.height - height) / 2
                        width: 6
                        height: 6
                        color: "#909199"
                        radius: width / 2
                    }

                    YText {
                        height: 26
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 26
                        color: "#A8AAB2"
                        text: "重点词汇"
                    }
                }
            }

            YSpacingForColumn {
                height: 10
                visible: docImportant.length
            }

            Repeater {
                id: id_docimporten_reapter
                width: parent.width
                model: docImportant
                Column {
                    width: parent.width
                    YText {
                        height: 38
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 28
                        color: "white"
                        text: "  " + id_docimporten_reapter.model[index].origin
                    }

                    YSpacingForColumn {
                        height: 5
                        visible: true
                    }

                    YText {
//                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 15
//                        anchors.rightMargin: 24
                        font.pixelSize: 24
                        wrapMode: YText.WordWrap
                        color: "#A8AAB2"
                        text: /*"  " + */id_docimporten_reapter.model[index].explain
                    }

                    YSpacingForColumn {
                        height: 10
                        visible: true
                    }
                }
            }

            YSpacingForColumn {
                height: 40
                visible: id_results_statement.visible
            }

            YText {
                id: id_results_statement
                width: parent.width
                font.pixelSize: 24
                wrapMode: YText.WordWrap
                color: "#666873"
                visible: false
                text: "以上分析结果来自有道神经网络语法分析。仅供参考。"
            }

        }
    }
}
