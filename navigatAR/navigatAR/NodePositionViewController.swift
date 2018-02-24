//
//  NodePositionViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import IndoorAtlas

class NodePositionViewController: UIViewController, IALocationManagerDelegate, LocationDelegate {

	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

	let locationManager = IALocationManager.sharedInstance()

	var currentLocation: Location?

	@IBOutlet weak var calibrationText: UILabel!
	@IBOutlet weak var accuracyText: UILabel!
	@IBOutlet weak var getPositionButton: UIButton!

	@IBAction func getPosition() {
		self.gotPosition()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		setQualityText(calibrationQuality: locationManager.calibration)
		if (appDelegate.currentLocation != nil) {
			setLocation(location: appDelegate.currentLocation!)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK - Custom location delegate

	func locationUpdate(currentLocation: Location?, kalmanLocation: CLLocation?) {
		if (currentLocation != nil) {
			setLocation(location: currentLocation!);
		}
	}

	func indoorLocationManager(_ manager: IALocationManager, calibrationQualityChanged quality: ia_calibration) {
		setQualityText(calibrationQuality: quality)
	}

	func gotPosition() {
		print("Got gotted");
//		performSegue(withIdentifier: "unwindToUpsertNodesWithUnwindSegue", sender: self)
		_ = navigationController?.popViewController(animated: true)
	}

	//	Pass position data back to the creation page
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let UpsertNodeViewController = segue.destination as? UpsertNodeViewController {
			UpsertNodeViewController.locationData = currentLocation
		}
	}

	func setLocation(location l: Location) {
		currentLocation = l
		let ha = String(round(currentLocation!.horizontalAccuracy))
		let va = String(round(currentLocation!.verticalAccuracy))
		accuracyText.text = "Accuracy: (" + ha + ", " + va + ")"
	}

	func setQualityText(calibrationQuality quality: ia_calibration) {
		var qualityText: String
		switch quality {
		case ia_calibration.iaCalibrationExcellent:
			qualityText = "Excellent"
		case ia_calibration.iaCalibrationGood:
			qualityText = "Good"
		case ia_calibration.iaCalibrationPoor:
			qualityText = "Poor"
		}
		calibrationText.text = "Calibration: " + qualityText
	}
}
