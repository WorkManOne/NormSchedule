//
//  CachedYandexAdaptiveBanner.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 25.07.2025.
//

import SwiftUI
import YandexMobileAds

struct CachedYandexAdaptiveBanner: UIViewRepresentable {
    let key: String
    let adUnitID: String
    let withWidth: CGFloat?
    let maxHeight: CGFloat?
    let padding: CGFloat?

    init(key: String, adUnitID: String, withWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, padding: CGFloat? = nil) {
        self.key = key
        self.adUnitID = adUnitID
        self.withWidth = withWidth
        self.maxHeight = maxHeight
        self.padding = padding
    }

    func makeUIView(context: Context) -> UIView {
        return AdBannerManager.shared.getBanner(
            for: key,
            adUnitID: adUnitID,
            withWidth: withWidth,
            maxHeight: maxHeight,
            padding: padding
        )
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

#Preview {
    CachedYandexAdaptiveBanner(key: "pn", adUnitID: "demo-banner-yandex")
}
