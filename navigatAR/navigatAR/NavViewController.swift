//
//  NavViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/1/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Firebase
import CodableFirebase
import IndoorAtlas

// Coords outside Belltower Nook
let targetLat = 38.6599490906118
let targetLong = -90.3967783079035
let targetAlt = 3.72000002861023

class NavViewController: UIViewController, ARSCNViewDelegate, UITableViewDataSource, UISearchBarDelegate, IALocationManagerDelegate {

	@IBOutlet weak var searchBlur: UIVisualEffectView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var sceneView: ARSCNView!

	let locationManager = IALocationManager.sharedInstance()

	var cameraPosition = SCNVector3(0, 0, 0)

	var bestHorizontalLocationAccuracy: Double = Double(INT_MAX)
	var bestVerticalLocationAccuracy: Double = Double(INT_MAX)
	var currentLat: Double = 0
	var currentLong: Double = 0
	var currentAlt: Double = 0

	/*let data = ["New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX",
				"Philadelphia, PA", "Phoenix, AZ", "San Diego, CA", "San Antonio, TX",
				"Dallas, TX", "Detroit, MI", "San Jose, CA", "Indianapolis, IN",
				"Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Austin, TX",
				"Memphis, TN", "Baltimore, MD", "Charlotte, ND", "Fort Worth, TX"]*/
    
    var data: [String] = []

	var filteredData: [String]!

	@IBAction func debugPress() {
		addArrow(z: -1, eulerX: 45, eulerY: 20);
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		/* Indoor Atlas Setup */
		locationManager.delegate = self

		/* Search Setup */

		tableView.dataSource = self
		searchBar.delegate = self
		filteredData = data

		/* AR Setup */

		// Set the view's delegate
		sceneView.delegate = self

		// Show statistics such as fps and timing information
		sceneView.showsStatistics = false

		sceneView.autoenablesDefaultLighting = true
		sceneView.automaticallyUpdatesLighting = true

        // Get nodes from db and load into the array
        let ref = Database.database().reference()
        
        ref.child("nodes").observe(.value, with: { snapshot in
            guard let value = snapshot.value else { return }
            
            do {
                let loc = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)
                
                for node in loc {
                    self.data.append(node.name + "," + node.building)
                }
            }
            catch let error {
                print(error)
            }
        })
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		configuration.worldAlignment = .gravityAndHeading
//		configuration.planeDetection = [.horizontal]

		// Detect
		print("ARKit supported?", ARWorldTrackingConfiguration.isSupported)

		// Run the view's session
		sceneView.session.run(configuration)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Pause the view's session
		sceneView.session.pause()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}

	/* Search Handlers */

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as UITableViewCell
        var parsed = filteredData[indexPath.row].split(separator: ",")
        
        cell.textLabel?.text = String(describing: parsed[0])
        cell.detailTextLabel?.text = String(describing: parsed[1])
        //cell.!detailTextLabel.text = "hello"
		return cell
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredData.count
	}

	// This method updates filteredData based on the text in the Search Box
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// When there is no text, filteredData is the same as the original data
		// When user has entered text into the search box
		// Use the filter method to iterate over all items in the data array
		// For each item, return true if the item should be included and false if the
		// item should NOT be included
		filteredData = searchText.isEmpty ? data : data.filter { (item: String) -> Bool in
			// If dataItem matches the searchText, return true to include it
			return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
		}

		tableView.reloadData()
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.searchBar.showsCancelButton = true
		self.searchBlur.fadeIn()
		self.tableView.fadeIn()
        self.tableView.reloadData()
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = false
//		searchBar.text = ""
		searchBar.resignFirstResponder()
		self.tableView.fadeOut()
		self.searchBlur.fadeOut()
	}

	// MARK: - IndoorAtlas delegates

	func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {

		let l = locations.last as! IALocation

		var positionChanged = false

		if let horizontalAccuracy = l.location?.horizontalAccuracy, let newLocation = l.location?.coordinate {
//			if horizontalAccuracy.isLessThanOrEqualTo(bestHorizontalLocationAccuracy) {
				bestHorizontalLocationAccuracy = horizontalAccuracy.magnitude
				self.currentLat = newLocation.latitude
				self.currentLong = newLocation.longitude
				positionChanged = true
//			}
		}

		if let verticalAccuracy = l.location?.verticalAccuracy, let altitude = l.location?.altitude {
//			if verticalAccuracy.isLessThanOrEqualTo(bestVerticalLocationAccuracy) {
//				bestVerticalLocationAccuracy = verticalAccuracy.magnitude
				self.currentAlt = altitude
//				positionChanged = true
//			}
		}

//		if positionChanged {
			print("Position changed to coordinate: \(currentLat) \(currentLong) \(currentAlt) with accuracy \(bestHorizontalLocationAccuracy) \(bestVerticalLocationAccuracy)")

			let latDiff = currentLat - targetLat
			let longDiff = currentLong - targetLong
			let altDiff = currentAlt - targetAlt

			print("DIFF", latDiff, longDiff, altDiff)

			// Calculate offset (in meters)
			// https://gis.stackexchange.com/a/2964

			let averageLat = (currentLat + targetLat) / 2

			let longOffset = longDiff * 111111
			let latOffset = latDiff * 111111 * cos(degreesToRadians(averageLat))

			// @TODO - Take into account camera's current position because (0, 0, 0) is when AR session is first started

			clearArrows()
			addArrow(x: latOffset, y: longOffset, z: altDiff)

//		}
	}

	func indoorLocationManager(_ manager: IALocationManager, statusChanged status: IAStatus) {
		let statusNum = String(status.type.rawValue)
		print("Status: " + statusNum)
	}

	// MARK: - ARSCNViewDelegate

//	func session(_ session: ARSession, didUpdate frame: ARFrame) {
//		let cameraTransform = frame.camera.transform.columns
//		cameraX = cameraTransform.0
//		cameraY = cameraTransform.1
//		cameraZ = cameraTransform.2
//		print("camera transform", cameraTransform.0, cameraTransform.1, cameraTransform.2, cameraTransform.3)
//	}

	func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
		guard let pointOfView = sceneView.pointOfView else { return }
		let transform = pointOfView.transform
		cameraPosition = SCNVector3(transform.m41, transform.m42, transform.m43)
	}

	func session(_ session: ARSession, didFailWithError error: Error) {
		// Present an error message to the user

	}

	func sessionWasInterrupted(_ session: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay

	}

	func sessionInterruptionEnded(_ session: ARSession) {
		// Reset tracking and/or remove existing anchors if consistent tracking is required

	}

	/* Augmented Reality */

	func addArrow(x: Double = 0, y: Double = 0, z: Double = 0, eulerX: Double = 0, eulerY: Double = 0) {

		print("Add arrow", x, y, z, eulerX, eulerY);

		guard let arrowScene = SCNScene(named: "art.scnassets/arrow/Arrow.scn") else { return }
		let arrowNode = SCNNode()
		let arrowSceneChildNodes = arrowScene.rootNode.childNodes

		for childNode in arrowSceneChildNodes {
			arrowNode.addChildNode(childNode)
		}

		arrowNode.position = SCNVector3(x, y, z)
		arrowNode.eulerAngles = SCNVector3(degreesToRadians(eulerX), degreesToRadians(eulerY), 0)
		arrowNode.scale = SCNVector3(0.5, 0.5, 0.5)
		sceneView.scene.rootNode.addChildNode(arrowNode)
	}

	func clearArrows() {
		let sceneChildNodes = sceneView.scene.rootNode.childNodes

		for childNode in sceneChildNodes {
			childNode.removeFromParentNode()
		}
	}

}

func degreesToRadians(_ degrees: Double) -> Double {
	return degrees * (.pi / 180)
}

