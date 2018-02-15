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
	
	func distanceTo(_ other: Location) -> Double {
		// https://en.wikipedia.org/wiki/Geographic_coordinate_system#Expressing_latitude_and_longitude_as_linear_units
		let metersPerLatitude = 111132.92 - (559.82 * cos(2 * other.latitude)) + (1.175 * cos(4 * other.latitude)) - (0.0023 * cos(6 * other.latitude))
		let metersPerLongitude = (111412.84 * cos(other.longitude)) - (93.5 * cos(3 * other.longitude)) + (0.118 * cos(5 * other.longitude))
		
		let deltaLatitude = fabs(latitude - other.latitude)
		let deltaLongitude = fabs(longitude - other.longitude)
		let deltaAltitude = fabs(altitude - other.altitude)
		
		return sqrt(pow(deltaLatitude * metersPerLatitude, 2) + pow(deltaLongitude * metersPerLongitude, 2) + pow(deltaAltitude, 2))
	}
}
