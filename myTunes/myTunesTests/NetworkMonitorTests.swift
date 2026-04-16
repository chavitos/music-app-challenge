//
//  NetworkMonitorTests.swift
//  myTunesTests
//

import Testing
@testable import myTunes

@Suite("NetworkMonitor")
@MainActor
struct NetworkMonitorTests {

	// MARK: - Initial state

	@MainActor
	@Test func isConnected_withAlwaysOnlineClient_isTrue() async {
		let monitor = NetworkMonitor(client: .mock)
		#expect(monitor.isConnected)
		#expect(monitor.connectivity == .online)
	}

	@MainActor
	@Test func isConnected_withCurrentStatusOffline_isFalse() async {
		let client = NetworkClient(
			stream: { AsyncStream { _ in } },
			currentStatus: { .offline }
		)
		let monitor = NetworkMonitor(client: client)
		monitor.refreshStatus()
		#expect(!monitor.isConnected)
		#expect(monitor.connectivity == .offline)
	}

	// MARK: - refreshStatus

	@MainActor
	@Test func refreshStatus_withOnlineCurrentStatus_setsOnline() async {
		let client = NetworkClient(
			stream: { AsyncStream { _ in } },
			currentStatus: { .online }
		)
		let monitor = NetworkMonitor(client: client)
		monitor.refreshStatus()
		#expect(monitor.isConnected)
	}
	
	@MainActor
	@Test func refreshStatus_withOfflineCurrentStatus_setsOffline() async {
		let client = NetworkClient(
			stream: { AsyncStream { _ in } },
			currentStatus: { .offline }
		)
		let monitor = NetworkMonitor(client: client)
		monitor.refreshStatus()
		#expect(!monitor.isConnected)
	}

	// MARK: - AsyncStream updates

	@MainActor
	@Test func stream_receivingOfflineEvent_updatesConnectivity() async throws {
		let (stream, continuation) = AsyncStream<Connectivity>.makeStream()
		let client = NetworkClient(
			stream: { stream },
			currentStatus: { .online }
		)
		let monitor = NetworkMonitor(client: client)

		continuation.yield(.offline)
		try await Task.sleep(for: .milliseconds(50))

		#expect(!monitor.isConnected)
		#expect(monitor.connectivity == .offline)
	}

	@MainActor
	@Test func stream_receivingOnlineAfterOffline_updatesConnectivity() async throws {
		let (stream, continuation) = AsyncStream<Connectivity>.makeStream()
		let client = NetworkClient(
			stream: { stream },
			currentStatus: { .online }
		)
		let monitor = NetworkMonitor(client: client)

		continuation.yield(.offline)
		try await Task.sleep(for: .milliseconds(50))
		#expect(!monitor.isConnected)

		continuation.yield(.online)
		try await Task.sleep(for: .milliseconds(50))
		#expect(monitor.isConnected)
	}

	// MARK: - Connectivity enum

	@MainActor
	@Test func connectivity_onlineAndOffline_areNotEqual() {
		#expect(Connectivity.online == .online)
		#expect(Connectivity.online != .offline)
	}

	@MainActor
	@Test func connectivity_offline_isConnectedFalse() async {
		let client = NetworkClient(
			stream: { AsyncStream { _ in } },
			currentStatus: { .offline }
		)
		let monitor = NetworkMonitor(client: client)
		monitor.refreshStatus()
		#expect(monitor.connectivity == .offline)
		#expect(!monitor.isConnected)
	}
}
