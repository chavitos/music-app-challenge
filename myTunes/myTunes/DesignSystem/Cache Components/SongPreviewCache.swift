//
//  SongPreviewCache.swift
//  myTunes
//

import Foundation

actor SongPreviewCache {
	static let shared = SongPreviewCache()

	private let cacheDirectory: URL

	init() {
		let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		let dir = base.appendingPathComponent("SongPreviews")
		try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
		cacheDirectory = dir
	}

	func localURL(for remoteURL: URL) -> URL? {
		let file = cacheDirectory.appendingPathComponent(cacheKey(for: remoteURL))
		return FileManager.default.fileExists(atPath: file.path) ? file : nil
	}

	func store(data: Data, for remoteURL: URL) {
		let file = cacheDirectory.appendingPathComponent(cacheKey(for: remoteURL))
		try? data.write(to: file)
	}

	private func cacheKey(for url: URL) -> String {
		var hash: UInt64 = 5381
		for scalar in url.absoluteString.unicodeScalars {
			hash = 127 &* hash &+ UInt64(scalar.value)
		}
		return String(hash) + ".m4a"
	}
}
