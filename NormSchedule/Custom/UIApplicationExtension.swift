//
//  UIApplicationExtension.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 19.07.2025.
//

import Foundation
import UIKit

extension UIApplication {
    static func rootViewController() -> UIViewController? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
