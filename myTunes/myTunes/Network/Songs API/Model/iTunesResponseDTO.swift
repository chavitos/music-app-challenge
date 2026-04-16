//
//  iTunesResponseDTO.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation

// MARK: - Top-Level Response

struct iTunesResponseDTO: Decodable, Sendable {
	let resultCount: Int
	let results: [iTunesItemDTO]
}

// MARK: - Individual Result Item
//
// Both `/search` (tracks) and `/lookup` (collection + tracks) return
// items through the same `results` array. Collection entries omit
// track-specific fields, so most properties are optional.

struct iTunesItemDTO: Decodable, Sendable {
	
	// MARK: Type Discriminators
	
	let wrapperType: String        // "track" | "collection"
	let kind: String?              // "song" (tracks only)
	
	// MARK: Identifiers
	
	let trackId: Int?
	let artistId: Int
	let collectionId: Int
	
	// MARK: Names
	
	let trackName: String?
	let artistName: String
	let collectionName: String
	let collectionArtistName: String?
	
	// MARK: Artwork
	
	let artworkUrl30: String?
	let artworkUrl60: String?
	let artworkUrl100: String?
	
	// MARK: Playback
	
	let previewUrl: String?
	let trackTimeMillis: Int?
	let isStreamable: Bool?
	
	// MARK: Album Context
	
	let trackNumber: Int?
	let trackCount: Int?
	let discNumber: Int?
	let discCount: Int?
	
	// MARK: Metadata
	
	let releaseDate: String?
	let primaryGenreName: String?
	let copyright: String?
	
	// MARK: Content Ratings
	
	let trackExplicitness: String?
	let collectionExplicitness: String?
	
	// MARK: Collection-Only (Album wrapper)
	
	let collectionType: String?    // "Album" (collection entries only)
}

// MARK: - Helpers

extension iTunesItemDTO {
	
	var isTrack: Bool {
		wrapperType == "track" && kind == "song"
	}
	
	var isCollection: Bool {
		wrapperType == "collection"
	}
	
	func toSong(searchTerm: String? = nil) -> Song? {
		guard isTrack,
					let trackId,
					let trackName,
					let artworkUrl100 else {
			return nil
		}
		
		return Song(
			trackId: trackId,
			artistId: artistId,
			collectionId: collectionId,
			trackName: trackName,
			artistName: artistName,
			collectionName: collectionName,
			artworkUrl: artworkUrl100,
			previewUrl: previewUrl,
			trackTimeMillis: trackTimeMillis ?? 0,
			trackNumber: trackNumber ?? 0,
			discNumber: discNumber ?? 0,
			releaseDate: releaseDate,
			searchTerm: searchTerm
		)
	}
	
	func toAlbum() -> Album? {
		guard isCollection,
					let artworkUrl100 else {
			return nil
		}
		
		return Album(
			collectionId: collectionId,
			artistId: artistId,
			collectionName: collectionName,
			artistName: artistName,
			artworkUrl: artworkUrl100,
			trackCount: trackCount ?? 0,
			releaseDate: releaseDate,
			copyright: copyright
		)
	}
}
