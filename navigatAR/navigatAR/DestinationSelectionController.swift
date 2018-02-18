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
import FuzzyMatchingSwift

class DestinationSelectionController: UIViewController {

	var dest: String = ""
	var nodePushKey: String = ""

	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var type: UILabel!
	@IBOutlet weak var building: UILabel!

	@IBAction func navigate(_ sender: Any) {
		performSegue(withIdentifier: "navigateToPoint", sender: nodePushKey);
	}

	override func viewDidLoad() {
		// view has loaded
		super.viewDidLoad();
		let parsed = self.dest.split(separator: ",")
		nodePushKey = String(parsed[0])
		self.name.text = "Name: " + String(describing: parsed[1])
		self.type.text = "Type: " + String(describing: parsed[2])
		//self.building.text = self.getBuildingName(buildingID: String(describing: parsed[3]))
		self.getBuildingName(buildingID: String(describing: parsed[3]))
		print("dest", dest, parsed)
	}

	func getBuildingName(buildingID id: String) {
		var ref: DatabaseReference!

		ref = Database.database().reference()

		ref.child("buildings").observe(.value, with: { (snapshot) in
			guard let value = snapshot.value else { return }
			let buildings = try! FirebaseDecoder().decode([FirebasePushKey: Building].self, from: value)

			let name = buildings.first(where: { $0.key == id })!.value.name

			self.building.text = "Building: " + String(describing: name)
		})
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "navigateToPoint") {
			if let destination = segue.destination as? UITabBarController {
				for viewController in destination.viewControllers! {
					if let navController = viewController as? NavViewController {
						navController.navigating = true
						navController.navigateTo = nodePushKey
					}
				}
			}
		}
	}
}
