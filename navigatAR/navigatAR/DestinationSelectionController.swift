//
//  DestinationSelectionController.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/11/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CodableFirebase

class DestinationSelectionController: UIViewController {
    
    var dest: String = "";
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var building: UILabel!
    
    override func viewDidLoad() {
        // view has loaded
        super.viewDidLoad();
        let parsed = self.dest.split(separator: ",")
        self.name.text = "Name: " + String(describing: parsed[0])
        self.type.text = "Type: " + String(describing: parsed[1])
        //self.building.text = self.getBuildingName(buildingID: String(describing: parsed[2]))
        self.getBuildingName(buildingID: String(describing: parsed[2]))
    }
    
    func getBuildingName(buildingID id: String) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        ref.child("buildings").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let loc = Array((try FirebaseDecoder().decode([FirebasePushKey: Building].self, from: value)).values)
                
                self.building.text = "Building: " + (String(describing: loc[0].name))
            }
            catch let error {
                print(error)
            }
        })
    }
}
