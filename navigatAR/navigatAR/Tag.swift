//
//  Tag.swift
//  CodableFirebase
//
//  Created by Nick Clifford on 2/4/18.
//

enum Tag: Codable {
	case string(String)
	case number(Int)
	case boolean(Bool)
	case multipleStrings(FirebaseArray<String>)
	case multipleNumbers(FirebaseArray<Int>)
	
	init(from decoder: Decoder) throws {
		let value = try decoder.singleValueContainer()
		
		if let str = try? value.decode(String.self) {
			self = .string(str)
		} else if let num = try? value.decode(Int.self) {
			self = .number(num)
		} else if let bool = try? value.decode(Bool.self) {
			self = .boolean(bool)
		} else if let strs = try? value.decode(FirebaseArray<String>.self) {
			self = .multipleStrings(strs)
		} else if let nums = try? value.decode(FirebaseArray<Int>.self) {
			self = .multipleNumbers(nums)
		} else {
			// Should never happen, but just to make the compiler happy (and I don't want to bother with throwing an error)
			self = .string("")
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var value = encoder.singleValueContainer()

		// Switches are necessary to get associated values
		switch self {
		case .string(let str):
			try value.encode(str)
		case .number(let num):
			try value.encode(num)
		case .boolean(let bool):
			try value.encode(bool)
		case .multipleStrings(let strs):
			try value.encode(strs)
		case .multipleNumbers(let nums):
			try value.encode(nums)
		}
	}
}
