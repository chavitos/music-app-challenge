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

	init(song: Song) {
		_viewModel = State(initialValue: PlayerViewModel(song: song))
	}

	var body: some View {
		VStack(spacing: 0) {
			headerView

			Spacer()

			albumImageView

			Spacer()

			footerView
				.padding(.horizontal, 24)
				.padding(.bottom, 33)
		}
		.frame(maxWidth: .infinity)
		.background(Color.appBackground)
		.toolbar(.hidden, for: .navigationBar)
		.task {
			await viewModel.loadAlbum()
		}
		.sheet(isPresented: $showOptions) {
			OptionsBottomSheet(song: viewModel.song, album: viewModel.album) {
				showOptions = false
				showAlbum = true
			}
			.presentationDetents([.height(192)])
			.presentationDragIndicator(.visible)
			.presentationCornerRadius(16)
			.presentationBackground {
				ZStack {
					Color.appBackground.opacity(0.8)
				}
			}
		}
		.navigationDestination(isPresented: $showAlbum) {
			if let album = viewModel.album {
				AlbumView(album: album)
			}
		}
	}
}

// MARK: - Header
extension PlayerView {
	private var headerView: some View {
		HStack {
			backNavButton
			Spacer()
			Text(viewModel.song.collectionName)
				.font(.custom("ArticulatCF-DemiBold", size: 16))
				.foregroundStyle(Color.appPrimaryText)
				.lineLimit(1)
			Spacer()
			optionNavButton
		}
		.padding(.horizontal, 10)
	}
}

// MARK: - Footer
extension PlayerView {
	private var footerView: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(viewModel.song.trackName)
				.font(.custom("ArticulatCF-DemiBold", size: 32))
				.fontWeight(.semibold)
				.multilineTextAlignment(.center)
				.foregroundColor(Color.appPrimaryText)
			
			HStack {
				Text(viewModel.song.artistName)
					.font(.custom("ArticulatCF-Medium", size: 16))
					.fontWeight(.medium)
					.foregroundColor(Color.appPrimaryText.opacity(0.7))
				
				Spacer()
				
				Button {
					viewModel.playOrPause()
				} label: {
					Image(.repeatIcon)
				}
			}
			.padding(.bottom, 24)
			
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

// MARK: - Buttons
extension PlayerView {
	private var backNavButton: some View {
		Button {
			dismiss()
		} label: {
			Image(.backNavButton)
				.glassEffect(.clear, in: Circle())
		}
	}
	
	private var optionNavButton: some View {
		Button {
			showOptions = true
		} label: {
			Image(.optionNavButton)
				.glassEffect(.clear, in: Circle())
		}
	}
	
	private var backwardButton: some View {
		Button {
			viewModel.previousSong()
		} label: {
			Image(.backwardIcon)
		}
	}
	
	private var forwardButton: some View {
		Button {
			viewModel.nextSong()
		} label: {
			Image(.forwardIcon)
		}
	}
	
	private var playButton: some View {
		Button {
			viewModel.playOrPause()
		} label: {
			Image(.playIcon)
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
			.frame(width: 280, height: 280)
			.clipShape(RoundedRectangle(cornerRadius: 32))
		} else {
			Image(systemName: "music.note")
				.foregroundColor(.white)
				.frame(width: 280, height: 280)
				.clipShape(RoundedRectangle(cornerRadius: 32))
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
	return PlayerView(song: song)
		.modelContainer(container)
}
