//
//  UpsertNodeViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import IndoorAtlas

class UpsertNodeViewController: UIViewController {

	let locationManager = IALocationManager.sharedInstance()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		// Delegate methods to our custom location handler
		locationManager.delegate = self
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
