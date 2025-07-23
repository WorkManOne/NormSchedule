//
//  YandexRewardedAd.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 18.07.2025.
//

import SwiftUI
import YandexMobileAds

final class RewardedAdManager: NSObject, ObservableObject {
    private var rewardedAdLoader: RewardedAdLoader?
    private var rewardedAd: RewardedAd?

    @Published var isAdReady = false
    var onReward: (() -> Void)?

    override init() {
        super.init()
        rewardedAdLoader = RewardedAdLoader()
        rewardedAdLoader?.delegate = self
    }

    func loadAd(adUnitId: String = "demo-rewarded-yandex") {
        let configuration = AdRequestConfiguration(adUnitID: adUnitId)
        rewardedAdLoader?.loadAd(with: configuration)
    }

    func showAd(from viewController: UIViewController) {
        guard let rewardedAd = rewardedAd else { return }
        rewardedAd.delegate = self
        rewardedAd.show(from: viewController)
    }
}

extension RewardedAdManager: RewardedAdLoaderDelegate {
    func rewardedAdLoader(_ adLoader: RewardedAdLoader, didLoad rewardedAd: RewardedAd) {
        self.rewardedAd = rewardedAd
        self.isAdReady = true
        print("Rewarded Ad Loaded")
    }

    func rewardedAdLoader(_ adLoader: RewardedAdLoader, didFailToLoadWithError error: AdRequestError) {
        print("Failed to load rewarded ad")
        isAdReady = false
    }
}

extension RewardedAdManager: RewardedAdDelegate {
    func rewardedAd(_ rewardedAd: RewardedAd, didReward reward: Reward) {
        print("User should be rewarded")
        onReward?()
        self.isAdReady = false
        loadAd()
    }
    func rewardedAd(_ rewardedAd: RewardedAd, didFailToShowWithError error: any Error) {
        loadAd()
    }
    func rewardedAdDidDismiss(_ rewardedAd: RewardedAd) {
        print("did dismiss")
        self.isAdReady = false
        loadAd()
    }
}
