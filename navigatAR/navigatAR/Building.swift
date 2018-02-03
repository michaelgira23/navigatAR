//
//  Building.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase

struct Building: FirebaseModel {
	let id: FirebasePushKey

	let name: String
	
	static func fromPushKey(root: DataSnapshot, key: FirebasePushKey) -> Building {
		let building = root.childSnapshot(forPath: "buildings/\(key)").value as! [String: Any]
		
		return Building(
			id: key,
			name: building["name"] as! String
		)
	}
}
