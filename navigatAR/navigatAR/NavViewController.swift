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

class NavViewController: UIViewController, ARSCNViewDelegate, UITableViewDataSource, UISearchBarDelegate {

	@IBOutlet weak var searchBlur: UIVisualEffectView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var sceneView: ARSCNView!

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

		// Create a new scene
//		let scene = SCNScene(named: "art.scnassets/ship.scn")!
//		let scene = SCNScene(named: "art.scnassets/arrow/Arrow.scn")!

		// Set the scene to the view
//		sceneView.scene = scene

//		addArrow(z: -1, eulerX: 1, eulerY: 0);

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
		configuration.planeDetection = [.horizontal]

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

	// MARK: - ARSCNViewDelegate

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		// Place content only for anchors found by plane detection.
		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

		// Create a SceneKit plane to visualize the plane anchor using its position and extent.
		let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
		let planeNode = SCNNode(geometry: plane)
		planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

		// `SCNPlane` is vertically oriented in its local coordinate space, so
		// rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
		planeNode.eulerAngles.x = -.pi / 2

		// Make the plane visualization semitransparent to clearly show real-world placement.
		planeNode.opacity = 0.25

		// Add the plane visualization to the ARKit-managed node so that it tracks
		// changes in the plane anchor as plane estimation continues.
		node.addChildNode(planeNode)
	}

	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		// Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
		guard let planeAnchor = anchor as?  ARPlaneAnchor,
			let planeNode = node.childNodes.first,
			let plane = planeNode.geometry as? SCNPlane
			else { return }

		// Plane estimation may shift the center of a plane relative to its anchor's transform.
		planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

		// Plane estimation may also extend planes, or remove one plane to merge its extent into another.
		plane.width = CGFloat(planeAnchor.extent.x)
		plane.height = CGFloat(planeAnchor.extent.z)
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

	func addArrow(x: Float = 0, y: Float = 0, z: Float = 0, eulerX: Float = 0, eulerY: Float = 0) {
//		guard let arrowScene = SCNScene(named: "art.scnassets/arrow/Arrow.dae") else { return }
		let arrowScene = SCNScene(named: "art.scnassets/arrow/Arrow.scn")!;
//		let arrowScene = SCNScene(named: "art.scnassets/ship.scn")!;
		print("Add arrow", arrowScene);
		let arrowNode = SCNNode()
		let arrowSceneChildNodes = arrowScene.rootNode.childNodes

		for childNode in arrowSceneChildNodes {
			arrowNode.addChildNode(childNode)
		}

//		for anchor in sceneView.session.currentFrame!.anchors {
//			print("anchor", anchor)
//		}

		arrowNode.position = SCNVector3(x, y, z)
//		carNode.position = SCNVector3(x, y, z)
		arrowNode.eulerAngles = SCNVector3(degreesToRadians(eulerX), degreesToRadians(eulerY), 0)
		arrowNode.scale = SCNVector3(0.5, 0.5, 0.5)
//		print("child nodes", sceneView.scene.rootNode.childNodes)
//		let debug = sceneView.scene;
//		print(sceneView)
		sceneView.scene.rootNode.addChildNode(arrowNode)
	}

}

func degreesToRadians(_ degrees: Float) -> Float {
	return degrees * (.pi / 180)
}

