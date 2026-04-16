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

	// MARK: - Options / Album State

	var songForOptions: Song?
	var albumForOptions: Album?
	var albumSongsForOptions: [Song] = []
	var albumLoadFailed = false

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

		guard trimmed != lastSearchTerm else { return }
		lastSearchTerm = trimmed

		guard !trimmed.isEmpty else {
			resetPagination()
			hasSearched = false
			errorMessage = nil
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
			songs = []
			let offline = isNetworkError(error)
			errorMessage = offline ? "No internet connection" : "Something went wrong. Please try again."
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

	func loadAlbumForOptions() async {
		guard let song = songForOptions else { return }
		albumLoadFailed = false
		do {
			let response = try await provider.loadAlbum(collectionId: song.collectionId)
			albumForOptions = response.results.first(where: { $0.isCollection })?.toAlbum()
			albumSongsForOptions = response.results.compactMap { $0.toSong() }
		} catch {
			let id = song.collectionId
			let albumDescriptor = FetchDescriptor<Album>(predicate: #Predicate { $0.collectionId == id })
			albumForOptions = try? modelContext.fetch(albumDescriptor).first
			let songsDescriptor = FetchDescriptor<Song>(
				predicate: #Predicate { $0.collectionId == id },
				sortBy: [SortDescriptor(\.trackNumber)]
			)
			albumSongsForOptions = (try? modelContext.fetch(songsDescriptor)) ?? []

			if albumForOptions == nil {
				albumLoadFailed = true
			}
		}
	}

	func saveAlbumForOptionsToCache() {
		guard let album = albumForOptions, !albumSongsForOptions.isEmpty else { return }
		modelContext.insert(album)
		for song in albumSongsForOptions {
			modelContext.insert(song)
		}
		try? modelContext.save()
	}

	// MARK: - Private

	private func isNetworkError(_ error: Error) -> Bool {
		if let urlError = error as? URLError {
			switch urlError.code {
			case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotConnectToHost, .cannotFindHost:
				return true
			default:
				return false
			}
		}
		return !NetworkMonitor.shared.isConnected
	}

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
