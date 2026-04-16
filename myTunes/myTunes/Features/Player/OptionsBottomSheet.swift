//
//  OptionsBottomSheet.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

struct OptionsBottomSheet: View {
	let song: Song
	let onViewAlbum: () -> Void

	var body: some View {
		VStack(alignment: .center, spacing: .spacingXS) {
			Text(song.trackName)
				.font(.appSheetTitle)
				.fontWeight(.bold)
				.foregroundStyle(Color.appPrimaryText)
				.padding(.top, .spacingXL)

			Text(song.artistName)
				.font(.appCaption)
				.fontWeight(.medium)
				.foregroundStyle(Color.appPrimaryText)

			Spacer()

			Button(action: onViewAlbum) {
				HStack(spacing: .spacingM) {
					Image(.albumIcon)

					Text("View \(song.collectionName)")
						.font(.appBody)
						.fontWeight(.medium)
						.foregroundStyle(Color.appPrimaryText)
					Spacer()
				}
				.padding(.leading, 30)
			}
			.buttonStyle(.plain)
			.padding(.bottom, 30)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
	VStack {
		Color.blue
			.ignoresSafeArea()
	}
	.sheet(isPresented: .constant(true)) {
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
		)) {
			print("tap view album")
		}
		.presentationDetents([.height(192)])
		.presentationDragIndicator(.hidden)
		.presentationBackground {
			VStack {
				Color.appBackground.opacity(0.8)
			}
		}
	}
}
