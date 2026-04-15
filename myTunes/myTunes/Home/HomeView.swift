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
	@State private var showOptions = false
	@State private var showAlbum = false
	@Environment(\.modelContext) private var modelContext

	init(viewModel: HomeViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			List {
				ForEach(viewModel.songs) { song in
					SongItemView(song: song) {
						viewModel.songForOptions = song
						showOptions = true
					}
					.listRowSeparator(.hidden)
					.listRowInsets(EdgeInsets())
					.padding(.bottom, .spacingL)
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
			.contentMargins(.leading, .spacingXL, for: .scrollContent)
			.contentMargins(.trailing, .spacingL, for: .scrollContent)
			.contentMargins(.top, .spacingS, for: .scrollContent)
			.overlay {
				if viewModel.isLoading {
					LoadingIndicatorView(size: 32, text: "Searching...")
				} else if viewModel.songs.isEmpty {
					emptyStateView
				}
			}
			.navigationTitle("Songs")
			.task(id: viewModel.searchText) {
				try? await Task.sleep(for: .milliseconds(300))
				guard !Task.isCancelled else { return }
				await viewModel.searchSongs()
			}
			.task(id: viewModel.songForOptions?.trackId) {
				await viewModel.loadAlbumForOptions()
			}
			.searchable(
				text: $viewModel.searchText,
				placement: .navigationBarDrawer(displayMode: .automatic),
				prompt: "Search"
			)
			.navigationDestination(item: $viewModel.selectedSong) { song in
				PlayerView(song: song, modelContext: modelContext, songList: viewModel.songs)
			}
			.navigationDestination(isPresented: $showAlbum) {
				if let album = viewModel.albumForOptions {
					AlbumView(album: album, songs: viewModel.albumSongsForOptions)
				}
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.scrollIndicators(.hidden)
			.background(Color.appBackground)
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbarBackground(Color.appBackground, for: .navigationBar)
			.sheet(isPresented: $showOptions) {
				if let song = viewModel.songForOptions {
					OptionsBottomSheet(song: song) {
						showOptions = false
						showAlbum = true
						viewModel.saveAlbumForOptionsToCache()
					}
					.presentationDetents([.height(192)])
					.presentationDragIndicator(.hidden)
					.presentationBackground {
						ZStack {
							Color.appBackground.opacity(0.8)
						}
					}
				}
			}
		}
		.preferredColorScheme(.dark)
		.networkAware()
	}

	private var emptyStateView: some View {
		let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespaces)
		let message = (viewModel.hasSearched && !trimmed.isEmpty)
			? "No results for \"\(trimmed)\""
			: "Search for your favorite songs"
		return VStack(spacing: .spacingL) {
			Image(systemName: "music.note.list")
				.font(.system(size: .iconSizeLarge))
				.foregroundStyle(Color.appSecondaryText)
			Text(message)
				.font(.appBody)
				.foregroundStyle(Color.appSecondaryText)
				.multilineTextAlignment(.center)
				.padding(.horizontal, .spacing2XL)
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
