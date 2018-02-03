//
//  Building.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase

struct Building {
	let id: String
	let name: String
	let admins: [String]
	// let tags: [TagInfo]

	static func fromPushKey(root: DataSnapshot, key: String) -> Building {
		let building = root.childSnapshot(forPath: "buildings/\(key)").value as! [String: Any]

		return Building(
			id: key,
			name: building["name"] as! String,
			admins: Array((building["admins"] as! [String: Bool]).keys)
			// tags: Array((building["tags"] as! [String: Bool]).keys).map({ TagInfo.fromPushKey(root: rootSnapshot, key: $0) })
		)
	}
}
