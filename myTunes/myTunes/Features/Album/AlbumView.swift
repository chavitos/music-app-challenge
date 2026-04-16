//
//  AlbumView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

struct AlbumView: View {
	let album: Album
	let songs: [Song]

	@Environment(\.dismiss) private var dismiss

	private var artworkURL: URL? {
		let highRes = album.artworkUrl.replacingOccurrences(of: "100x100", with: "600x600")
		return URL(string: highRes)
	}

	var body: some View {
		VStack(spacing: 0) {
			// Fixed — does not scroll
			headerView

			artworkView
				.padding(.top, .spacingXL)
				.padding(.bottom, .spacingL)

			albumInfoView
				.padding(.bottom, .spacingL)

			// Scrollable song list
			songListView
		}
		.background(Color.appBackground)
		.toolbar(.hidden, for: .navigationBar)
	}

	// MARK: - Header

	private var headerView: some View {
		HStack {
			backNavButton
			Spacer()
		}
		.padding(.horizontal, 10)
	}

	// MARK: - Artwork

	private var artworkView: some View {
		CachedAsyncImage(url: artworkURL) { phase in
			switch phase {
				case .empty:
					RoundedRectangle(cornerRadius: .cornerRadiusL)
						.fill(Color.appSecondaryText.opacity(0.2))
				case .success(let image):
					image
						.resizable()
						.scaledToFit()
						.clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
				case .failure:
					RoundedRectangle(cornerRadius: .cornerRadiusL)
						.fill(Color.appSecondaryText.opacity(0.2))
						.overlay {
							Image(systemName: "music.note")
								.font(.system(size: .iconSizeLarge))
								.foregroundStyle(Color.appSecondaryText)
						}
			}
		}
		.frame(width: .artworkAlbumCover, height: .artworkAlbumCover)
	}

	// MARK: - Album Info

	private var albumInfoView: some View {
		VStack(spacing: 6) {
			Text(album.collectionName)
				.font(.appHeading)
				.fontWeight(.bold)
				.foregroundStyle(Color.appPrimaryText)
				.multilineTextAlignment(.center)

			Text(album.artistName)
				.font(.appBody)
				.foregroundStyle(Color.appSecondaryText)
		}
		.padding(.horizontal, .spacingXL)
	}

	// MARK: - Song List

	private var songListView: some View {
		List {
			ForEach(songs) { song in
				SongItemView(song: song)
					.listRowSeparator(.hidden)
					.listRowInsets(EdgeInsets())
					.padding(.bottom, .spacingL)
			}
		}
		.contentMargins(.leading, .spacingXL, for: .scrollContent)
		.contentMargins(.trailing, .spacingL, for: .scrollContent)
		.listStyle(.plain)
		.scrollContentBackground(.hidden)
		.scrollIndicators(.hidden)
	}

	// MARK: - Buttons

	private var backNavButton: some View {
		Button {
			dismiss()
		} label: {
			Image(.backNavButton)
				.glassEffect(.clear, in: Circle())
		}
		.buttonStyle(.plain)
	}
}
