//
//  HomeViewModel.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class HomeViewModel {

	// MARK: - State

	var songs: [Song] = []
	var searchText = ""
	var selectedSong: Song?
	var isLoading = false
	var hasSearched = false
	var errorMessage: String?
	var hasMorePages: Bool { songs.count < allFetchedSongs.count }

	// MARK: - Dependencies

	private let provider: SongsProviding
	private let modelContext: ModelContext
	private var lastSearchTerm: String?

	// MARK: - Pagination

	private var allFetchedSongs: [Song] = []
	private let pageSize = 20
	private var currentPage = 0

	// MARK: - Init

	init(provider: SongsProviding, modelContext: ModelContext) {
		self.provider = provider
		self.modelContext = modelContext
	}

	// MARK: - Use Cases

	func searchSongs() async {
		let trimmed = searchText.trimmingCharacters(in: .whitespaces)

		// Skip if already loaded for this exact term — prevents re-render on navigation back
		guard trimmed != lastSearchTerm else { return }
		lastSearchTerm = trimmed

		guard !trimmed.isEmpty else {
			resetPagination()
			hasSearched = false
			loadRecentlyPlayed()
			return
		}

		isLoading = true
		hasSearched = false
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

			allFetchedSongs = fetchedSongs
			currentPage = 0
			songs = Array(allFetchedSongs.prefix(pageSize))
		} catch {
			errorMessage = error.localizedDescription
		}

		isLoading = false
		hasSearched = true
	}

	func loadNextPage() {
		guard hasMorePages else { return }
		currentPage += 1
		let start = currentPage * pageSize
		let end = min(start + pageSize, allFetchedSongs.count)
		songs.append(contentsOf: allFetchedSongs[start..<end])
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

	private func resetPagination() {
		allFetchedSongs = []
		currentPage = 0
	}
}
