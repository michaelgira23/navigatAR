//
//  User.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/16/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase

struct User: Codable {
	static func current(root snapshot: DataSnapshot) -> (id: FirebasePushKey, object: User)? {
		guard let authUser = Auth.auth().currentUser else { return nil }
		guard let value = snapshot.childSnapshot(forPath: "user").value else { return nil }
		guard let users = try? FirebaseDecoder().decode([FirebasePushKey: User].self, from: value) else { return nil }
		
		// If authUser isn't nil, the user is guaranteed to be in the database
		return (id: authUser.uid, object: users[authUser.uid]!)
	}

	// uid is not stored here since it's basically used as the push key
	let email: String
	let admin: FirebaseArray<FirebasePushKey>?
}
