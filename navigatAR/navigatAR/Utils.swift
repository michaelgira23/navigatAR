//
//  Utils.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

public typealias FirebasePushKey = String

public func camelToTitle(str: String) -> String {
	return (str.prefix(1).uppercased() + str.dropFirst()).reduce(into: "", { (result, char) in
		if ("A"..."Z").contains(char) && result.count > 0 {
			result.append(" ")
		}
		
		result.append(char)
	})
}

// TODO: add convenience methods
