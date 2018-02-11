//
//  TagInfo.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

enum TagType: String, Codable {
	case string
	case number
	case boolean
}

struct TagInfo: Codable {
	let building: FirebasePushKey
	let multiple: Bool
	let name: String
	let type: TagType
}
