//
//  myTunesApp.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct myTunesApp: App {

	init() {
		let size = CGSize(width: 24, height: 24)
		let renderer = UIGraphicsImageRenderer(size: size)
		let thumbImage = renderer.image { context in
			UIColor.white.setFill()
			context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
		}
		UISlider.appearance().setThumbImage(thumbImage, for: .normal)
	}

	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			Song.self,
			Album.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var body: some Scene {
		WindowGroup {
			HomeView(
				viewModel: HomeViewModel(
					provider: RemoteSongsProvider(),
					modelContext: sharedModelContainer.mainContext
				)
			)
		}
		.modelContainer(sharedModelContainer)
	}
}
