pragma Singleton

import QtQuick 2.12
import XmPresenter 1.0

QtObject {
    // no need translate
    readonly property string accountInfo: qsTr("账号信息")
    readonly property string logout: qsTr("退出登录")
    readonly property string notLogin: qsTr("未登录")
    readonly property string scanQrCodeLoginTip: qsTr("请用微信扫描二维码，登录App")
    readonly property string userContractTip: qsTr("请用微信扫描二维码，查看用户服务协议和隐私政策")
    readonly property string vipContractTip: qsTr("请用微信扫描二维码，查看会员服务协议")
    readonly property string xmlyChildrenApp: qsTr("喜马拉雅少儿App")
    readonly property string vipForPayment: qsTr("开通VIP 畅享会员权益")
    readonly property string vipForPaymentTip: qsTr("请用微信扫描二维码   享多重VIP特权")
    readonly property string albumPrice: qsTr("价格")
    readonly property string albumPriceVip: qsTr("会员尊享价")
    readonly property string albumPriceOrigin: qsTr("原价")
    readonly property string openVip: qsTr("开通VIP")
    readonly property string renewVip: qsTr("立即续费")
    readonly property string vipPeriod: qsTr("会员到期")
    readonly property string vipExpired: qsTr("会员已过期")
    readonly property string playing: qsTr("正在播放")
    readonly property string myCollection: qsTr("我的收藏")
    readonly property string playHistory: qsTr("听书历史")
    readonly property string bought: qsTr("已购听书")
    readonly property string hotList: qsTr("热门专题")
    readonly property string allList: qsTr("全部分类")
    readonly property string userContract: qsTr("用户服务协议和隐私政策")
    readonly property string vipContract: qsTr("会员服务协议")
    readonly property string version: qsTr("版本号")
    readonly property string noHistory: qsTr("暂时没有历史记录")
    readonly property string noSubscrible: qsTr("暂时没有收藏图书")
    readonly property string noPurchased: qsTr("暂时没有已购图书")
    readonly property string noSubject: qsTr("该分类暂无内容")
    readonly property string afterLogin: qsTr("登录后才可以查看~~~")
    readonly property string tipNotPlaying: qsTr("暂无播放记录")
    readonly property string networkSlow: qsTr("网络不稳定哦~")
    readonly property string networkBroken: qsTr("网络异常，请检查网络")
    readonly property string albumIdentity: qsTr("合集")
    readonly property string logoutWillNotBeAbleToSync: qsTr("请确认要退出喜马拉雅账号?")

    function loadingError(errorCode) {
        if (errorCode === XmHomePresenter.CodeDataEmpty) {
            return qsTr("暂时还没有数据哦~")
        } else if (errorCode === XmHomePresenter.CodeServerError
                   || errorCode === XmHomePresenter.CodeNetworkError) {
            return qsTr("网络异常，请检查网络")
        } else if (errorCode === XmHomePresenter.CodeNetworkDisable) {
            return qsTr("设备处于离线状态，请重新检查网络")
        } else if (errorCode === XmHomePresenter.CodeAlbumOutOfStock) {
            return qsTr("专辑已下架")
        } else {
            return qsTr("加载失败，请稍后再试")
        }
    }
}
