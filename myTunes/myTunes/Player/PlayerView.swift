//
//  PlayerView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI
import SwiftData

struct PlayerView: View {
	@State private var viewModel: PlayerViewModel
	@State private var showOptions = false
	@State private var showAlbum = false
	@Environment(\.dismiss) private var dismiss

	init(song: Song, modelContext: ModelContext, songList: [Song] = []) {
		_viewModel = State(initialValue: PlayerViewModel(
			song: song,
			modelContext: modelContext,
			songList: songList
		))
	}

	var body: some View {
		VStack(spacing: 0) {
			Spacer()

			albumImageView

			Spacer()

			footerView
				.padding(.horizontal, .spacingXL)
				.padding(.bottom, 33)
		}
		.frame(maxWidth: .infinity)
		.background(Color.appBackground)
		.networkAware()
		.navigationBarBackButtonHidden(true)
		.navigationTitle(viewModel.song.collectionName)
		.navigationBarTitleDisplayMode(.inline)
		.toolbarColorScheme(.dark, for: .navigationBar)
		.toolbarBackground(Color.appBackground, for: .navigationBar)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				backNavButton
			}
			ToolbarItem(placement: .topBarTrailing) {
				optionNavButton
			}
		}
		.task {
			await viewModel.loadAlbum()
			viewModel.markAsPlayed()
		}
		.sheet(isPresented: $showOptions) {
			OptionsBottomSheet(song: viewModel.song, album: viewModel.album) {
				showOptions = false
				showAlbum = true
				viewModel.saveAlbumToCache()
			}
			.presentationDetents([.height(192)])
			.presentationDragIndicator(.visible)
			.presentationCornerRadius(.cornerRadiusM)
			.presentationBackground {
				ZStack {
					Color.appBackground.opacity(0.8)
				}
			}
		}
		.navigationDestination(isPresented: $showAlbum) {
			if let album = viewModel.album {
				AlbumView(album: album, songs: viewModel.albumSongs)
			} else {
				EmptyView()
			}
		}
	}
}

// MARK: - Footer
extension PlayerView {
	private var footerView: some View {
		VStack(alignment: .leading, spacing: .spacingXS) {
			Text(viewModel.song.trackName)
				.font(.appTitle)
				.fontWeight(.semibold)
				.multilineTextAlignment(.center)
				.foregroundColor(Color.appPrimaryText)

			HStack {
				Text(viewModel.song.artistName)
					.font(.appBody)
					.fontWeight(.medium)
					.foregroundColor(Color.appPrimaryText.opacity(0.7))

				Spacer()

				Button {
					viewModel.setRepeat()
				} label: {
					Image(.repeatIcon)
				}
			}
			.padding(.bottom, .spacingXL)

			sliderView
				.padding(.bottom, .spacingXL)

			HStack {
				Spacer()
				backwardButton

				playButton
					.padding(.horizontal, 28)

				forwardButton
				Spacer()
			}
		}
	}
}

// MARK: - Slider
extension PlayerView {
	private var sliderView: some View {
		VStack(spacing: .spacingXS) {
			Slider(
				value: $viewModel.currentTime,
				in: 0...max(viewModel.duration, 1),
				onEditingChanged: { editing in
					viewModel.isSeeking = editing
					if !editing {
						viewModel.seek(to: viewModel.currentTime)
					}
				}
			)
			.tint(Color.white.opacity(0.6))

			HStack {
				Text(viewModel.formattedCurrentTime)
					.font(.appSmall)
					.foregroundStyle(Color.appSecondaryText)
				Spacer()
				Text(viewModel.formattedRemainingTime)
					.font(.appSmall)
					.foregroundStyle(Color.appSecondaryText)
			}
		}
	}
}

// MARK: - Buttons
extension PlayerView {
	private var backNavButton: some View {
		Button {
			dismiss()
		} label: {
			Image(.backNavButton)
				.resizable()
				.scaledToFit()
				.frame(width: .navButtonSize, height: .navButtonSize)
		}
		.buttonStyle(.plain)
	}

	private var optionNavButton: some View {
		Button {
			showOptions = true
		} label: {
			Image(.optionNavButton)
				.resizable()
				.scaledToFit()
				.frame(width: .navButtonSize, height: .navButtonSize)
		}
		.buttonStyle(.plain)
	}

	private var backwardButton: some View {
		Button {
			viewModel.previousSong()
		} label: {
			Image(.backwardIcon)
		}
		.disabled(!viewModel.canGoPrevious)
		.opacity(viewModel.canGoPrevious ? 1.0 : 0.4)
	}

	private var forwardButton: some View {
		Button {
			viewModel.nextSong()
		} label: {
			Image(.forwardIcon)
		}
		.disabled(!viewModel.canGoNext)
		.opacity(viewModel.canGoNext ? 1.0 : 0.4)
	}

	private var playButton: some View {
		Button {
			viewModel.playOrPause()
		} label: {
			Image(viewModel.isPlaying ? .pauseIcon : .playIcon)
				.glassEffect(.clear, in: Circle())
		}
	}

	private var repeatButton: some View {
		Button {
			viewModel.setRepeat()
		} label: {
			Image(.repeatIcon)
		}
	}
}

// MARK: - Image
extension PlayerView {
	@ViewBuilder
	private var albumImageView: some View {
		if let url = viewModel.artworkURL {
			AsyncImage(url: url) { phase in
				switch phase {
					case .empty:
						ProgressView()
					case .success(let image):
						image
							.resizable()
							.scaledToFit()
					case .failure:
						Image(systemName: "music.note")
							.resizable()
							.scaledToFit()
					@unknown default:
						EmptyView()
				}
			}
			.frame(width: .artworkPlayerCover, height: .artworkPlayerCover)
			.clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
		} else {
			Image(systemName: "music.note")
				.foregroundColor(.white)
				.frame(width: .artworkPlayerCover, height: .artworkPlayerCover)
				.clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
		}
	}
}

#Preview {
	let container = try! ModelContainer(
		for: Song.self, Album.self,
		configurations: ModelConfiguration(isStoredInMemoryOnly: true)
	)
	let song = Song(
		trackId: 617154366,
		artistId: 5468295,
		collectionId: 617154241,
		trackName: "Get Lucky",
		artistName: "Daft Punk feat. Pharrell Williams",
		collectionName: "Random Access Memories",
		artworkUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/e8/43/5f/e8435ffa-b6b9-b171-40ab-4ff3959ab661/886443919266.jpg/100x100bb.jpg",
		previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/d4/d3/1e/d4d31eb4-7405-b806-8346-3c52ad5b4cf4/mzaf_8095545455942962509.plus.aac.p.m4a",
		trackTimeMillis: 369629,
		trackNumber: 8,
		discNumber: 1,
		releaseDate: "2013-04-19T07:00:00Z"
	)
	container.mainContext.insert(song)
	return NavigationStack {
		PlayerView(song: song, modelContext: container.mainContext)
	}
	.modelContainer(container)
}
