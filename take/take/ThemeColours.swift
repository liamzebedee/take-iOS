//
//  ThemeColours.swift
//  take
//
//  Created by Liam Edwards-Playne on 22/1/2023.
//

import Foundation
import SwiftUI


class Theme:ObservableObject {
    init() {
        self.brandColor = Color(hex: 0xff2a8d)
        self.backgroundColor = Color(hex: 0x000000)
        self.contrastBackground = Color(hex: 0x000000)
        self.secondaryColor = Color(hex: 0x000000)
        self.shadowColor = Color(hex: 0x000000)
        self.bodyTextColor = Color(hex: 0x000000)
    }
    
    
    @Published var brandColor: Color
    @Published var backgroundColor: Color
    @Published var contrastBackground: Color
    @Published var secondaryColor: Color
    @Published var shadowColor: Color
    @Published var bodyTextColor: Color
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
