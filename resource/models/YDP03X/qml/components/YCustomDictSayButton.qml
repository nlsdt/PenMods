import BaseQml 1.0
import com.youdao.pen 1.0
import QtQuick 2.12

import "../common"

/**
 * 自造词典里的发音按钮（词头 / 例句）。
 *
 * 播放首选 PenMods 自己的 TTS 包装（QML 上下文属性 `tts`，见 src/tts/TtsWrapper.cpp）：
 * 它内部就是调宿主的 `YSoundCenter::play(文本, 语言, 音标, 引擎类型)`，而且参数是对的——
 *   speakEnglish(文本) → play(文本, "en-US", "", 0x0E)     (0x0E = 微软 TTS)
 *   speakChinese(文本) → play(文本, "zh-CHS", "", 0)
 * 千万别自己调 `soundCenter.play(文本, "en")`（不带引擎类型）：那会走**词典发音**，
 * 自造词在宿主词典里查不到就不出声。
 *
 * 状态由自己维护（`saying`），不依赖基类 YAudioPlayButton 的 onValidClicked 会不会被同时触发。
 * 动画收尾：**轮询** isPlaying()——实测 TTS 这条路既不触发 tts.speakFinished 也不触发
 * soundCenter.onCloseAudioOutputState，只等信号的话喇叭会一直转到 15s 保底定时器才停。
 */
YAudioPlayButton {
    id: id_say

    property string text: ""
    property string lang: "en"      ///< en / zh / ja / ko（决定用哪个语言朗读）
    property string kind: "word"    ///< word = 单词，sentence = 例句（目前走同一套 TTS）
    property bool   saying: false    ///< 真正由本按钮发起的播放是否还在进行
    property int    pollCount: 0     ///< 起播后轮询次数
    property int    idleCount: 0     ///< 连续"没在播"的次数
    property bool   sawBusy: false   ///< 是否见过"正在播放"

    visible: text.length > 0
    icon: "dict/sound"
    spacing: 0                      ///< 不显示文字，去掉图标与文字之间那 9px
    leftMargin: 6                   ///< 图标左右各留 6px，别贴胶囊边
    rightMargin: 6

    function hostLang() {
        if (lang === "zh")
            return "zh-CHS";
        if (lang === "ja")
            return "ja-JP";
        if (lang === "ko")
            return "ko-KR";
        return "en-US";
    }

    function speak() {
        if (text.length === 0)
            return;
        saying     = true;
        pollCount  = 0;
        idleCount  = 0;
        sawBusy    = false;
        play();

        if (typeof tts !== "undefined" && tts) {
            if (lang === "zh")
                tts.speakChinese(text);
            else if (lang === "en")
                tts.speakEnglish(text);
            else
                tts.speak(text, hostLang(), "", 0x0E);
            return;
        }

        // 退化路径：没有 tts 时直接调宿主播放器（同样要带引擎类型）
        if (typeof soundCenter !== "undefined" && soundCenter)
            playId = soundCenter.play(text, hostLang(), "", 0x0E);
    }

    /// 播放中？优先问 PenMods 的 TTS 包装，其次问宿主
    function isBusy() {
        if (typeof tts !== "undefined" && tts)
            return tts.isPlaying();
        if (typeof soundCenter !== "undefined" && soundCenter)
            return soundCenter.isPlaying();
        return false;
    }

    function finishSaying() {
        saying = false;
        stop();
    }

    function stopSaying() {
        saying = false;
        stop();
        if (typeof tts !== "undefined" && tts)
            tts.stop();
        else if (typeof soundCenter !== "undefined" && soundCenter)
            soundCenter.stop();
    }

    onValidClicked: {
        if (saying)
            stopSaying();
        else
            speak();
    }

    // 收尾靠轮询：TTS 播完不会有信号过来。
    // 正常情况：见过"正在播"，之后连续 ~0.9s 静音 → 停；
    // 兜底情况：~4s 都没见过"正在播"（引擎不同/查询失败）→ 也收尾。
    Timer {
        interval: 300
        repeat: true
        running: id_say.saying
        onTriggered: {
            id_say.pollCount += 1;
            if (id_say.isBusy()) {
                id_say.sawBusy = true;
                id_say.idleCount = 0;
                return;
            }
            if (id_say.sawBusy) {
                id_say.idleCount += 1;
                if (id_say.idleCount >= 3)
                    id_say.finishSaying();
            } else if (id_say.pollCount > 13) {
                id_say.finishSaying();
            }
        }
    }

    Connections {
        target: (typeof soundCenter !== "undefined") ? soundCenter : null
        ignoreUnknownSignals: true

        function onCloseAudioOutputState() {
            if (id_say.saying && !soundCenter.isPlaying()) {
                id_say.saying = false;
                id_say.stop();
            }
        }
    }
}
