//
//  FirebaseUtils.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase

public typealias FirebasePushKey = String

public protocol FirebaseModel {
	var id: FirebasePushKey { get }

	static func fromPushKey(root: DataSnapshot, key: FirebasePushKey) -> Self
}
