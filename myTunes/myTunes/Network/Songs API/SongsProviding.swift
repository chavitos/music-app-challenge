//
//  SongsProviding.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation

protocol SongsProviding: Sendable {
	func loadSongs(with searchTerm: String) async throws -> iTunesResponseDTO
	func loadAlbum(collectionId: Int) async throws -> iTunesResponseDTO
}
