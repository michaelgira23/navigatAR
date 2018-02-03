//
//  Node.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase

enum NodeType {
	// Generic stuff
	case pointOfInterest

	// More specific nodes
	case pathway
	case bathroom
	case printer
	case fountain
	case room
	case sportsVenue

	// TODO: add more types if necessary
}

struct Node {
	let building: Building
	let name: String
	let admins: [String]
	// let tags: [String: Any] TODO

	static func fromPushKey(root: DataSnapshot, key: String) -> Node {
		let node = root.childSnapshot(forPath: "nodes/\(key)").value as! [String: Any]

		return Node(
			building: Building.fromPushKey(root: root, key: node["building"] as! String),
			name: node["name"] as! String,
			admins: Array((node["admins"] as! [String: Bool]).keys)
			// tags: whatever
		)
	}
}
