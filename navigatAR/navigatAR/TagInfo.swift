//
//  TagInfo.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase

enum TagType: String {
	case string
	case number
}

struct TagInfo: FirebaseModel {
	let id: FirebasePushKey

	let building: FirebasePushKey
	let multiple: Bool
	let name: String
	let type: TagType
	
	static func fromPushKey(root: DataSnapshot, key: FirebasePushKey) -> TagInfo {
		let tag = root.childSnapshot(forPath: "tags/\(key)").value as! [String: Any]
		
		return TagInfo(
			id: key,
			building: tag["building"] as! FirebasePushKey,
			multiple: tag["multiple"] as! Bool,
			name: tag["name"] as! String,
			type: TagType(rawValue: tag["type"] as! String)!
		)
	}
}
