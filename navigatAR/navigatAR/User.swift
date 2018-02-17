//
//  User.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/16/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

struct User: Codable {
	// uid is not stored here since it's basically used as the push key
	let email: String
	let admin: FirebaseArray<FirebasePushKey>?
}
