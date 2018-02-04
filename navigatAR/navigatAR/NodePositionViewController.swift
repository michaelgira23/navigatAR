//
//  NodePositionViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import IndoorAtlas

class NodePositionViewController: UIViewController {

	let locationManager = IALocationManager.sharedInstance()

	@IBAction func getGotted() {
		self.gotPosition()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Delegate methods to our custom location handler
		locationManager.delegate = self

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func gotPosition() {

		print("Got gotted");

		/** @TODO Put Firebase logic here for adding node to database */

		performSegue(withIdentifier: "unwindToManageNodesSegueId", sender: self)
	}

}

// MARK: - IndoorAtlas delegates
extension NodePositionViewController: IALocationManagerDelegate {
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
