//
//  swiftui_tutorialApp.swift
//  swiftui_tutorial
//
//  Created by Haresh Patel on 6/26/25.
//

import SwiftUI

@main
struct swiftui_tutorialApp: App {
    @StateObject var viewModel = ProductViewModel()
    init() {
         let appearance = UITabBarItem.appearance()
         let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
         appearance.setTitleTextAttributes(attributes, for: .normal)
     }
    var body: some Scene {
        WindowGroup {
            DelayedSplashView()
         
        }.modelContainer(for: LocalProduct.self)
    }
}
