//
//  LocationDelegate.swift
//  navigatAR
//
//  Created by Michael Gira on 2/22/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CoreLocation
import IndoorAtlas

protocol LocationDelegate: class {
	func locationUpdate(currentLocation: Location?, kalmanLocation: CLLocation?)
}
