//
//  TestHelpers.swift
//  myTunesTests
//

import Foundation
import SwiftData
@testable import myTunes

// MARK: - Song factory

extension Song {
	static func test(
		trackId: Int = 1,
		collectionId: Int = 100,
		artistId: Int = 1,
		trackName: String = "Test Song",
		artistName: String = "Test Artist",
		previewUrl: String? = nil,
		trackTimeMillis: Int = 30000,
		trackNumber: Int = 1,
		lastPlayedAt: Date? = nil
	) -> Song {
		Song(
			trackId: trackId,
			artistId: artistId,
			collectionId: collectionId,
			trackName: trackName,
			artistName: artistName,
			collectionName: "Test Album",
			artworkUrl: "https://example.com/100x100bb.jpg",
			previewUrl: previewUrl,
			trackTimeMillis: trackTimeMillis,
			trackNumber: trackNumber,
			discNumber: 1,
			releaseDate: nil,
			lastPlayedAt: lastPlayedAt
		)
	}
}

// MARK: - Album factory

extension Album {
	static func test(collectionId: Int = 100, artistId: Int = 1) -> Album {
		Album(
			collectionId: collectionId,
			artistId: artistId,
			collectionName: "Test Album",
			artistName: "Test Artist",
			artworkUrl: "https://example.com/100x100bb.jpg",
			trackCount: 10
		)
	}
}

// MARK: - iTunesItemDTO factory

extension iTunesItemDTO {
	static func makeSong(trackId: Int = 1, collectionId: Int = 100, trackNumber: Int = 1) -> iTunesItemDTO {
		iTunesItemDTO(
			wrapperType: "track",
			kind: "song",
			trackId: trackId,
			artistId: 1,
			collectionId: collectionId,
			trackName: "Test Song \(trackId)",
			artistName: "Test Artist",
			collectionName: "Test Album",
			collectionArtistName: nil,
			artworkUrl30: nil,
			artworkUrl60: nil,
			artworkUrl100: "https://example.com/100x100bb.jpg",
			previewUrl: nil,
			trackTimeMillis: 30000,
			isStreamable: true,
			trackNumber: trackNumber,
			trackCount: 10,
			discNumber: 1,
			discCount: 1,
			releaseDate: nil,
			primaryGenreName: nil,
			copyright: nil,
			trackExplicitness: nil,
			collectionExplicitness: nil,
			collectionType: nil
		)
	}

	static func makeCollection(collectionId: Int = 100) -> iTunesItemDTO {
		iTunesItemDTO(
			wrapperType: "collection",
			kind: nil,
			trackId: nil,
			artistId: 1,
			collectionId: collectionId,
			trackName: nil,
			artistName: "Test Artist",
			collectionName: "Test Album",
			collectionArtistName: nil,
			artworkUrl30: nil,
			artworkUrl60: nil,
			artworkUrl100: "https://example.com/100x100bb.jpg",
			previewUrl: nil,
			trackTimeMillis: nil,
			isStreamable: nil,
			trackNumber: nil,
			trackCount: 10,
			discNumber: nil,
			discCount: nil,
			releaseDate: nil,
			primaryGenreName: nil,
			copyright: nil,
			trackExplicitness: nil,
			collectionExplicitness: nil,
			collectionType: "Album"
		)
	}
}

// MARK: - iTunesResponseDTO factory

extension iTunesResponseDTO {
	static func make(results: [iTunesItemDTO]) -> iTunesResponseDTO {
		iTunesResponseDTO(resultCount: results.count, results: results)
	}
}

// MARK: - ModelContainer factory

extension ModelContainer {
	static func testContainer() throws -> ModelContainer {
		try ModelContainer(
			for: Song.self, Album.self,
			configurations: ModelConfiguration(isStoredInMemoryOnly: true)
		)
	}
}

// MARK: - JSON fixtures

enum JSONFixtures {
	static let singleSongResponse = """
	{
		"resultCount": 1,
		"results": [{
			"wrapperType": "track",
			"kind": "song",
			"trackId": 123,
			"artistId": 456,
			"collectionId": 789,
			"trackName": "Test Song",
			"artistName": "Test Artist",
			"collectionName": "Test Album"
		}]
	}
	""".data(using: .utf8)!

	static let emptyResponse = """
	{"resultCount": 0, "results": []}
	""".data(using: .utf8)!

	static let invalidJSON = "not json".data(using: .utf8)!
}
