//
//  Node.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

enum NodeType: String, Codable {
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

struct Node: Codable {
	let building: FirebasePushKey
	let name: String
	let type: NodeType
	let position: Location
	// there's no way to provide a default value for this when decoding without a custom implementation, so has to be optional
	let tags: [String: Tag]?
	var connectedTo: FirebaseArray<FirebasePushKey>?
	let highPriority: Bool?
}
