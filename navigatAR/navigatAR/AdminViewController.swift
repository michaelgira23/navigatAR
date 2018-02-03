//
//  AdminViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import IndoorAtlas

class AdminViewController: UIViewController {

	@IBOutlet weak var locationText: UILabel!
	@IBOutlet weak var statusText: UILabel!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

    // MARK: - IndoorAtlas delegates
extension AdminViewController: IALocationManagerDelegate {
	// recieve locaiton info
	func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {

		let l = locations.last as! IALocation

		if let newLocation = l.location?.coordinate {
			locationText.text = "Position changed to coordinate: \(newLocation.latitude) \(newLocation.longitude)"
		}
	}
	
	func indoorLocationManager(_ manager: IALocationManager, statusChanged status: IAStatus) {
		let statusNum = String(status.type.rawValue)
		statusText.text = "Status: " + statusNum
	}
}
