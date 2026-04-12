//
//  HTTPClient.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation

public protocol HTTPClient {
	func data(from url: URL) async throws -> (Data, URLResponse)
}
