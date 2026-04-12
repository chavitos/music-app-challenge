//
//  Item.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import Foundation
import SwiftData

@Model
final class Item {
	var timestamp: Date
	
	init(timestamp: Date) {
		self.timestamp = timestamp
	}
}
