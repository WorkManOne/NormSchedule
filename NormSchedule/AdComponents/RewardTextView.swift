import SwiftUI
import DotLottie

struct RewardTextView: View {
    @State private var positions: [CGSize] = []
    @State private var rotations: [Double] = []
    @State private var dragOffsets: [CGSize] = []
    @State private var animateIn = false
    @State private var initialDragOffsets: [CGSize] = []

    let words: [String]
    let animationName: String

    let containerWidth: CGFloat = 350
    let containerHeight: CGFloat = 400

    init(phrase: String, animationName: String) {
        self.animationName = animationName
        self.words = phrase.components(separatedBy: " ")
        self._positions = State(initialValue: Array(repeating: .zero, count: words.count))
        self._rotations = State(initialValue: Array(repeating: 0.0, count: words.count))
        self._dragOffsets = State(initialValue: Array(repeating: .zero, count: words.count))
        self._initialDragOffsets = State(initialValue: Array(repeating: .zero, count: words.count))
    }

    var body: some View {
        ZStack {
            ZStack {
                Color.frame
                    .ignoresSafeArea()
                DotLottieAnimation(fileName: animationName, config: AnimationConfig(autoplay: true, loop: true))
                    .view()
                    .scaledToFit()
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text(word)
                        .font(.system(size: fontSize(for: word), weight: .bold, design: .rounded))
                        .foregroundColor(colorForWord(at: index))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(backgroundColorForWord(at: index))
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
                        )
                        .rotationEffect(.degrees(rotations[index]))
                        .scaleEffect(animateIn ? 1.0 : 0.0)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .offset(
                            x: positions[index].width + dragOffsets[index].width,
                            y: positions[index].height + dragOffsets[index].height
                        )
                        .animation(
                            animateIn ?
                            .spring(response: 0.8, dampingFraction: 0.7)
                            .delay(Double(index) * 0.15) :
                            .spring(response: 0.8, dampingFraction: 0.7),
                            value: animateIn
                        )
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.7),
                            value: positions[index]
                        )
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8),
                            value: rotations[index]
                        )
                        .animation(.interpolatingSpring(stiffness: 400, damping: 30), value: dragOffsets[index])
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    dragOffsets[index] = CGSize(
                                        width: initialDragOffsets[index].width + value.translation.width,
                                        height: initialDragOffsets[index].height + value.translation.height
                                    )
                                }
                                .onEnded { value in
                                    initialDragOffsets[index] = dragOffsets[index]
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        rotations[index] += Double.random(in: -15...15)
                                    }
                                }
                        )
                        .onTapGesture {
                            let jumpOffset = CGSize(
                                width: Double.random(in: -25...25),
                                height: Double.random(in: -35...(-15))
                            )
                            let rotationChange = Double.random(in: -25...25)
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                dragOffsets[index] = jumpOffset
                                initialDragOffsets[index] = .zero
                                rotations[index] += rotationChange
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    dragOffsets[index] = .zero
                                }
                            }
                        }
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Spacer()
                Button(action: resetAnimation) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.lines)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
        }
        .onAppear {
            generateScatteredPositions()
            startAnimation()
        }
    }

    private func estimatedWordWidth(for word: String) -> CGFloat {
        let fontSize = fontSize(for: word)
        return CGFloat(word.count) * fontSize * 0.6 + 28
    }

    private func estimatedWordHeight(for word: String) -> CGFloat {
        let fontSize = fontSize(for: word)
        return fontSize + 20
    }

    private func generateScatteredPositions() {
        let wordsPerRow = min(4, max(3, words.count / 3))
        let startY: CGFloat = -containerHeight/2 + 80
        var newPositions = Array(repeating: CGSize.zero, count: words.count)
        var newRotations = Array(repeating: 0.0, count: words.count)
        var currentRow = 0
        var currentRowWords: [Int] = []

        for i in 0..<words.count {
            if i > 0 && i % wordsPerRow == 0 {
                layoutRow(words: currentRowWords, row: currentRow, startY: startY,
                         positions: &newPositions, rotations: &newRotations)
                currentRow += 1
                currentRowWords = [i]
            } else {
                currentRowWords.append(i)
            }
        }
        if !currentRowWords.isEmpty {
            layoutRow(words: currentRowWords, row: currentRow, startY: startY,
                     positions: &newPositions, rotations: &newRotations)
        }

        fixOverlaps(positions: &newPositions)

        positions = newPositions
        rotations = newRotations
    }

    private func layoutRow(words: [Int], row: Int, startY: CGFloat,
                          positions: inout [CGSize], rotations: inout [Double]) {
        let rowHeight: CGFloat = 65
        let baseY = startY + CGFloat(row) * rowHeight
        let minGap: CGFloat = 15

        let totalWordsWidth = words.reduce(0) { sum, index in
            sum + estimatedWordWidth(for: self.words[index])
        }
        let totalGapsWidth = CGFloat(max(0, words.count - 1)) * minGap
        let totalRowWidth = totalWordsWidth + totalGapsWidth

        let startX = -totalRowWidth / 2
        var currentX = startX

        for (_, wordIndex) in words.enumerated() {
            let wordWidth = estimatedWordWidth(for: self.words[wordIndex])

            let wordCenterX = currentX + wordWidth / 2

            let randomX = Double.random(in: -10...10)
            let randomY = Double.random(in: -10...10)

            positions[wordIndex] = CGSize(
                width: wordCenterX + randomX,
                height: baseY + randomY
            )

            rotations[wordIndex] = Double.random(in: -12...12)

            currentX += wordWidth + minGap
        }
    }

    private func fixOverlaps(positions: inout [CGSize]) {
        for i in 0..<positions.count {
            for j in (i+1)..<positions.count {
                let pos1 = positions[i]
                let pos2 = positions[j]

                let word1Width = estimatedWordWidth(for: words[i])
                let word1Height = estimatedWordHeight(for: words[i])
                let word2Width = estimatedWordWidth(for: words[j])
                let word2Height = estimatedWordHeight(for: words[j])

                let minDistanceX = (word1Width + word2Width) / 2 + 10
                let minDistanceY = (word1Height + word2Height) / 2 + 5

                let deltaX = abs(pos1.width - pos2.width)
                let deltaY = abs(pos1.height - pos2.height)

                if deltaX < minDistanceX && deltaY < minDistanceY {
                    let pushX = minDistanceX - deltaX
                    let pushY = minDistanceY - deltaY

                    if pushX < pushY {
                        if pos1.width < pos2.width {
                            positions[i].width -= pushX / 2
                            positions[j].width += pushX / 2
                        } else {
                            positions[i].width += pushX / 2
                            positions[j].width -= pushX / 2
                        }
                    } else {
                        if pos1.height < pos2.height {
                            positions[i].height -= pushY / 2
                            positions[j].height += pushY / 2
                        } else {
                            positions[i].height += pushY / 2
                            positions[j].height -= pushY / 2
                        }
                    }

                    positions[i] = clampToContainer(positions[i])
                    positions[j] = clampToContainer(positions[j])
                }
            }
        }
    }

    private func clampToContainer(_ position: CGSize) -> CGSize {
        let marginX: CGFloat = 60
        let marginY: CGFloat = 30
        return CGSize(
            width: max(-containerWidth/2 + marginX, min(containerWidth/2 - marginX, position.width)),
            height: max(-containerHeight/2 + marginY, min(containerHeight/2 - marginY, position.height))
        )
    }

    private func fontSize(for word: String) -> CGFloat {
        switch word.count {
        case 1...2: return 20
        case 3...4: return 18
        case 5...6: return 17
        default: return 16
        }
    }

    private func colorForWord(at index: Int) -> Color {
        return .primary
    }

    private func backgroundColorForWord(at index: Int) -> Color {
        let colors: [Color] = [
            .pink.opacity(0.3),
            .blue.opacity(0.3),
            .yellow.opacity(0.3),
            .green.opacity(0.3),
            .orange.opacity(0.3),
            .purple.opacity(0.3)
        ]
        return colors[index % colors.count]
    }

    private func startAnimation() {
        animateIn = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }

    private func resetAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            animateIn = false
        }

        dragOffsets = Array(repeating: .zero, count: words.count)
        initialDragOffsets = Array(repeating: .zero, count: words.count)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            generateScatteredPositions()
            animateIn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animateIn = true
                }
            }
        }
    }
}

struct RewardPreviewView: View {
    @State private var isPresented: Bool = false
    var body: some View {
        Button("preview") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            RewardTextView(phrase: "Sample text", animationName: "toaster")
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }

    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RewardPreviewView()
    }
}
