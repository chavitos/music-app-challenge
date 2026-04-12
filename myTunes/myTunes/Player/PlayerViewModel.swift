//
//  PlayerViewModel.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation

@Observable
final class PlayerViewModel {

	// MARK: - State

	let song: Song
	var isPlaying = false
	var isRepeating = false
	var currentTime: TimeInterval = 0
	var duration: TimeInterval = 0

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

	// MARK: - Use Cases

	func playOrPause() {
		// TODO: Implement
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
}
