//
//  Mocks.swift
//  myTunesTests
//

import Foundation
@testable import myTunes

// MARK: - MockSongsProvider

final class MockSongsProvider: SongsProviding, @unchecked Sendable {
	var loadSongsResult: Result<iTunesResponseDTO, Error> = .success(iTunesResponseDTO(resultCount: 0, results: []))
	var loadAlbumResult: Result<iTunesResponseDTO, Error> = .success(iTunesResponseDTO(resultCount: 0, results: []))
	var loadSongsCallCount = 0
	var loadAlbumCallCount = 0
	var lastSearchTerm: String?
	var lastCollectionId: Int?

	func loadSongs(with searchTerm: String) async throws -> iTunesResponseDTO {
		loadSongsCallCount += 1
		lastSearchTerm = searchTerm
		return try loadSongsResult.get()
	}

	func loadAlbum(collectionId: Int) async throws -> iTunesResponseDTO {
		loadAlbumCallCount += 1
		lastCollectionId = collectionId
		return try loadAlbumResult.get()
	}
}

// MARK: - MockHTTPClient

final class MockHTTPClient: HTTPClient, @unchecked Sendable {
	var result: Result<(Data, URLResponse), Error>

	init(data: Data = Data(), statusCode: Int = 200) {
		let response = HTTPURLResponse(
			url: URL(string: "https://example.com")!,
			statusCode: statusCode,
			httpVersion: nil,
			headerFields: nil
		)!
		result = .success((data, response))
	}

	init(error: Error) {
		result = .failure(error)
	}

	init(data: Data, response: URLResponse) {
		result = .success((data, response))
	}

	func data(from url: URL) async throws -> (Data, URLResponse) {
		return try result.get()
	}
}
