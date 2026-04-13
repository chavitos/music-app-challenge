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
				.padding(.top, 24)
				.padding(.bottom, 16)
			
			albumInfoView
				.padding(.bottom, 16)
			
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
		AsyncImage(url: artworkURL) { phase in
			switch phase {
				case .empty:
					RoundedRectangle(cornerRadius: 24)
						.fill(Color.appSecondaryText.opacity(0.2))
						.frame(width: 240, height: 240)
				case .success(let image):
					image
						.resizable()
						.scaledToFit()
						.frame(width: 240, height: 240)
						.clipShape(RoundedRectangle(cornerRadius: 24))
				case .failure:
					RoundedRectangle(cornerRadius: 24)
						.fill(Color.appSecondaryText.opacity(0.2))
						.frame(width: 240, height: 240)
						.overlay {
							Image(systemName: "music.note")
								.font(.system(size: 48))
								.foregroundStyle(Color.appSecondaryText)
						}
				@unknown default:
					EmptyView()
			}
		}
	}
	
	// MARK: - Album Info
	
	private var albumInfoView: some View {
		VStack(spacing: 6) {
			Text(album.collectionName)
				.font(.custom("ArticulatCF-DemiBold", size: 24))
				.fontWeight(.bold)
				.foregroundStyle(Color.appPrimaryText)
				.multilineTextAlignment(.center)
			
			Text(album.artistName)
				.font(.custom("ArticulatCF-Medium", size: 16))
				.foregroundStyle(Color.appSecondaryText)
		}
		.padding(.horizontal, 24)
	}
	
	// MARK: - Song List
	
	private var songListView: some View {
		List {
			ForEach(songs) { song in
				SongItemView(song: song)
					.listRowSeparator(.hidden)
					.listRowInsets(EdgeInsets())
					.padding(.bottom, 16)
			}
		}
		.contentMargins(.leading, 24, for: .scrollContent)
		.contentMargins(.trailing, 16, for: .scrollContent)
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
