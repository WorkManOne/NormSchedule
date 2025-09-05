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
    @Published var shouldRewardUser = false
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
        rewardedAd.show(from: viewController)
    }
}

extension RewardedAdManager: RewardedAdLoaderDelegate {
    func rewardedAdLoader(_ adLoader: RewardedAdLoader, didLoad rewardedAd: RewardedAd) {
        self.rewardedAd = rewardedAd
        rewardedAd.delegate = self
        DispatchQueue.main.async {
            self.isAdReady = true
        }
        print("Rewarded Ad Loaded")
    }

    func rewardedAdLoader(_ adLoader: RewardedAdLoader, didFailToLoadWithError error: AdRequestError) {
        print("Failed to load rewarded ad")
        DispatchQueue.main.async {
            self.isAdReady = false
        }
    }
}

extension RewardedAdManager: RewardedAdDelegate {
    func rewardedAd(_ rewardedAd: RewardedAd, didReward reward: Reward) {
        print("User should be rewarded")
        DispatchQueue.main.async {
            self.shouldRewardUser = true
        }
    }

    func rewardedAd(_ rewardedAd: RewardedAd, didFailToShowWithError error: any Error) {
        DispatchQueue.main.async {
            self.isAdReady = false
            self.shouldRewardUser = false
        }
        loadAd()
    }

    func rewardedAdDidDismiss(_ rewardedAd: RewardedAd) {
        DispatchQueue.main.async {
            self.isAdReady = false
            if self.shouldRewardUser {
                self.onReward?()
                self.shouldRewardUser = false
            }
        }
        loadAd()
    }

    func rewardedAdDidShow(_ rewardedAd: RewardedAd) {
        DispatchQueue.main.async {
            self.shouldRewardUser = false
        }
    }
}

