//
//  Building.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

struct Building: Codable {
	static var current: (id: FirebasePushKey, object: Building)? = nil
	
	let name: String
}
