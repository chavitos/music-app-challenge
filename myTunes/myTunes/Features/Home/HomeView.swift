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
	@State private var showAlbumUnavailableAlert = false
	@State private var isSearchBarHidden = false
	@State private var isSearchPresented = false
	@State private var restingContentTop: CGFloat?
	@Environment(\.modelContext) private var modelContext

	init(viewModel: HomeViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			ScrollView(.vertical) {
				ZStack {
					LazyVStack(spacing: 0) {
						ForEach(viewModel.songs) { song in
							SongItemView(song: song) {
								viewModel.songForOptions = song
								showOptions = true
							}
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
						}
					}
					.padding(.leading, .spacingXL)
					.padding(.trailing, .spacingL)
					.padding(.top, .spacingS)
					GeometryReader { proxy in
						let offset = proxy.frame(in: .named("scroll")).minY
						Color.clear.preference(
							key: ScrollContentTopKey.self,
							value: offset
						)
					}
				}
			}
			.coordinateSpace(name: "scroll")
			.onPreferenceChange(ScrollContentTopKey.self) { topY in
				if restingContentTop == nil {
					restingContentTop = topY
				}
				if let resting = restingContentTop {
					let scrolledAmount = resting - topY
					let shouldHide = scrolledAmount > 1
					if shouldHide != isSearchBarHidden {
						withAnimation(.easeInOut(duration: 0.2)) {
							isSearchBarHidden = shouldHide
						}
					}
				}
			}
			.scrollBounceBehavior(.basedOnSize)
			.scrollIndicators(.hidden)
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
				isPresented: $isSearchPresented,
				placement: .navigationBarDrawer(displayMode: .automatic),
				prompt: "Search"
			)
			.toolbar {
				if isSearchBarHidden && !isSearchPresented {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							isSearchPresented = true
						} label: {
							Image(systemName: "magnifyingglass")
								.foregroundStyle(.white)
						}
					}
				}
				if viewModel.errorMessage != nil {
					ToolbarItem(placement: .principal) {
						HStack(spacing: 6) {
							Text("Songs")
								.fontWeight(.semibold)
							Image(systemName: "wifi.slash")
								.font(.caption)
						}
						.foregroundStyle(.white)
					}
				}
			}
			.navigationDestination(item: $viewModel.selectedSong) { song in
				PlayerView(song: song, modelContext: modelContext, songList: viewModel.songs)
			}
			.navigationDestination(isPresented: $showAlbum) {
				if let album = viewModel.albumForOptions {
					AlbumView(album: album, songs: viewModel.albumSongsForOptions)
				}
			}
			.background(Color.appBackground)
			.toolbarColorScheme(.dark, for: .navigationBar)
			.toolbarBackground(Color.appBackground, for: .navigationBar)
			.alert("Album Unavailable", isPresented: $showAlbumUnavailableAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text("No internet connection. This album isn't available offline.")
			}
			.sheet(isPresented: $showOptions) {
				if let song = viewModel.songForOptions {
					OptionsBottomSheet(song: song) {
						showOptions = false
						if viewModel.albumLoadFailed {
							showAlbumUnavailableAlert = true
						} else {
							showAlbum = true
							viewModel.saveAlbumForOptionsToCache()
						}
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
	}

	private var emptyStateView: some View {
		let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespaces)

		let (icon, message): (String, String) = {
			if viewModel.errorMessage != nil {
				return ("wifi.slash", "No internet connection")
			} else if viewModel.hasSearched && !trimmed.isEmpty {
				return ("music.note.list", "No results for \"\(trimmed)\"")
			} else {
				return ("music.note.list", "Search for your favorite songs")
			}
		}()

		return VStack(spacing: .spacingL) {
			Image(systemName: icon)
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

private struct ScrollContentTopKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
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
