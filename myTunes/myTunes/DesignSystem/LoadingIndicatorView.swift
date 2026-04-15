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
		VStack(spacing: .spacingM) {
			ProgressView {
				if let text {
					Text(text)
						.multilineTextAlignment(.center)
						.lineLimit(3)
						.font(.appLoading)
						.fontWeight(.medium)
						.foregroundStyle(Color.appPrimaryText)
				}
			}
			.tint(.white)
			.controlSize(controlSize)

		}
		.padding(.spacingXL)
		.background(
			RoundedRectangle(cornerRadius: .cornerRadiusM)
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
