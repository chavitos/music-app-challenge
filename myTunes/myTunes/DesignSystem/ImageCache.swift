//
//  ImageCache.swift
//  myTunes
//
//  Created by Tiago Chaves on 15/04/26.
//

import UIKit

actor ImageCache {
	static let shared = ImageCache(maxBytes: 50_000_000) // 50 MB

	private let maxBytes: Int
	private let memoryCache = NSCache<NSString, UIImage>()
	private let cacheDirectory: URL
	private var manifest: [String: ManifestEntry] = [:]
	private var currentDiskSize: Int = 0

	private struct ManifestEntry: Codable {
		let filename: String
		var size: Int
		var lastAccessed: Date
	}

	init(maxBytes: Int) {
		self.maxBytes = maxBytes
		memoryCache.totalCostLimit = maxBytes / 5 // 20% for memory

		let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		let directory = caches.appendingPathComponent("ImageCache", isDirectory: true)
		cacheDirectory = directory

		try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

		// Load manifest inline (init is nonisolated on actors)
		let manifestURL = directory.appendingPathComponent("manifest.json")
		if let data = try? Data(contentsOf: manifestURL),
		   let loaded = try? JSONDecoder().decode([String: ManifestEntry].self, from: data) {
			manifest = loaded
			currentDiskSize = loaded.values.reduce(0) { $0 + $1.size }
		}
	}

	func image(for url: URL) -> UIImage? {
		let key = cacheKey(for: url)

		// Memory hit
		if let cached = memoryCache.object(forKey: key as NSString) {
			manifest[key]?.lastAccessed = Date()
			return cached
		}

		// Disk hit
		let filePath = cacheDirectory.appendingPathComponent(key)
		guard let data = try? Data(contentsOf: filePath),
			  let diskImage = UIImage(data: data) else {
			return nil
		}

		// Promote to memory
		memoryCache.setObject(diskImage, forKey: key as NSString, cost: data.count)
		manifest[key]?.lastAccessed = Date()
		return diskImage
	}

	func store(data: Data, for url: URL) {
		let key = cacheKey(for: url)
		let fileURL = cacheDirectory.appendingPathComponent(key)

		evictIfNeeded(for: data.count)

		// Write to disk
		try? data.write(to: fileURL)
		manifest[key] = ManifestEntry(filename: key, size: data.count, lastAccessed: Date())
		currentDiskSize += data.count
		saveManifest()

		// Add to memory
		if let uiImage = UIImage(data: data) {
			memoryCache.setObject(uiImage, forKey: key as NSString, cost: data.count)
		}
	}

	private func evictIfNeeded(for incomingSize: Int) {
		guard currentDiskSize + incomingSize > maxBytes else { return }

		let sorted = manifest.sorted { $0.value.lastAccessed < $1.value.lastAccessed }

		for (key, entry) in sorted {
			guard currentDiskSize + incomingSize > maxBytes else { break }

			let fileURL = cacheDirectory.appendingPathComponent(entry.filename)
			try? FileManager.default.removeItem(at: fileURL)
			memoryCache.removeObject(forKey: key as NSString)
			currentDiskSize -= entry.size
			manifest.removeValue(forKey: key)
		}
	}

	private func cacheKey(for url: URL) -> String {
		let input = url.absoluteString
		var hash: UInt64 = 5381
		for byte in input.utf8 {
			hash = 127 &* (hash & 0x00ffffffffffffff) &+ UInt64(byte)
		}
		return String(hash, radix: 36)
	}

	private func saveManifest() {
		let manifestURL = cacheDirectory.appendingPathComponent("manifest.json")
		guard let data = try? JSONEncoder().encode(manifest) else { return }
		try? data.write(to: manifestURL)
	}
}
