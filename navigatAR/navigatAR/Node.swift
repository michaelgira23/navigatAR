//
//  Node.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase

enum NodeType: String {
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

struct Node: FirebaseModel {
	let id: FirebasePushKey

	let building: FirebasePushKey
	let name: String
	let type: NodeType
	// let position: CLLocation TODO
	// let tags: [String: Any] TODO

	static func fromPushKey(root: DataSnapshot, key: FirebasePushKey) -> Node {
		let node = root.childSnapshot(forPath: "nodes/\(key)").value as! [String: Any]

		return Node(
			id: key,
			building: node["building"] as! FirebasePushKey,
			name: node["name"] as! String,
			type: NodeType(rawValue: node["type"] as! String)!
			// TODO: the rest of these
		)
	}
}
