//
//  Album.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import SwiftData

@Model
final class Album {

    // MARK: - API Identifiers

    @Attribute(.unique)
    var collectionId: Int
    var artistId: Int

    // MARK: - Display Info

    var collectionName: String
    var artistName: String
    var artworkUrl: String
    var trackCount: Int

    // MARK: - Metadata

    var releaseDate: String?
    var copyright: String?

    // MARK: - App-Specific

    var cachedAt: Date

    init(
        collectionId: Int,
        artistId: Int,
        collectionName: String,
        artistName: String,
        artworkUrl: String,
        trackCount: Int,
        releaseDate: String? = nil,
        copyright: String? = nil,
        cachedAt: Date = .now
    ) {
        self.collectionId = collectionId
        self.artistId = artistId
        self.collectionName = collectionName
        self.artistName = artistName
        self.artworkUrl = artworkUrl
        self.trackCount = trackCount
        self.releaseDate = releaseDate
        self.copyright = copyright
        self.cachedAt = cachedAt
    }
}
