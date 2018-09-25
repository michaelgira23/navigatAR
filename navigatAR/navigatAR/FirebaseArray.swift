//
//  FirebaseArray.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/14/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

struct FirebaseArray<T: Hashable & Codable> {
	typealias ArrayType = [T]

	var values: ArrayType
}

extension FirebaseArray: Collection {
	typealias Element = ArrayType.Element
	typealias Index = ArrayType.Index

	subscript(position: Index) -> Element {
		return values[position]
	}

	var startIndex: Index {
		return values.startIndex
	}

	var endIndex: Index {
		return values.endIndex
	}

	func index(after i: Index) -> Index {
		return i + 1
	}
}

extension FirebaseArray: ExpressibleByArrayLiteral {
	typealias ArrayLiteralElement = Element

	init(arrayLiteral elements: Element...) {
		values = elements
	}
}

extension FirebaseArray: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let externalValues = try container.decode([Element: Bool].self)

		values = Array(externalValues.filter { $0.value }.keys)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(values.reduce(into: [:], { $0[$1] = true }))
	}
}
