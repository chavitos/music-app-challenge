//
//  AlbumView.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

struct AlbumView: View {
	let album: Album

	var body: some View {
		VStack {
			Text(album.collectionName)
				.font(.title2)
				.fontWeight(.bold)
				.foregroundStyle(Color.appPrimaryText)

			Text(album.artistName)
				.font(.body)
				.foregroundStyle(Color.appSecondaryText)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.appBackground)
		.toolbar(.hidden, for: .navigationBar)
	}
}
