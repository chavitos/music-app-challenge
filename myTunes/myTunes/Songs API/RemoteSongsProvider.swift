//
//  RemoteSongsProvider.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation

final class RemoteSongsProvider: SongsProviding {
	private let client: HTTPClient
	
	init(client: HTTPClient = URLSessionHTTPClient()) {
		self.client = client
	}
	
	func loadSongs(with searchTerm: String) async throws -> iTunesResponseDTO {
		let request = iTunesAPIRequests.searchSongs(term: searchTerm)
		return try await perform(request)
	}
	
	func loadAlbum(collectionId: Int) async throws -> iTunesResponseDTO {
		let request = iTunesAPIRequests.lookupAlbum(collectionId: collectionId)
		return try await perform(request)
	}
	
	// MARK: - Private
	
	private func perform(_ request: iTunesAPIRequests) async throws -> iTunesResponseDTO {
		guard let url = request.url else {
			throw SongsProviderError.invalidURL
		}
		
		let (data, response) = try await client.data(from: url)
		
		guard let httpResponse = response as? HTTPURLResponse else {
			throw SongsProviderError.invalidResponse
		}
		
		guard (200...299).contains(httpResponse.statusCode) else {
			throw SongsProviderError.httpError(statusCode: httpResponse.statusCode)
		}
		
		do {
			return try JSONDecoder().decode(iTunesResponseDTO.self, from: data)
		} catch {
			throw SongsProviderError.decodingFailed(error)
		}
	}
}

// MARK: - Errors

enum SongsProviderError: Error {
	case invalidURL
	case invalidResponse
	case httpError(statusCode: Int)
	case decodingFailed(Error)
}

// MARK: - API Requests

enum iTunesAPIRequests {
	case searchSongs(term: String, limit: Int = 200)
	case lookupAlbum(collectionId: Int)
}

extension iTunesAPIRequests {
	
	var baseURL: String {
		"https://itunes.apple.com"
	}
	
	var path: String {
		switch self {
			case .searchSongs:
				return "/search"
			case .lookupAlbum:
				return "/lookup"
		}
	}
	
	var httpMethod: NetworkRequestMethod {
		switch self {
			case .searchSongs, .lookupAlbum:
				return .get
		}
	}
	
	var parameters: [String: String] {
		switch self {
			case .searchSongs(let term, let limit):
				return [
					"term": term,
					"media": "music",
					"entity": "song",
					"limit": "\(limit)",
				]
			case .lookupAlbum(let collectionId):
				return [
					"id": "\(collectionId)",
					"entity": "song",
				]
		}
	}
	
	var url: URL? {
		var components = URLComponents(string: baseURL)
		components?.path = path
		components?.queryItems = parameters.map {
			URLQueryItem(name: $0.key, value: $0.value)
		}
		return components?.url
	}
	
	enum NetworkRequestMethod: String {
		case get = "GET"
	}
}
