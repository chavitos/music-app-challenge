//
//  NetworkAwareModifier.swift
//  myTunes
//

import SwiftUI

struct NetworkAwareModifier: ViewModifier {
	@State private var network = NetworkMonitor.shared

	func body(content: Content) -> some View {
		content
			.overlay(alignment: .top) {
				if !network.isConnected {
					Text("No connection")
						.font(.custom("ArticulatCF-Medium", size: 14))
						.foregroundStyle(.white)
						.frame(maxWidth: .infinity)
						.padding(.vertical, 8)
						.background(Color.red)
				}
			}
			.animation(.easeInOut(duration: 0.3), value: network.isConnected)
			.alert(
				alertTitle,
				isPresented: showAlert
			) {
				Button("OK") {
					network.connectionChanged = nil
				}
			}
	}

	private var alertTitle: String {
		switch network.connectionChanged {
		case .lost:
			"No internet connection"
		case .restored:
			"Connection restored"
		case nil:
			""
		}
	}

	private var showAlert: Binding<Bool> {
		Binding(
			get: { network.connectionChanged != nil },
			set: { if !$0 { network.connectionChanged = nil } }
		)
	}
}

extension View {
	func networkAware() -> some View {
		modifier(NetworkAwareModifier())
	}
}
