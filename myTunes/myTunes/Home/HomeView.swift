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
				.onTapGesture {
					viewModel.selectSong(song)
				}
			}
			.navigationTitle("Songs")
			.task(id: viewModel.searchText) {
				try? await Task.sleep(for: .milliseconds(300))
				guard !Task.isCancelled else { return }
				await viewModel.searchSongs()
			}
			.onAppear {
				Task {
					await viewModel.searchSongs()
				}
			}
			.searchable(text: $viewModel.searchText, placement: .navigationBarDrawer, prompt: "Search")
			.navigationDestination(item: $viewModel.selectedSong) { song in
				PlayerView(song: song)
			}
			.scrollContentBackground(.hidden)
			.background(.black)
			.listItemTint(.white)
		}
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
