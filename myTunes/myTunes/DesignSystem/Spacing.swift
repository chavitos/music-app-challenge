//
//  Spacing.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import CoreFoundation

// MARK: - Spacing Scale

extension CGFloat {
	static let spacingXS: CGFloat = 4
	static let spacingS: CGFloat = 8
	static let spacingM: CGFloat = 12
	static let spacingL: CGFloat = 16
	static let spacingXL: CGFloat = 24
	static let spacing2XL: CGFloat = 32
}

// MARK: - Artwork & Icon Sizes

extension CGFloat {
	/// 52 pt — song row thumbnail
	static let artworkSongRow: CGFloat = 52
	/// 120 pt — album cover in AlbumView header
	static let artworkAlbumCover: CGFloat = 120
	/// 280 pt — album art in PlayerView
	static let artworkPlayerCover: CGFloat = 280
	/// 48 pt — large decorative icons (empty state, failure overlay)
	static let iconSizeLarge: CGFloat = 48
	/// 36 pt — navigation bar icon buttons
	static let navButtonSize: CGFloat = 36
}

// MARK: - Corner Radii

extension CGFloat {
	/// 8 pt — small elements (song row artwork)
	static let cornerRadiusS: CGFloat = 8
	/// 16 pt — cards and overlays (loading indicator background)
	static let cornerRadiusM: CGFloat = 16
	/// 24 pt — album artwork
	static let cornerRadiusL: CGFloat = 24
	/// 32 pt — player artwork
	static let cornerRadiusXL: CGFloat = 32
}
