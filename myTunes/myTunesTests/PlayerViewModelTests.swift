//
//  PlayerViewModelTests.swift
//  myTunesTests
//

import Testing
import SwiftData
@testable import myTunes
import Foundation

@Suite("PlayerViewModel")
@MainActor
struct PlayerViewModelTests {

	let container: ModelContainer
	let context: ModelContext
	let provider: MockSongsProvider

	init() async throws {
		container = try .testContainer()
		context = container.mainContext
		provider = MockSongsProvider()
	}

	private func makeSUT(
		song: Song = .test(),
		songList: [Song] = []
	) -> PlayerViewModel {
		PlayerViewModel(song: song, modelContext: context, songList: songList, provider: provider)
	}

	// MARK: - canGoNext / canGoPrevious

	@Test func canGoNext_withNextSongAvailable_isTrue() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2), Song.test(trackId: 3)]
		let sut = makeSUT(song: songs[0], songList: songs)
		#expect(sut.canGoNext)
	}

	@Test func canGoNext_atLastSong_isFalse() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2)]
		let sut = makeSUT(song: songs[1], songList: songs)
		#expect(!sut.canGoNext)
	}

	@Test func canGoPrevious_withSongList_isTrue() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2)]
		let sut = makeSUT(song: songs[0], songList: songs)
		#expect(sut.canGoPrevious)
	}

	@Test func canGoPrevious_withEmptySongList_isFalse() {
		let sut = makeSUT(song: .test())
		#expect(!sut.canGoPrevious)
	}

	// MARK: - nextSong

	@Test func nextSong_advancesToNextSong() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2), Song.test(trackId: 3)]
		let sut = makeSUT(song: songs[0], songList: songs)

		sut.nextSong()

		#expect(sut.song.trackId == 2)
		#expect(sut.currentIndex == 1)
		#expect(sut.currentTime == 0)
	}

	@Test func nextSong_atLastSong_doesNothing() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2)]
		let sut = makeSUT(song: songs[1], songList: songs)

		sut.nextSong()

		#expect(sut.song.trackId == 2)
		#expect(sut.currentIndex == 1)
	}

	@Test func nextSong_withEmptyList_doesNothing() {
		let sut = makeSUT(song: .test(trackId: 1))
		sut.nextSong()
		#expect(sut.song.trackId == 1)
	}

	// MARK: - previousSong

	@Test func previousSong_withinFirst3Seconds_goesToPreviousSong() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2), Song.test(trackId: 3)]
		let sut = makeSUT(song: songs[2], songList: songs)
		sut.currentTime = 1.5

		sut.previousSong()

		#expect(sut.song.trackId == 2)
		#expect(sut.currentIndex == 1)
		#expect(sut.currentTime == 0)
	}

	@Test func previousSong_after3Seconds_seeksToStartRegardlessOfIndex() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2), Song.test(trackId: 3)]
		let sut = makeSUT(song: songs[2], songList: songs)
		sut.currentTime = 10

		sut.previousSong()

		#expect(sut.song.trackId == 3) // song unchanged
		#expect(sut.currentTime == 0)
	}

	@Test func previousSong_atFirstSong_withinFirst3Seconds_seeksToStart() {
		let songs = [Song.test(trackId: 1), Song.test(trackId: 2)]
		let sut = makeSUT(song: songs[0], songList: songs)
		sut.currentTime = 1

		sut.previousSong()

		#expect(sut.song.trackId == 1) // stays on first song
		#expect(sut.currentTime == 0)
	}

	@Test func previousSong_withEmptyList_doesNothing() {
		let sut = makeSUT(song: .test(trackId: 1))
		sut.currentTime = 1
		sut.previousSong()
		#expect(sut.song.trackId == 1)
	}

	// MARK: - seek

	@Test func seek_updatesCurrentTime() {
		let sut = makeSUT()
		sut.seek(to: 15.5)
		#expect(sut.currentTime == 15.5)
	}

	@Test func seek_toZero_setsCurrentTimeToZero() {
		let sut = makeSUT()
		sut.seek(to: 30)
		sut.seek(to: 0)
		#expect(sut.currentTime == 0)
	}

	// MARK: - artworkURL

	@Test func artworkURL_replacesResolutionWithHighRes() {
		let sut = makeSUT(song: .test())
		// Song.test() uses "https://example.com/100x100bb.jpg"
		#expect(sut.artworkURL?.absoluteString.contains("600x600") == true)
	}

	// MARK: - markAsPlayed

	@Test func markAsPlayed_withSongNotInContext_insertsAndSetsTimestamp() throws {
		let song = Song.test(trackId: 77)
		let sut = makeSUT(song: song)

		sut.markAsPlayed()

		let fetched = try context.fetch(FetchDescriptor<Song>(predicate: #Predicate { $0.trackId == 77 }))
		#expect(fetched.count == 1)
		#expect(fetched.first?.lastPlayedAt != nil)
	}

	@Test func markAsPlayed_withSongAlreadyInContext_updatesTimestamp() throws {
		let song = Song.test(trackId: 88)
		context.insert(song)
		try context.save()

		let sut = makeSUT(song: song)
		sut.markAsPlayed()

		let fetched = try context.fetch(FetchDescriptor<Song>(predicate: #Predicate { $0.trackId == 88 }))
		#expect(fetched.count == 1)
		#expect(fetched.first?.lastPlayedAt != nil)
	}

	// MARK: - saveAlbumToCache

	@Test func saveAlbumToCache_insertsAlbumAndSongsIntoContext() throws {
		let sut = makeSUT()
		sut.album = Album.test(collectionId: 300)
		sut.albumSongs = [.test(trackId: 10, collectionId: 300), .test(trackId: 11, collectionId: 300)]

		sut.saveAlbumToCache()

		let albums = try context.fetch(FetchDescriptor<Album>())
		#expect(albums.first?.collectionId == 300)
		let songs = try context.fetch(FetchDescriptor<Song>(predicate: #Predicate { $0.collectionId == 300 }))
		#expect(songs.count == 2)
	}

	@Test func saveAlbumToCache_withNilAlbum_doesNotInsert() throws {
		let sut = makeSUT()
		sut.album = nil
		sut.saveAlbumToCache()

		let albums = try context.fetch(FetchDescriptor<Album>())
		#expect(albums.isEmpty)
	}

	// MARK: - loadAlbum

	@Test func loadAlbum_withSuccess_setsAlbumAndSongs() async {
		let sut = makeSUT()
		provider.loadAlbumResult = .success(.make(results: [
			.makeCollection(collectionId: 100),
			.makeSong(trackId: 1, collectionId: 100, trackNumber: 1),
			.makeSong(trackId: 2, collectionId: 100, trackNumber: 2)
		]))

		await sut.loadAlbum()

		#expect(sut.album?.collectionId == 100)
		#expect(sut.albumSongs.count == 2)
		#expect(!sut.albumLoadFailed)
	}

	@Test func loadAlbum_withFailure_andNoCache_setsAlbumLoadFailed() async {
		let sut = makeSUT(song: .test(collectionId: 999))
		provider.loadAlbumResult = .failure(URLError(.notConnectedToInternet))

		await sut.loadAlbum()

		#expect(sut.album == nil)
		#expect(sut.albumLoadFailed)
	}

	@Test func loadAlbum_withFailure_andCachedAlbum_usesCachedData() async throws {
		let cachedAlbum = Album.test(collectionId: 100)
		let cachedSong = Song.test(trackId: 5, collectionId: 100)
		context.insert(cachedAlbum)
		context.insert(cachedSong)
		try context.save()

		let sut = makeSUT(song: .test(collectionId: 100))
		provider.loadAlbumResult = .failure(URLError(.notConnectedToInternet))

		await sut.loadAlbum()

		#expect(sut.album?.collectionId == 100)
		#expect(!sut.albumSongs.isEmpty)
		#expect(!sut.albumLoadFailed)
	}

	@Test func loadAlbum_resetsAlbumLoadFailed_beforeFetch() async {
		let sut = makeSUT()
		sut.albumLoadFailed = true

		provider.loadAlbumResult = .success(.make(results: [.makeCollection(collectionId: 100)]))
		await sut.loadAlbum()

		#expect(!sut.albumLoadFailed)
	}
}
