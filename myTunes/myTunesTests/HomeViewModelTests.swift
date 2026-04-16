//
//  HomeViewModelTests.swift
//  myTunesTests
//

import Testing
import SwiftData
@testable import myTunes
import Foundation

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

	let container: ModelContainer
	let context: ModelContext
	let provider: MockSongsProvider
	let sut: HomeViewModel

	init() async throws {
		container = try .testContainer()
		context = container.mainContext
		provider = MockSongsProvider()
		sut = HomeViewModel(provider: provider, modelContext: context)
	}

	// MARK: - searchSongs

	@Test func searchSongs_withNonEmptyTerm_callsProvider() async {
		sut.searchText = "Beatles"
		await sut.searchSongs()
		#expect(provider.loadSongsCallCount == 1)
		#expect(provider.lastSearchTerm == "Beatles")
	}

	@Test func searchSongs_withSuccess_populatesSongs() async {
		provider.loadSongsResult = .success(.make(results: [.makeSong(trackId: 1), .makeSong(trackId: 2)]))
		sut.searchText = "Beatles"
		await sut.searchSongs()
		#expect(sut.songs.count == 2)
		#expect(sut.errorMessage == nil)
		#expect(sut.hasSearched)
		#expect(!sut.isLoading)
	}

	@Test func searchSongs_withSameTermTwice_skipsSecondCall() async {
		provider.loadSongsResult = .success(.make(results: [.makeSong()]))
		sut.searchText = "Beatles"
		await sut.searchSongs()
		await sut.searchSongs() // same term — should be skipped
		#expect(provider.loadSongsCallCount == 1)
	}

	@Test func searchSongs_withEmptyTerm_doesNotCallProvider() async {
		sut.searchText = ""
		await sut.searchSongs()
		#expect(provider.loadSongsCallCount == 0)
		#expect(!sut.hasSearched)
	}

	@Test func searchSongs_withEmptyTerm_clearsError() async {
		// Prime an error first
		provider.loadSongsResult = .failure(URLError(.notConnectedToInternet))
		sut.searchText = "Beatles"
		await sut.searchSongs()
		#expect(sut.errorMessage != nil)

		// Now clear search
		sut.searchText = ""
		await sut.searchSongs()
		#expect(sut.errorMessage == nil)
	}

	@Test func searchSongs_withNetworkError_setsOfflineErrorMessage() async {
		provider.loadSongsResult = .failure(URLError(.notConnectedToInternet))
		sut.searchText = "Beatles"
		await sut.searchSongs()
		#expect(sut.errorMessage == "No internet connection")
		#expect(sut.songs.isEmpty)
		#expect(sut.hasSearched)
	}

	@Test func searchSongs_withGenericError_setsGenericErrorMessage() async {
		provider.loadSongsResult = .failure(URLError(.badServerResponse))
		sut.searchText = "Beatles"
		await sut.searchSongs()
		#expect(sut.errorMessage == "Something went wrong. Please try again.")
	}

	@Test func searchSongs_withEmptyTerm_loadsRecentlyPlayedSongs() async {
		let played = Song.test(trackId: 1, lastPlayedAt: .now)
		context.insert(played)
		try? context.save()

		sut.searchText = ""
		await sut.searchSongs()

		#expect(sut.songs.count == 1)
		#expect(sut.songs.first?.trackId == 1)
	}

	// MARK: - loadNextPage

	@Test func loadNextPage_withMoreThanOnePage_appendsSecondPage() async {
		let results = (1...25).map { iTunesItemDTO.makeSong(trackId: $0) }
		provider.loadSongsResult = .success(.make(results: results))
		sut.searchText = "Beatles"
		await sut.searchSongs()

		#expect(sut.songs.count == 20)
		#expect(sut.hasMorePages)

		sut.loadNextPage()

		#expect(sut.songs.count == 25)
		#expect(!sut.hasMorePages)
	}

	@Test func loadNextPage_whenNoMorePages_doesNothing() async {
		provider.loadSongsResult = .success(.make(results: [.makeSong(trackId: 1)]))
		sut.searchText = "Beatles"
		await sut.searchSongs()

		#expect(!sut.hasMorePages)
		sut.loadNextPage() // should be a no-op
		#expect(sut.songs.count == 1)
	}

	// MARK: - selectSong

	@Test func selectSong_setsSelectedSong() {
		let song = Song.test(trackId: 42)
		sut.selectSong(song)
		#expect(sut.selectedSong?.trackId == 42)
	}

	// MARK: - loadAlbumForOptions

	@Test func loadAlbumForOptions_withNoSongForOptions_doesNothing() async {
		sut.songForOptions = nil
		await sut.loadAlbumForOptions()
		#expect(provider.loadAlbumCallCount == 0)
	}

	@Test func loadAlbumForOptions_withSuccess_setsAlbumAndSongs() async {
		let song = Song.test(trackId: 1, collectionId: 100)
		sut.songForOptions = song

		provider.loadAlbumResult = .success(.make(results: [
			.makeCollection(collectionId: 100),
			.makeSong(trackId: 1, collectionId: 100),
			.makeSong(trackId: 2, collectionId: 100)
		]))

		await sut.loadAlbumForOptions()

		#expect(sut.albumForOptions?.collectionId == 100)
		#expect(sut.albumSongsForOptions.count == 2)
		#expect(!sut.albumLoadFailed)
	}

	@Test func loadAlbumForOptions_withFailure_andNoCache_setsAlbumLoadFailed() async {
		let song = Song.test(trackId: 1, collectionId: 999)
		sut.songForOptions = song
		provider.loadAlbumResult = .failure(URLError(.notConnectedToInternet))

		await sut.loadAlbumForOptions()

		#expect(sut.albumForOptions == nil)
		#expect(sut.albumLoadFailed)
	}

	@Test func loadAlbumForOptions_withFailure_andCachedAlbum_usesCachedData() async {
		let cachedAlbum = Album.test(collectionId: 100)
		let cachedSong = Song.test(trackId: 5, collectionId: 100)
		context.insert(cachedAlbum)
		context.insert(cachedSong)
		try? context.save()

		let song = Song.test(trackId: 1, collectionId: 100)
		sut.songForOptions = song
		provider.loadAlbumResult = .failure(URLError(.notConnectedToInternet))

		await sut.loadAlbumForOptions()

		#expect(sut.albumForOptions?.collectionId == 100)
		#expect(!sut.albumSongsForOptions.isEmpty)
		#expect(!sut.albumLoadFailed)
	}

	// MARK: - saveAlbumForOptionsToCache

	@Test func saveAlbumForOptionsToCache_insertsAlbumAndSongsIntoContext() throws {
		sut.albumForOptions = Album.test(collectionId: 200)
		sut.albumSongsForOptions = [.test(trackId: 10, collectionId: 200)]

		sut.saveAlbumForOptionsToCache()

		let albums = try context.fetch(FetchDescriptor<Album>())
		let songs = try context.fetch(FetchDescriptor<Song>())
		#expect(albums.first?.collectionId == 200)
		#expect(!songs.isEmpty)
	}

	@Test func saveAlbumForOptionsToCache_withNoAlbum_doesNotInsert() throws {
		sut.albumForOptions = nil
		sut.saveAlbumForOptionsToCache()

		let albums = try context.fetch(FetchDescriptor<Album>())
		#expect(albums.isEmpty)
	}
}
