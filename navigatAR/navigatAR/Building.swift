//
//  Building.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase
import IndoorAtlas

struct Building: Codable {
	static func current(root snapshot: DataSnapshot) -> (id: FirebasePushKey?, object: Building)? {
		guard let region = IALocationManager.sharedInstance().location?.region else { return nil }
		
		var id: FirebasePushKey? = nil

		let buildings = snapshot.childSnapshot(forPath: "buildings").value as! [FirebasePushKey: [String: String]]
		
		if let theBuilding = buildings.first(where: { $0.value["iaIdentifier"]! == region.identifier }) {
			id = theBuilding.key
		}
		
		return (id: id, object: try! Building(fromIARegion: region))
	}
	
	let name: String
	let iaIdentifier: String
	
	init(fromIARegion region: IARegion) throws {
		if region.type == ia_region_type.iaRegionTypeFloorPlan {
			name = region.name!
			iaIdentifier = region.identifier
		} else {
			throw CustomError.buildingInitializationError(msg: "Please initialize with a region object with a floor plan.")
		}
	}
}

enum CustomError: Error {
	case buildingInitializationError(msg: String)
}
