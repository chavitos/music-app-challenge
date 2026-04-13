//
//  OptionsBottomSheet.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

struct OptionsBottomSheet: View {
	let song: Song
	let album: Album?
	let onViewAlbum: () -> Void
	
	var body: some View {
		VStack(alignment: .center, spacing: 4) {
			Text(song.trackName)
				.font(.custom("ArticulatCF-Bold", size: 18))
				.fontWeight(.bold)
				.foregroundStyle(Color.appPrimaryText)
				.padding(.top, 10)
			
			Text(song.artistName)
				.font(.custom("ArticulatCF-Medium", size: 14))
				.fontWeight(.medium)
				.foregroundStyle(Color.appPrimaryText)
			
			Spacer()
			
			Button(action: onViewAlbum) {
				HStack(spacing: 12) {
					Image(.albumIcon)
					
					Text("View \(album?.collectionName ?? "album")")
						.font(.custom("ArticulatCF-Medium", size: 16))
						.fontWeight(.medium)
						.foregroundStyle(Color.appPrimaryText)
					Spacer()
				}
				.padding(.leading, 30)
			}
			.buttonStyle(.plain)
			.padding(.bottom, 30)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview {
	OptionsBottomSheet(song: Song(
		trackId: 617154366,
		artistId: 5468295,
		collectionId: 617154241,
		trackName: "Get Lucky",
		artistName: "Daft Punk feat. Pharrell Williams",
		collectionName: "Random Access Memories",
		artworkUrl: "",
		previewUrl: "",
		trackTimeMillis: 369629,
		trackNumber: 8,
		discNumber: 1,
		releaseDate: "2013-04-19T07:00:00Z"
	), album: nil) {
		print("tap view album")
	}
	.background(.black)
	.frame(width: 414, height: 192)
}
