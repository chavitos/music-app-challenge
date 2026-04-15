//
//  LoadingIndicatorView.swift
//  myTunes
//
//  Created by Tiago Chaves on 14/04/26.
//

import SwiftUI

struct LoadingIndicatorView: View {
	var size: CGFloat = 32
	var text: String?
	
	var body: some View {
		VStack(spacing: 12) {
			ProgressView {
				if let text {
					Text(text)
						.multilineTextAlignment(.center)
						.lineLimit(3)
						.font(.custom("ArticulatCF-Medium", size: 15))
						.fontWeight(.medium)
						.foregroundStyle(Color.appPrimaryText)
				}
			}
			.tint(.white)
			.controlSize(controlSize)
			
		}
		.padding(24)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.gray.opacity(0.1))
		)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	private var controlSize: ControlSize {
		if size >= 32 { return .large }
		if size >= 20 { return .regular }
		return .small
	}
}

#Preview("With text") {
	LoadingIndicatorView(size: 32, text: "Searching...")
		.background(Color.appBackground)
}

#Preview("Without text") {
	LoadingIndicatorView()
		.background(Color.appBackground)
}
