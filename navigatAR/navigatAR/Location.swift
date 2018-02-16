//
//  Location.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CoreLocation
import IndoorAtlas

// NOTE: This is used instead of just IALocation because of Codable conformance.
struct Location: Codable {
	// https://en.wikipedia.org/wiki/Geographic_coordinate_system#Expressing_latitude_and_longitude_as_linear_units
	static func metersPerLatitude(degrees: Double) -> Double {
		let radians = degreesToRadians(degrees)
		
		// Swift compiler is having difficulty parsing these all inlined for whatever reason
		let val1 = 559.82 * cos(2 * radians)
		let val2 = 1.175 * cos(4 * radians)
		let val3 = 0.0023 * cos(6 * radians)
		return 111132.92 - val1 + val2 - val3
	}
	static func metersPerLongitude(degrees: Double) -> Double {
		let radians = degreesToRadians(degrees)
		return (111412.84 * cos(radians)) - (93.5 * cos(3 * radians)) + (0.118 * cos(5 * radians))
	}
	
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
	
	func distanceTo(_ other: Location) -> Double {
		let deltaLatitude = fabs(latitude - other.latitude)
		let deltaLongitude = fabs(longitude - other.longitude)
		let deltaAltitude = fabs(altitude - other.altitude)
		
		return sqrt(pow(Location.metersPerLatitude(degrees: deltaLatitude), 2) + pow(Location.metersPerLongitude(degrees: deltaLongitude), 2) + pow(deltaAltitude, 2))
	}
}
