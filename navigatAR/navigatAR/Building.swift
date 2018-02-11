//
//  Building.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import IndoorAtlas

struct Building: Codable {
	static func current(root snapshot: DataSnapshot) -> (id: FirebasePushKey, object: Building)? {
		guard let region = IALocationManager.sharedInstance().location?.region else { return nil }
		guard let value = snapshot.childSnapshot(forPath: "buildings").value else { return nil }
		guard let buildings = try? FirebaseDecoder().decode([FirebasePushKey: Building].self, from: value) else { return nil }
		guard let building = buildings.first(where: { $0.value.indoorAtlasFloors.keys.contains(region.identifier) }) else { return nil }
			
		return (id: building.key, object: building.value)
	}
	
	let name: String
	let indoorAtlasFloors: [String: String]
}

enum CustomError: Error {
	case buildingInitializationError(msg: String)
}
