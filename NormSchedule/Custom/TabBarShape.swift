//
//  TabBarShape.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 12.02.2025.
//

import Foundation
import SwiftUI

struct TabBarShape: Shape {
    let isTop: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let curveSize: CGFloat = 40

        path.move(to: CGPoint(x: 0, y: isTop ? height : 0))
        path.addQuadCurve(to: CGPoint(x: curveSize, y: isTop ? height-curveSize : curveSize),
                          control: CGPoint(x: 0, y: isTop ? height-curveSize : curveSize))
        path.addLine(to: CGPoint(x: width - curveSize, y: isTop ? height - curveSize : curveSize))
        path.addQuadCurve(to: CGPoint(x: width, y: isTop ? height : 0), control: CGPoint(x: width, y: isTop ? height - curveSize : curveSize))
        path.addLine(to: CGPoint(x: width, y: isTop ? 0 : height))
        path.addLine(to: CGPoint(x: 0, y: isTop ? 0 : height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    TabBarShape(isTop: false)
}
