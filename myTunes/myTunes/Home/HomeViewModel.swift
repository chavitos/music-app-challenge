//
//  HomeViewModel.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import SwiftData

@Observable
final class HomeViewModel {
	
	// MARK: - State
	
	var songs: [Song] = []
	var searchText = ""
	var selectedSong: Song?
	var isLoading = false
	var errorMessage: String?
	
	// MARK: - Dependencies
	
	private let provider: SongsProviding
	private let modelContext: ModelContext
	
	// MARK: - Init
	
	init(provider: SongsProviding, modelContext: ModelContext) {
		self.provider = provider
		self.modelContext = modelContext
	}
	
	// MARK: - Use Cases
	
	func searchSongs() async {
		let trimmed = searchText.trimmingCharacters(in: .whitespaces)
		
		guard !trimmed.isEmpty else {
			loadRecentlyPlayed()
			return
		}
		
		isLoading = true
		errorMessage = nil
		
		do {
			let response = try await provider.loadSongs(with: trimmed)
			let fetchedSongs = response.results.compactMap {
				$0.toSong(searchTerm: trimmed)
			}
			
			for song in fetchedSongs {
				modelContext.insert(song)
			}
			try modelContext.save()
			
			songs = fetchedSongs
		} catch {
			errorMessage = error.localizedDescription
		}
		
		isLoading = false
	}
	
	func selectSong(_ song: Song) {
		selectedSong = song
	}
	
	// MARK: - Private
	
	private func loadRecentlyPlayed() {
		songs = [
			Song(
				trackId: 617154366,
				artistId: 5468295,
				collectionId: 617154241,
				trackName: "Get Lucky",
				artistName: "Daft Punk feat. Pharrell Williams",
				collectionName: "Random Access Memories",
				artworkUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/e8/43/5f/e8435ffa-b6b9-b171-40ab-4ff3959ab661/886443919266.jpg/100x100bb.jpg",
				previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/d4/d3/1e/d4d31eb4-7405-b806-8346-3c52ad5b4cf4/mzaf_8095545455942962509.plus.aac.p.m4a",
				trackTimeMillis: 369629,
				trackNumber: 8,
				discNumber: 1,
				releaseDate: "2013-04-19T07:00:00Z"
			)
		]
		
//		var descriptor = FetchDescriptor<Song>(
//			predicate: #Predicate { $0.lastPlayedAt != nil },
//			sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
//		)
//		descriptor.fetchLimit = 20
//		songs = (try? modelContext.fetch(descriptor)) ?? []
	}
}
