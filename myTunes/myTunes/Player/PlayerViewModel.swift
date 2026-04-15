//
//  PlayerViewModel.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import AVFoundation
import SwiftData

@Observable
@MainActor
final class PlayerViewModel {

	// MARK: - State

	private(set) var song: Song
	var isPlaying = false
	var isRepeating = false
	var currentTime: TimeInterval = 0
	var duration: TimeInterval = 0
	var isSeeking = false
	var album: Album?
	var albumSongs: [Song] = []

	// MARK: - Song List

	private(set) var songList: [Song]
	private(set) var currentIndex: Int

	var canGoNext: Bool { !songList.isEmpty && currentIndex < songList.count - 1 }
	var canGoPrevious: Bool { !songList.isEmpty }

	// MARK: - Private

	@ObservationIgnored
	nonisolated(unsafe) private var player: AVPlayer?
	@ObservationIgnored
	nonisolated(unsafe) private var timeObserver: Any?
	@ObservationIgnored
	private let provider: any SongsProviding = RemoteSongsProvider()
	private let modelContext: ModelContext

	// MARK: - Computed

	var artworkURL: URL? {
		let highRes = song.artworkUrl.replacingOccurrences(of: "100x100", with: "600x600")
		return URL(string: highRes)
	}

	var formattedCurrentTime: String {
		formatTime(currentTime)
	}

	var formattedRemainingTime: String {
		"-" + formatTime(max(duration - currentTime, 0))
	}

	// MARK: - Init

	init(song: Song, modelContext: ModelContext, songList: [Song] = []) {
		self.song = song
		self.modelContext = modelContext
		self.songList = songList
		self.currentIndex = songList.firstIndex(where: { $0.trackId == song.trackId }) ?? 0
		self.duration = Double(song.trackTimeMillis) / 1000.0
	}

	deinit {
		if let timeObserver {
			player?.removeTimeObserver(timeObserver)
		}
		player?.pause()
	}

	// MARK: - Use Cases

	func playOrPause() {
		if player == nil {
			setupPlayer()
		}

		guard let player else { return }

		if isPlaying {
			player.pause()
		} else {
			player.play()
		}
		isPlaying.toggle()
	}

	func nextSong() {
		guard !songList.isEmpty else { return }
		let nextIndex = currentIndex + 1
		guard nextIndex < songList.count else { return }
		switchToSong(at: nextIndex)
	}

	func previousSong() {
		guard !songList.isEmpty else { return }
		if currentTime > 3 {
			seek(to: 0)
			return
		}
		let prevIndex = currentIndex - 1
		guard prevIndex >= 0 else {
			seek(to: 0)
			return
		}
		switchToSong(at: prevIndex)
	}

	func setRepeat() {
		// TODO: Implement
	}

	func seek(to time: TimeInterval) {
		let cmTime = CMTime(seconds: time, preferredTimescale: 600)
		player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
		currentTime = time
	}

	func markAsPlayed() {
		let id = song.trackId
		let descriptor = FetchDescriptor<Song>(predicate: #Predicate { $0.trackId == id })
		if let existing = try? modelContext.fetch(descriptor).first {
			existing.lastPlayedAt = .now
		} else {
			song.lastPlayedAt = .now
			modelContext.insert(song)
		}
		try? modelContext.save()
	}

	func saveAlbumToCache() {
		guard let album, !albumSongs.isEmpty else { return }
		modelContext.insert(album)
		for albumSong in albumSongs {
			modelContext.insert(albumSong)
		}
		try? modelContext.save()
	}

	func loadAlbum() async {
		do {
			let response = try await provider.loadAlbum(collectionId: song.collectionId)
			album = response.results.first(where: { $0.isCollection })?.toAlbum()
			albumSongs = response.results.compactMap { $0.toSong() }
		} catch {
			// Fallback to SwiftData cache
			let id = song.collectionId
			let albumDescriptor = FetchDescriptor<Album>(
				predicate: #Predicate { $0.collectionId == id }
			)
			album = try? modelContext.fetch(albumDescriptor).first

			let songsDescriptor = FetchDescriptor<Song>(
				predicate: #Predicate { $0.collectionId == id },
				sortBy: [SortDescriptor(\.trackNumber)]
			)
			albumSongs = (try? modelContext.fetch(songsDescriptor)) ?? []
		}
	}

	// MARK: - Private

	private func switchToSong(at index: Int) {
		player?.pause()
		if let timeObserver {
			player?.removeTimeObserver(timeObserver)
		}
		player = nil
		timeObserver = nil

		currentIndex = index
		song = songList[index]
		currentTime = 0
		duration = Double(song.trackTimeMillis) / 1000.0
		isPlaying = false

		playOrPause()
		markAsPlayed()
		Task { await loadAlbum() }
	}

	private func setupPlayer() {
		guard let urlString = song.previewUrl,
			  let url = URL(string: urlString) else { return }

		let playerItem = AVPlayerItem(url: url)
		player = AVPlayer(playerItem: playerItem)

		timeObserver = player?.addPeriodicTimeObserver(
			forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
			queue: .main
		) { [weak self] time in
			guard let self else { return }
			Task { @MainActor in
				guard !self.isSeeking else { return }
				self.currentTime = time.seconds
				if let itemDuration = self.player?.currentItem?.duration,
				   itemDuration.isNumeric {
					self.duration = itemDuration.seconds
				}
			}
		}
	}

	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}
}
