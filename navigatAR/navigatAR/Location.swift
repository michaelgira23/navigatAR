//
//  Location.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CoreLocation

// NOTE: This is used instead of just CLLocation because of Codable conformance.
struct Location: Codable {
	let latitude: CLLocationDegrees
	let longitude: CLLocationDegrees
	let altitude: CLLocationDistance
	
	init(fromCoreLocation cl: CLLocation) {
		latitude = cl.coordinate.latitude
		longitude = cl.coordinate.longitude
		altitude = cl.altitude
	}
}
