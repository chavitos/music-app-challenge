//
//  NetworkMonitor.swift
//  myTunes
//

import Network
import Observation

enum ConnectionChange {
	case lost
	case restored
}

@Observable
@MainActor
final class NetworkMonitor {
	static let shared = NetworkMonitor()

	var isConnected = true
	var connectionChanged: ConnectionChange?

	@ObservationIgnored
	private let monitor = NWPathMonitor()

	private init() {
		monitor.pathUpdateHandler = { [weak self] path in
			Task { @MainActor [weak self] in
				guard let self else { return }
				let wasConnected = self.isConnected
				let nowConnected = path.status == .satisfied

				self.isConnected = nowConnected

				if wasConnected && !nowConnected {
					self.connectionChanged = .lost
				} else if !wasConnected && nowConnected {
					self.connectionChanged = .restored
				}
			}
		}
		monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
	}

	deinit {
		monitor.cancel()
	}
}
