//
//  NetworkMonitor.swift
//  myTunes
//

import Network
import Observation

@Observable
@MainActor
final class NetworkMonitor {
	static let shared = NetworkMonitor(client: .live)

	private(set) var connectivity: Connectivity = .online

	var isConnected: Bool { connectivity == .online }

	@ObservationIgnored
	nonisolated(unsafe) private var monitorTask: Task<Void, Never>?

	@ObservationIgnored
	private let networkClient: NetworkClient

	init(client: NetworkClient) {
		self.networkClient = client
		let stream = client.stream()
		monitorTask = Task { @MainActor [weak self] in
			for await status in stream {
				self?.connectivity = status
			}
		}
	}

	func refreshStatus() {
		connectivity = networkClient.currentStatus()
	}

	deinit {
		monitorTask?.cancel()
	}
}
