//
//  Searching.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/8/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation

public class Searching {
    public static func sort(searchitems items: [String], searchquery search: String) -> [String] {
        var results: [String] = []
        
        for item in items {
            if (item.contains(search)) {
                results.append(item);
            }
        }
        
        return results
    }
}
