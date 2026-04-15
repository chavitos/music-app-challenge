//
//  CachedAsyncImage.swift
//  myTunes
//
//  Created by Tiago Chaves on 15/04/26.
//

import SwiftUI

enum CachedImagePhase {
	case empty
	case success(Image)
	case failure(Error)
}

struct CachedAsyncImage<Content: View>: View {
	let url: URL?
	let content: (CachedImagePhase) -> Content

	@State private var phase: CachedImagePhase = .empty

	init(url: URL?, @ViewBuilder content: @escaping (CachedImagePhase) -> Content) {
		self.url = url
		self.content = content
	}

	var body: some View {
		content(phase)
			.task(id: url) {
				await loadImage()
			}
	}

	private func loadImage() async {
		guard let url else {
			phase = .empty
			return
		}

		// Check cache first
		if let cached = await ImageCache.shared.image(for: url) {
			phase = .success(Image(uiImage: cached))
			return
		}

		// Download
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			guard let uiImage = UIImage(data: data) else {
				phase = .failure(URLError(.cannotDecodeContentData))
				return
			}
			await ImageCache.shared.store(data: data, for: url)
			phase = .success(Image(uiImage: uiImage))
		} catch {
			if !Task.isCancelled {
				phase = .failure(error)
			}
		}
	}
}
