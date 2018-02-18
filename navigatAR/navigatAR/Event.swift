//
//  Event.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/17/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation
import CodableFirebase

struct Event: Codable {
	let eventName: String
	let eventDescription: String
	let locations: FirebaseArray<FirebasePushKey>
	let start: String
	let end: String
	
	init(name theName: String, description theDescription: String, locations locations: [String], start eventStart: String, end eventEnd: String) {
		self.eventName = theName
		self.eventDescription = theDescription
		self.locations = FirebaseArray(values: locations)
		self.start = eventStart
		self.end = eventEnd
	}
}
