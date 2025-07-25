//
//  AdBannerManager.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 25.07.2025.
//

import Foundation
import SwiftUI
import YandexMobileAds

class AdBannerManager: ObservableObject {
    static let shared = AdBannerManager()

    private var cachedBanners: [String: UIView] = [:]
    private let maxCacheSize = 21

    private init() {}

    func getBanner(for key: String, adUnitID: String, withWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, padding: CGFloat? = nil) -> UIView {
        if let cachedBanner = cachedBanners[key] {
            return cachedBanner
        }
        let banner = createBanner(adUnitID: adUnitID, withWidth: withWidth, maxHeight: maxHeight, padding: padding)
        cachedBanners[key] = banner
        if cachedBanners.count > maxCacheSize {
            let oldestKey = cachedBanners.keys.first!
            cachedBanners.removeValue(forKey: oldestKey)
        }

        return banner
    }

    private func createBanner(adUnitID: String, withWidth: CGFloat?, maxHeight: CGFloat?, padding: CGFloat?) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let adWidth = withWidth ?? UIScreen.main.bounds.width - (padding ?? 0)
        let adSize = BannerAdSize.inlineSize(withWidth: adWidth, maxHeight: maxHeight ?? 50)
        let adView = AdView(adUnitID: adUnitID, adSize: adSize)
        adView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(adView)

        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: container.topAnchor),
            adView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            adView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            adView.widthAnchor.constraint(equalToConstant: adWidth)
        ])

        adView.loadAd()
        return container
    }

    func clearCache() {
        cachedBanners.removeAll()
    }
}
