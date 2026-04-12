//
//  URLSessionHTTPClient.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession = .shared) {
		self.session = session
	}
	
	public func data(from url: URL) async throws -> (Data, URLResponse) {
		try await session.data(from: url)
	}
}
