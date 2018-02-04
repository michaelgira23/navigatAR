//
//  Node.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CoreLocation

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
	let tags: [String: Tag] // TODO: see if this can be made more specific
}
