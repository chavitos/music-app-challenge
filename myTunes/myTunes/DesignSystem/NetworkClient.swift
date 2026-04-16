//
//  NetworkClient.swift
//  myTunes
//

import Network

enum Connectivity: Equatable, Sendable {
	case online
	case offline
}

struct NetworkClient: Sendable {
	var stream: @Sendable () -> AsyncStream<Connectivity>
	var currentStatus: @Sendable () -> Connectivity
}

extension NetworkClient {
	static var live: Self {
		let box = MonitorBox()
		return Self(
			stream: {
				AsyncStream { continuation in
					let monitor = NWPathMonitor()
					box.monitor = monitor
					monitor.pathUpdateHandler = { path in
						let connectivity: Connectivity = path.status == .satisfied ? .online : .offline
						continuation.yield(connectivity)
					}
					monitor.start(queue: DispatchQueue(label: "NetworkClient.monitor", qos: .utility))
					continuation.onTermination = { @Sendable _ in
						box.monitor?.cancel()
						box.monitor = nil
					}
				}
			},
			currentStatus: {
				box.monitor?.currentPath.status == .satisfied ? .online : .offline
			}
		)
	}

	static var mock: Self {
		Self(stream: { AsyncStream { _ in } }, currentStatus: { .online })
	}
}

private final class MonitorBox: @unchecked Sendable {
	nonisolated(unsafe) var monitor: NWPathMonitor?
}
