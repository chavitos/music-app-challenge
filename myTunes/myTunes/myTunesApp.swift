//
//  myTunesApp.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI
import SwiftData

@main
struct myTunesApp: App {
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
			HomeView()
		}
		.modelContainer(sharedModelContainer)
	}
}
