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
		var descriptor = FetchDescriptor<Song>(
			predicate: #Predicate { $0.lastPlayedAt != nil },
			sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
		)
		descriptor.fetchLimit = 20
		songs = (try? modelContext.fetch(descriptor)) ?? []
	}
}
