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
	
	func distanceDeltas(with other: Location) -> (latitude: Double, longitude: Double, altitude: Double) {
		// https://en.wikipedia.org/wiki/Geographic_coordinate_system#Expressing_latitude_and_longitude_as_linear_units
		let latRadians = degreesToRadians(latitude)
		// Swift compiler is having difficulty parsing these all inlined for whatever reason
		let val1 = 559.82 * cos(2 * latRadians)
		let val2 = 1.175 * cos(4 * latRadians)
		let val3 = 0.0023 * cos(6 * latRadians)
		let metersPerLatitude = 111132.92 - val1 + val2 - val3
		
		let longRadians = degreesToRadians(longitude)
		let metersPerLongitude = (111412.84 * cos(longRadians)) - (93.5 * cos(3 * longRadians)) + (0.118 * cos(5 * longRadians))
		
		return (latitude: fabs(latitude - other.latitude) * metersPerLatitude, longitude: fabs(longitude - other.longitude) * metersPerLongitude, altitude: fabs(altitude - other.altitude))
	}
	
	func distanceTo(_ other: Location) -> Double {
		let (deltaLat, deltaLong, deltaAlt) = distanceDeltas(with: other)
		return sqrt(pow(deltaLat, 2) + pow(deltaLong, 2) + pow(deltaAlt, 2))
	}
	
	func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
}
