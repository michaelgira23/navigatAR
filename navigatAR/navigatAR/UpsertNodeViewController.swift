//
//  UpsertNodeViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Eureka
import IndoorAtlas

class UpsertNodeViewController: FormViewController {

	let locationManager = IALocationManager.sharedInstance()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Delegate methods to our custom location handler
		locationManager.delegate = self

		form +++ TextRow() { row in
				row.title = "Name"
				row.placeholder = "Ex. STEM 252"
			}
			+++ SelectableSection<ListCheckRow<String>>("Node Type", selectionType: .singleSelection(enableDeselection: true))
		let nodeTypes = ["Pathway", "Bathroom", "Printer", "Water Fountain", "Room", "Sports Venue", "Monument"]
		for option in nodeTypes {
			form.last! <<< ListCheckRow<String>(option){ listRow in
				listRow.title = option
				listRow.selectableValue = option
				listRow.value = nil
			}
		}

		form +++ ButtonRow() { row in
				row.title = "Create"
			}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

// MARK: - IndoorAtlas delegates
extension UpsertNodeViewController: IALocationManagerDelegate {
	// recieve locaiton info
	func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {

		let l = locations.last as! IALocation

		if let newLocation = l.location?.coordinate {
			print("Position changed to coordinate: \(newLocation.latitude) \(newLocation.longitude)")
		}
	}

	func indoorLocationManager(_ manager: IALocationManager, statusChanged status: IAStatus) {
		let statusNum = String(status.type.rawValue)
		print("Status: " + statusNum)
	}
}
