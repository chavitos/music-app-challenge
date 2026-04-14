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
	@Environment(\.modelContext) private var modelContext

	init(viewModel: HomeViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			List {
				ForEach(viewModel.songs) { song in
					SongItemView(song: song) {
						print("options tapped")
					}
					.listRowSeparator(.hidden)
					.listRowInsets(EdgeInsets())
					.padding(.bottom, 16)
					.onTapGesture {
						viewModel.selectSong(song)
					}
					.onAppear {
						if song.trackId == viewModel.songs.last?.trackId {
							viewModel.loadNextPage()
						}
					}
				}
				if viewModel.hasMorePages {
					HStack {
						Spacer()
						ProgressView()
						Spacer()
					}
					.listRowBackground(Color.appBackground)
					.listRowSeparator(.hidden)
				}
			}
			.contentMargins(.leading, 24, for: .scrollContent)
			.contentMargins(.trailing, 16, for: .scrollContent)
			.contentMargins(.top, 8, for: .scrollContent)
			.overlay {
				if viewModel.songs.isEmpty && !viewModel.isLoading {
					emptyStateView
				}
			}
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
				PlayerView(song: song, modelContext: modelContext)
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

	private var emptyStateView: some View {
		VStack(spacing: 16) {
			Image(systemName: "music.note.list")
				.font(.system(size: 48))
				.foregroundStyle(Color.appSecondaryText)
			Text(viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty
				 ? "Search for your favorite songs"
				 : "No results for \"\(viewModel.searchText.trimmingCharacters(in: .whitespaces))\"")
				.font(.custom("ArticulatCF-Medium", size: 16))
				.foregroundStyle(Color.appSecondaryText)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 32)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
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
