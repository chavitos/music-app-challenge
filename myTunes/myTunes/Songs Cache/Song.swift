//
//  Song.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import SwiftData

@Model
final class Song {
	
	// MARK: - API Identifiers
	
	@Attribute(.unique)
	var trackId: Int
	var artistId: Int
	var collectionId: Int
	
	// MARK: - Display Info
	
	var trackName: String
	var artistName: String
	var collectionName: String
	var artworkUrl: String
	
	// MARK: - Playback
	
	var previewUrl: String?
	var trackTimeMillis: Int
	
	// MARK: - Album Context
	
	var trackNumber: Int
	var discNumber: Int
	var releaseDate: String?
	
	// MARK: - App-Specific
	
	var lastPlayedAt: Date?
	var searchTerm: String?
	var cachedAt: Date
	
	init(
		trackId: Int,
		artistId: Int,
		collectionId: Int,
		trackName: String,
		artistName: String,
		collectionName: String,
		artworkUrl: String,
		previewUrl: String?,
		trackTimeMillis: Int,
		trackNumber: Int,
		discNumber: Int,
		releaseDate: String?,
		lastPlayedAt: Date? = nil,
		searchTerm: String? = nil,
		cachedAt: Date = .now
	) {
		self.trackId = trackId
		self.artistId = artistId
		self.collectionId = collectionId
		self.trackName = trackName
		self.artistName = artistName
		self.collectionName = collectionName
		self.artworkUrl = artworkUrl
		self.previewUrl = previewUrl
		self.trackTimeMillis = trackTimeMillis
		self.trackNumber = trackNumber
		self.discNumber = discNumber
		self.releaseDate = releaseDate
		self.lastPlayedAt = lastPlayedAt
		self.searchTerm = searchTerm
		self.cachedAt = cachedAt
	}
}
