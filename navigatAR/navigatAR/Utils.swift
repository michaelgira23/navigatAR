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

func tagPairToString(_ tagPair: (String, Tag)) -> String {
	switch tagPair.1 {
	case Tag.string(let str):
		return str
	case Tag.number(let int):
		return String(describing: int)
	case Tag.boolean(let bool):
		return bool ? tagPair.0 : ""
	case Tag.multipleStrings(let strs):
		return strs.joined(separator: ",")
	case Tag.multipleNumbers(let ints):
		return ints.map { String(describing: $0) }.joined(separator: ",")
	}
}

