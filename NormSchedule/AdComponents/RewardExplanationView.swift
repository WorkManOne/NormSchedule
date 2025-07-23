//
//  RewardExplanationView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 19.07.2025.
//
import SwiftUI
import Pow
import DotLottie

import SwiftUI
import Pow
import DotLottie

struct RewardExplanationView: View {
    let onStart: () -> Void
    let isAdReady: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var contentHeight: CGFloat = 0

    let repeatEvery = 0.5
    let minDelay = 0.0
    let maxDelay = 0.5

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let totalWidth = geometry.size.width
            let animationHeight = max(totalHeight - contentHeight, totalHeight * 0.2)

            let originalWidth = 3072.0
            let originalHeight = 950.0
            let aspect = originalWidth / originalHeight
            let scale = 1.5

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Text("Накормить разработчика")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    DotLottieAnimation(
                        fileName: "laptop",
                        config: AnimationConfig(autoplay: true, loop: true, speed: 1, backgroundColor: .clear)
                    )
                    .view()
                    .frame(width: animationHeight * aspect * scale, height: animationHeight * scale)
                    .offset(y: -animationHeight * 0.25)
                    .frame(width: animationHeight * aspect, height: animationHeight)
                    .clipped()
//                    .offset(y: -animationHeight * 0.02 * scale)
//                    .offset(y: -animationHeight * 0.30 * scale)
//                    .offset(y: 930 * 6 / animationHeight)

                    .frame(height: animationHeight)
                }
                .frame(height: animationHeight)
                contentView(totalWidth: totalWidth)
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .onAppear {
                                    contentHeight = contentGeometry.size.height
                                }
                                .onChange(of: contentGeometry.size.height) { _, newHeight in
                                    contentHeight = newHeight
                                }
                        }
                    )
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.frame)
    }

    @ViewBuilder
    private func contentView(totalWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("Нажав на кнопку, воспроизведется реклама. После нее вы увидите уникальную фразу и анимацию.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                Text("Это самый простой способ поблагодарить разработчика.")
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom)

            Button {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    onStart()
                }
            } label: {
                Text("Накормить")
                    .foregroundStyle(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: totalWidth * 0.025)
                            .fill(.lines.opacity(isAdReady ? 1 : 0.5))
                    )
            }
            .disabled(!isAdReady)
            .animation(.default, value: isAdReady)
            .conditionalEffect(
                .repeat(
                    .glow(color: .lines, radius: totalWidth * 0.12),
                    every: 1.5
                ),
                condition: isAdReady
            )
            .background(
                heartAnimationsBackground(width: totalWidth)
            )
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    @ViewBuilder
    private func heartAnimationsBackground(width: CGFloat) -> some View {
        Color.clear
            .overlay(
                ForEach(1..<10) { index in
                    Color.clear
                        .conditionalEffect(
                            .repeat(
                                .rise(origin: UnitPoint(x: Double(index) * 0.1, y: 0.5), {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                        .font(.system(size: width * 0.04))
                                }).delay(Double.random(in: minDelay...maxDelay)),
                                every: repeatEvery
                            ),
                            condition: isAdReady
                        )
                }
            )
    }
}

#Preview {
    struct preview: View {
        @State private var isReady = false
        @State private var isOpen = false
        var body: some View {
            Button("open") {
                isOpen = true
            }
            .sheet(isPresented: $isOpen) {
                RewardExplanationView(onStart: {}, isAdReady: isReady)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                            isReady = true
                        }
                    }
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
            }
        }
    }
    return preview()
}
