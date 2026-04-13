//
//  HomeView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
	@State private var viewModel: HomeViewModel

	init(viewModel: HomeViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			List(viewModel.songs) { song in
				SongItemView(song: song) {
					print("options tapped")
				}
				.listRowSeparator(.hidden)
				.listRowInsets(EdgeInsets())
				.padding(.bottom, 16)
				.onTapGesture {
					viewModel.selectSong(song)
				}
			}
			.contentMargins(.leading, 24, for: .scrollContent)
			.contentMargins(.trailing, 16, for: .scrollContent)
			.contentMargins(.top, 8, for: .scrollContent)
			.navigationTitle("Songs")
			.task(id: viewModel.searchText) {
				try? await Task.sleep(for: .milliseconds(300))
				guard !Task.isCancelled else { return }
				await viewModel.searchSongs()
			}
			.searchable(
				text: $viewModel.searchText,
				placement: .navigationBarDrawer(displayMode: .automatic),
				prompt: "Search"
			)
			.navigationDestination(item: $viewModel.selectedSong) { song in
				PlayerView(song: song)
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.scrollIndicators(.hidden)
			.background(Color.appBackground)
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbarBackground(Color.appBackground, for: .navigationBar)
		}
		.preferredColorScheme(.dark)
	}
}

#Preview {
	let container = try! ModelContainer(
		for: Song.self, Album.self,
		configurations: ModelConfiguration(isStoredInMemoryOnly: true)
	)
	return HomeView(
		viewModel: HomeViewModel(
			provider: RemoteSongsProvider(),
			modelContext: container.mainContext
		)
	)
	.modelContainer(container)
}
