//
//  NormWidgetBundle.swift
//  NormWidget
//
//  Created by Кирилл Архипов on 15.04.2025.
//

import WidgetKit
import SwiftUI

@main
struct NormWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProgressAccessoryWidget()
        TimeLeftAccessoryWidget()
        CurNextWidget()
        LargeListWidget()
    }
}
