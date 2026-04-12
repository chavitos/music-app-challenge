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
	@Environment(\.dismiss) private var dismiss

	init(song: Song) {
		_viewModel = State(initialValue: PlayerViewModel(song: song))
	}

	var body: some View {
		VStack(spacing: 0) {
			Spacer()

			AsyncImage(url: viewModel.artworkURL) { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
			} placeholder: {
				RoundedRectangle(cornerRadius: 8)
					.fill(.gray.opacity(0.3))
			}
			.frame(width: 280, height: 280)
			.clipShape(RoundedRectangle(cornerRadius: 8))

			Spacer()
				.frame(height: 40)

			VStack(spacing: 6) {
				Text(viewModel.song.trackName)
					.font(.title2)
					.fontWeight(.bold)

				Text(viewModel.song.artistName)
					.font(.body)
					.foregroundStyle(.secondary)
			}

			Spacer()
				.frame(height: 48)

			Button {
				viewModel.playOrPause()
			} label: {
				Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
					.font(.system(size: 64))
					.symbolRenderingMode(.hierarchical)
			}

			Spacer()
		}
		.frame(maxWidth: .infinity)
		.navigationTitle(viewModel.song.collectionName)
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "chevron.left")
				}
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					// TODO: Show options bottom sheet
				} label: {
					Image(systemName: "ellipsis")
				}
			}
		}
		.task {
			viewModel.playOrPause()
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
		PlayerView(song: song)
	}
	.modelContainer(container)
}
