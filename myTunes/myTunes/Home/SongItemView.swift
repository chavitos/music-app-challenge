//
//  SongItemView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

struct SongItemView: View {
	private var song: Song
	private var onTapSongOptions: (() -> Void)?

	init(song: Song, onTapSongOptions: (() -> Void)? = nil) {
		self.song = song
		self.onTapSongOptions = onTapSongOptions
	}

	var body: some View {
		HStack {
			AsyncImage(url: URL(string: song.artworkUrl)) { phase in
				switch phase {
					case .empty:
						ProgressView()
					case .success(let image):
						image
							.resizable()
							.scaledToFit()
							.frame(width: 52, height: 52)
							.cornerRadius(8)
							.padding(.trailing, 8)
					case .failure:
						Image(systemName: "music.note")
							.resizable()
							.scaledToFit()
							.frame(width: 40, height: 40)
							.cornerRadius(8)
							.foregroundColor(.white)
							.padding(.horizontal, 12)
							.padding(.vertical, 12)
					@unknown default:
						EmptyView()
				}
			}

			VStack(alignment: .leading) {
				Text(song.trackName)
					.font(.custom("ArticulatCF-Medium", size: 16))
					.fontWeight(.medium)
					.foregroundColor(Color.appPrimaryText)
				
				Text(song.artistName)
					.font(.custom("ArticulatCF-Medium", size: 12))
					.fontWeight(.medium)
					.foregroundColor(Color.appSubText)
			}
			Spacer()

			if onTapSongOptions != nil {
				Button {
					onTapSongOptions?()
				} label: {
					Image(.optionIcon)
				}
				.buttonStyle(.borderless)
			}
		}
		.listRowBackground(Color.appBackground)
		.background(Color.appBackground)
	}
}

#Preview {
	SongItemView(song: Song(
		trackId: 617154366,
		artistId: 5468295,
		collectionId: 617154241,
		trackName: "Get Lucky",
		artistName: "Daft Punk feat. Pharrell Williams",
		collectionName: "Random Access Memories",
		artworkUrl: "https://1213.jpg",
		previewUrl: "",
		trackTimeMillis: 369629,
		trackNumber: 8,
		discNumber: 1,
		releaseDate: "2013-04-19T07:00:00Z"
	)) {
		print("action")
	}
	.padding(.horizontal, 8)
}
