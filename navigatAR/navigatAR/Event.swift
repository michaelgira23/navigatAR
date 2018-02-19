//
//  Event.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/17/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation

struct Event: Codable {
	let name: String
	let description: String
	let locations: FirebaseArray<FirebasePushKey>
	let start: Date
	let end: Date
}
