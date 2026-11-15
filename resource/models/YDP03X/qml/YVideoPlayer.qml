import QtQuick 2.12
import QtMultimedia 5.14
import com.youdao.pen 1.0
import BaseQml 1.0

MouseArea{
    id: id_video_player_root
    anchors.fill: parent
    visible: false
    readonly property bool isShowing: id_video_player_root.visible

    signal videoPlayPageCalled()

    onVisibleChanged: {
        console.log("YVideoPlayer.qml====id_video_player_root.visible==="+id_video_player_root.visible)
    }

    function hidden(){
        if(id_video_player_root.visible){
            console.log("YVideoPlayer.qml===hidden()===")
            id_media_player.stop()
            id_video_output.source = id_media_player_empty
            id_video_player_root.visible = false
            readingBookManager.processedVideoFinish()
        }
    }

    function raise(path, videoFlushMode=YEnum.Empty_Frame){
        // enum VideoPlayerFlushMode{
        // Empty_Frame,
        // First_Frame,
        // Last_Frame
        // };
        console.log("YVideoPlayer.qml===onPlayVideoSignal===")
        console.log("YVideoPlayer.qml===onPlayVideoSignal===path:"+path)
        console.log("YVideoPlayer.qml===onPlayVideoSignal===videoFlushMode:"+videoFlushMode)
        if(!id_video_player_root.visible){
            if(path!==undefined && path!==null && path!==""){
                console.log("YVideoPlayer.qml===raise()===")
                soundCenter.openAudioOutput()
                videoPlayPageCalled()
                id_video_output.flushMode = videoFlushMode
                id_video_output.source = id_media_player
                id_media_player.lastPlayPath = path
                id_media_player.source = ""
                id_media_player.source = "file://"+path
                id_media_player.play()
                id_video_player_root.visible = true

            }else{
                console.error("YVideoPlayer.qml===path is error===")
            }
        }
    }

    Rectangle {
        id: id_background
        anchors.fill: parent
        color: YColors.black
    }

    VideoOutput {
        id: id_video_output
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        source: id_media_player
    }

    MediaPlayer{
        id:id_media_player_empty
    }

    MediaPlayer {
        id: id_media_player

        property string lastPlayPath: ""

        onError: {
            console.error("YVideoPlayer.qml===MediaPlayer==="+errorString)
        }

        onStatusChanged: {
            if(status===MediaPlayer.EndOfMedia){
                console.log("YVideoPlayer.qml===video end ===")
                if(id_video_output.flushMode === VideoOutput.EmptyFrame){
                    id_video_player_root.hidden()
                }
                systemBase.playVideoFinished(lastPlayPath)
                readingBookManager.processedVideoFinish()
            }
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true

        function onPlayVideoSignal(path, videoFlushMode){
            id_video_player_root.raise(path,videoFlushMode)
        }

    }


}
