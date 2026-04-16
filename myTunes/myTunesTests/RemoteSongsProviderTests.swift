//
//  RemoteSongsProviderTests.swift
//  myTunesTests
//

import Testing
import Foundation
@testable import myTunes

@Suite("RemoteSongsProvider")
struct RemoteSongsProviderTests {

	// MARK: - loadSongs

	@MainActor
	@Test func loadSongs_withValidJSON_returnsDecodedResponse() async throws {
		let client = MockHTTPClient(data: JSONFixtures.singleSongResponse)
		let sut = RemoteSongsProvider(client: client)

		let response = try await sut.loadSongs(with: "test")

		#expect(response.resultCount == 1)
		#expect(response.results.first?.trackName == "Test Song")
	}

	@MainActor
	@Test func loadSongs_withHTTP400_throwsHTTPError() async throws {
		let client = MockHTTPClient(data: Data(), statusCode: 400)
		let sut = RemoteSongsProvider(client: client)

		await #expect(throws: SongsProviderError.self) {
			_ = try await sut.loadSongs(with: "test")
		}
	}

	@MainActor
	@Test func loadSongs_withHTTP500_throwsHTTPError() async throws {
		let client = MockHTTPClient(data: Data(), statusCode: 500)
		let sut = RemoteSongsProvider(client: client)

		do {
			_ = try await sut.loadSongs(with: "test")
			Issue.record("Expected error was not thrown")
		} catch let error as SongsProviderError {
			if case .httpError(let code) = error {
				#expect(code == 500)
			} else {
				Issue.record("Unexpected SongsProviderError case: \(error)")
			}
		}
	}

	@MainActor
	@Test func loadSongs_withInvalidJSON_throwsDecodingFailed() async throws {
		let client = MockHTTPClient(data: JSONFixtures.invalidJSON)
		let sut = RemoteSongsProvider(client: client)

		do {
			_ = try await sut.loadSongs(with: "test")
			Issue.record("Expected error was not thrown")
		} catch let error as SongsProviderError {
			if case .decodingFailed = error { } else {
				Issue.record("Expected decodingFailed, got: \(error)")
			}
		}
	}

	@MainActor
	@Test func loadSongs_withNonHTTPResponse_throwsInvalidResponse() async throws {
		let response = URLResponse(
			url: URL(string: "https://example.com")!,
			mimeType: nil,
			expectedContentLength: 0,
			textEncodingName: nil
		)
		let client = MockHTTPClient(data: Data(), response: response)
		let sut = RemoteSongsProvider(client: client)

		do {
			_ = try await sut.loadSongs(with: "test")
			Issue.record("Expected error was not thrown")
		} catch let error as SongsProviderError {
			if case .invalidResponse = error { } else {
				Issue.record("Expected invalidResponse, got: \(error)")
			}
		}
	}

	@MainActor
	@Test func loadSongs_withNetworkError_propagatesOriginalError() async throws {
		let client = MockHTTPClient(error: URLError(.notConnectedToInternet))
		let sut = RemoteSongsProvider(client: client)

		await #expect(throws: URLError.self) {
			_ = try await sut.loadSongs(with: "test")
		}
	}

	@MainActor
	@Test func loadSongs_withEmptyResultsJSON_returnsEmptyResponse() async throws {
		let client = MockHTTPClient(data: JSONFixtures.emptyResponse)
		let sut = RemoteSongsProvider(client: client)

		let response = try await sut.loadSongs(with: "test")

		#expect(response.resultCount == 0)
		#expect(response.results.isEmpty)
	}

	// MARK: - loadAlbum

	@MainActor
	@Test func loadAlbum_withValidJSON_returnsDecodedResponse() async throws {
		let client = MockHTTPClient(data: JSONFixtures.singleSongResponse)
		let sut = RemoteSongsProvider(client: client)

		let response = try await sut.loadAlbum(collectionId: 789)

		#expect(response.resultCount == 1)
	}

	@MainActor
	@Test func loadAlbum_withHTTP404_throwsHTTPError() async throws {
		let client = MockHTTPClient(data: Data(), statusCode: 404)
		let sut = RemoteSongsProvider(client: client)

		do {
			_ = try await sut.loadAlbum(collectionId: 999)
			Issue.record("Expected error was not thrown")
		} catch let error as SongsProviderError {
			if case .httpError(let code) = error {
				#expect(code == 404)
			} else {
				Issue.record("Unexpected SongsProviderError case: \(error)")
			}
		}
	}

	@MainActor
	@Test func loadAlbum_withNetworkError_propagatesOriginalError() async throws {
		let client = MockHTTPClient(error: URLError(.timedOut))
		let sut = RemoteSongsProvider(client: client)

		await #expect(throws: URLError.self) {
			_ = try await sut.loadAlbum(collectionId: 123)
		}
	}
}
