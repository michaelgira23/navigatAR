//
//  Location.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CoreLocation
import IndoorAtlas

// NOTE: This is used instead of just CLLocation because of Codable conformance.
struct Location: Codable {
	let latitude: CLLocationDegrees
	let longitude: CLLocationDegrees
	let altitude: CLLocationDistance
	let floor: Int
	let verticalAccuracy: CLLocationAccuracy
	let horizontalAccuracy: CLLocationAccuracy

	init(fromIALocation ial: IALocation) {
		latitude = ial.location!.coordinate.latitude
		longitude = ial.location!.coordinate.longitude
		altitude = ial.location!.altitude
		floor = ial.floor!.level
		verticalAccuracy = ial.location!.verticalAccuracy
		horizontalAccuracy = ial.location!.horizontalAccuracy
	}
}

