//
//  ContentView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Song.lastPlayedAt, order: .reverse) private var songs: [Song]

	var body: some View {
		NavigationStack {
			List(songs) { song in
				Text(song.trackName)
			}
			.navigationTitle("Songs")
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(for: [Song.self, Album.self], inMemory: true)
}
