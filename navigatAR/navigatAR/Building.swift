//
//  Building.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import IndoorAtlas

struct Building: Codable {
	static func current() -> Building? {
		if let region = IALocationManager.sharedInstance().location?.region {
			return try? Building(fromIARegion: region)
		} else {
			return nil
		}
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
