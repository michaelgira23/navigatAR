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

class NavViewController: UIViewController, ARSCNViewDelegate, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet var sceneView: ARSCNView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Set search bar's delegate
//		otherSearchBar.delegate = self

		// Set the view's delegate
		sceneView.delegate = self

		// Show statistics such as fps and timing information
		sceneView.showsStatistics = false

		// Create a new scene
		let scene = SCNScene(named: "art.scnassets/ship.scn")!

		// Set the scene to the view
		sceneView.scene = scene
        self.searchBar.delegate = self;
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()

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

	/* Search Bar Handlers */
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		print("Search bar began editing");
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		print("Search bar stopped editing");
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder();
		print("Search bar cancel clicked");
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		print("Search bar search clicked");
	}

	// MARK: - ARSCNViewDelegate

	/*
	// Override to create and configure nodes for anchors added to the view's session.
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
	let node = SCNNode()

	return node
	}
	*/

	func session(_ session: ARSession, didFailWithError error: Error) {
		// Present an error message to the user

	}

	func sessionWasInterrupted(_ session: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay

	}

	func sessionInterruptionEnded(_ session: ARSession) {
		// Reset tracking and/or remove existing anchors if consistent tracking is required

	}

}

