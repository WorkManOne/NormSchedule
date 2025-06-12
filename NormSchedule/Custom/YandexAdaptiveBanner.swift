//
//  SwiftUIView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 12.06.2025.
//

import SwiftUI
import YandexMobileAds

struct YandexAdaptiveBanner: UIViewRepresentable {
    let adUnitID: String
    let withWidth: CGFloat?
    let maxHeight: CGFloat?
    let padding: CGFloat?

    init(adUnitID: String, withWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, padding: CGFloat? = nil) {
        self.adUnitID = adUnitID
        self.withWidth = withWidth
        self.maxHeight = maxHeight
        self.padding = padding
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let adWidth = withWidth ?? UIScreen.main.bounds.width - (padding ?? 0)
        let adSize = BannerAdSize.inlineSize(withWidth: adWidth, maxHeight: maxHeight ?? 50)
        let adView = AdView(adUnitID: adUnitID, adSize: adSize)
        adView.delegate = context.coordinator
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



    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, AdViewDelegate {
        func adViewDidLoad(_ adView: AdView) {
            print("Реклама загрузилась")
        }

        func adViewDidFailLoading(_ adView: AdView, error: Error) {
            print("Ошибка загрузки рекламы: \(error.localizedDescription)")
        }
    }
}

#Preview {
    VStack {
        Spacer()
        YandexAdaptiveBanner(adUnitID: "demo-banner-yandex")
            .frame(height: 50)
            .padding(.horizontal)
    }
}
