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
	let nodeId: String
	let start: String
	let end: String
	
	init(name theName: String, description theDescription: String, nodeId id: String, start eventStart: String, end eventEnd: String) {
		self.eventName = theName
		self.eventDescription = theDescription
		self.nodeId = id
		self.start = eventStart
		self.end = eventEnd
	}
}
