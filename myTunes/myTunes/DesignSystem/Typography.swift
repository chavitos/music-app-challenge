//
//  Typography.swift
//  myTunes
//
//  Created by Tiago Chaves on 12/04/26.
//

import SwiftUI

// MARK: - App Fonts

extension Font {
	/// ArticulatCF-DemiBold 32 — Player track name
	static let appTitle: Font = .custom("ArticulatCF-DemiBold", size: 32)
	/// ArticulatCF-DemiBold 24 — Album collection name
	static let appHeading: Font = .custom("ArticulatCF-DemiBold", size: 24)
	/// ArticulatCF-Bold 18 — Sheet / bottom-sheet title
	static let appSheetTitle: Font = .custom("ArticulatCF-Bold", size: 18)
	/// ArticulatCF-Medium 16 — Song title, body copy
	static let appBody: Font = .custom("ArticulatCF-Medium", size: 16)
	/// ArticulatCF-Medium 14 — Secondary labels (e.g. sheet artist name)
	static let appCaption: Font = .custom("ArticulatCF-Medium", size: 14)
	/// ArticulatCF-Medium 12 — Tertiary labels (artist in list, time stamps)
	static let appSmall: Font = .custom("ArticulatCF-Medium", size: 12)
	/// ArticulatCF-Medium 15 — Loading indicator text
	static let appLoading: Font = .custom("ArticulatCF-Medium", size: 15)
}
