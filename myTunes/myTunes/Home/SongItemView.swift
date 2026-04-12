//
//  SongItemView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

struct SongItemView: View {
	private var song: Song
	private var onTapSongOptions: () -> Void

	init(song: Song, onTapSongOptions: @escaping () -> Void) {
		self.song = song
		self.onTapSongOptions = onTapSongOptions
	}

	var body: some View {
		HStack {
			if let artworkUrl = URL(string: song.artworkUrl) {
				AsyncImage(url: artworkUrl) { phase in
					switch phase {
						case .empty:
							ProgressView()
						case .success(let image):
							image
								.resizable()
								.scaledToFit()
								.frame(width: 52, height: 52)
								.cornerRadius(8)
								.padding(.trailing, 16)
						case .failure:
							Image(systemName: "music.note")
								.resizable()
								.scaledToFit()
								.frame(width: 52, height: 52)
								.cornerRadius(8)
								.padding(.trailing, 16)
						@unknown default:
							EmptyView()
					}
				}
			} else {
				Image(systemName: "music.note")
					.resizable()
					.scaledToFit()
					.frame(width: 52, height: 52)
					.cornerRadius(8)
					.padding(.trailing, 16)
			}

			VStack(alignment: .leading) {
				Text(song.trackName)
					.font(.custom("Articulat CF Medium", size: 16))
					.fontWeight(.medium)
					.foregroundColor(Color.appPrimaryText)
					.padding(.bottom, 4)
				Text(song.artistName)
					.font(.custom("ArticulatCF-Medium", size: 12))
					.fontWeight(.medium)
					.foregroundColor(Color.appSecondaryText)
			}
			Spacer()

			Button {
				onTapSongOptions()
			} label: {
				Text("...")
					.fontWeight(.bold)
					.foregroundColor(Color.appSecondaryText)
			}
			.buttonStyle(.borderless)
		}
		.listRowBackground(Color.appBackground)
		.background(Color.appBackground)
	}
}
