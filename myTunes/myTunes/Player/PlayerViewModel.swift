//
//  PlayerViewModel.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import AVFoundation

@Observable
final class PlayerViewModel {

	// MARK: - State

	let song: Song
	var isPlaying = false
	var isRepeating = false
	var currentTime: TimeInterval = 0
	var duration: TimeInterval = 0
	var album: Album?
	var albumSongs: [Song] = []

	// MARK: - Private

	@ObservationIgnored
	nonisolated(unsafe) private var player: AVPlayer?
	@ObservationIgnored
	nonisolated(unsafe) private var timeObserver: Any?
	@ObservationIgnored
	private let provider: any SongsProviding = RemoteSongsProvider()

	// MARK: - Computed

	var artworkURL: URL? {
		let highRes = song.artworkUrl.replacingOccurrences(of: "100x100", with: "600x600")
		return URL(string: highRes)
	}

	// MARK: - Init

	init(song: Song) {
		self.song = song
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
		// TODO: Implement
	}

	func previousSong() {
		// TODO: Implement
	}

	func setRepeat() {
		// TODO: Implement
	}

	func loadAlbum() async {
		do {
			let response = try await provider.loadAlbum(collectionId: song.collectionId)
			album = response.results.first(where: { $0.isCollection })?.toAlbum()
			albumSongs = response.results.compactMap { $0.toSong() }
		} catch {
			// Silently fail — "View album" simply won't be available
		}
	}

	// MARK: - Private

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
				self.currentTime = time.seconds
				if let itemDuration = self.player?.currentItem?.duration,
				   itemDuration.isNumeric {
					self.duration = itemDuration.seconds
				}
			}
		}
	}
}
