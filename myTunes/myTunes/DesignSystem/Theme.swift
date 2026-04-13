//
//  Theme.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

// MARK: - App Colors

extension Color {
	static let appBackground = Color(hex: 0x000000)
	static let appPrimaryText = Color(hex: 0xFFFFFF)
	static let appSecondaryText = Color(hex: 0x8E8E93)
	static let appSubText = Color(hex: 0x737373)
}

// MARK: - Hex Init

extension Color {
	init(hex: Int) {
		let red = Double((hex >> 16) & 0xFF) / 255.0
		let green = Double((hex >> 8) & 0xFF) / 255.0
		let blue = Double(hex & 0xFF) / 255.0
		self.init(red: red, green: green, blue: blue)
	}
}
