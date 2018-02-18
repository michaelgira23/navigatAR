//
//  Utils.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

public typealias FirebasePushKey = String

// TODO: add more convenience methods

func degreesToRadians(_ degrees: Double) -> Double {
	return degrees * (.pi / 180)
}

extension Dictionary where Value: Equatable {
	func key(forValue value: Value) -> Key? {
		return first { $0.1 == value }?.0
	}
}
