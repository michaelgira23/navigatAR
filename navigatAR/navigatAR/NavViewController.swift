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
import FuzzyMatchingSwift
import GameplayKit

class NavViewController: UIViewController, ARSCNViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, IALocationManagerDelegate {

	@IBOutlet weak var searchBlur: UIVisualEffectView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var sceneView: ARSCNView!

	let locationManager = IALocationManager.sharedInstance()

	var currentLocation: Location? = nil
	var cameraPosition = SCNVector3(0, 0, 0)
	var targets: [String] = [];

	var dbSnapshot: DataSnapshot? = nil
	var nodes: [FirebasePushKey: GKNodeWrapper] = [:]
	var nodesGraph: GKGraph? = nil

	var arNodes: [FirebasePushKey: SCNNode] = [:]

	var data: [String] = [" , "]
	var filteredData: [String] = [" , "]

	@IBAction func debugPress() {
		addArrow(z: -1, eulerX: 45, eulerY: 20);
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		/* Indoor Atlas Setup */

		locationManager.delegate = self

		/* AR Setup */

		// Set the view's delegate
		sceneView.delegate = self

		// Show statistics such as fps and timing information
		sceneView.showsStatistics = false

		sceneView.autoenablesDefaultLighting = true
		sceneView.automaticallyUpdatesLighting = true

		/* Navigation */

		Database.database().reference().observe(DataEventType.value, with: { snapshot in
			guard let (nodes, graph) = populateGraph(rootSnapshot: snapshot) else { print("unable to get graph"); return }
			self.dbSnapshot = snapshot
			self.nodes = nodes
			self.nodesGraph = graph

			self.targets = [
				"-L5VwfdJwyl85ftvhGuR",
				"-L5W6_wCzliQ5q-VdWvi",
				"-L5W6wlziHejka5f8utU"
			]

		})

		/* Search Setup */

		tableView.dataSource = self
		searchBar.delegate = self
		tableView.delegate = self

		self.updateDBData()

		// Delete the dummy element in the array
		self.data.remove(at: 0)
		self.filteredData.remove(at: 0)
		self.tableView.reloadData()
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

	func updateDBData() {
		// Get nodes from db and load into the array
		let ref = Database.database().reference()
		ref.child("nodes").observe(.value, with: { snapshot in
			guard let value = snapshot.value else { return }

			do {
				let loc = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)
				self.data = [] // clear the data out so appending can work properly
				self.filteredData = []

				for node in loc {
					self.data.append(node.name + "," + String(describing: node.type) + "," + String(describing: node.building))
					self.filteredData.append(node.name + "," + String(describing: node.type) + "," + String(describing: node.building))
				}
			}
			catch let error {
				print(error)
			}
		})
		self.tableView.reloadData()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as UITableViewCell

		var parsed = self.filteredData[indexPath.row].split(separator: ",")

		cell.textLabel?.text = String(describing: parsed[0])
		cell.detailTextLabel?.text = String(describing: parsed[1])
		return cell
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredData.count
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "showDestinationDetail", sender: self.filteredData[indexPath.row]);
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if (searchText.isEmpty) {
			self.filteredData = self.data
		}
		else {
			self.filteredData = self.filteredData.sortedByFuzzyMatchPattern(searchText)
		}
		tableView.reloadData()
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.updateDBData()
		self.searchBar.showsCancelButton = true
		self.searchBlur.fadeIn()
		self.tableView.fadeIn()
		self.tableView.reloadData()
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = false
		searchBar.resignFirstResponder()
		self.tableView.fadeOut()
		self.searchBlur.fadeOut()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "showDestinationDetail") {
			if let destination = segue.destination as? DestinationSelectionController {
				destination.dest = sender as! String
			}
		}
	}

	// MARK: - IndoorAtlas delegates

	func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {
		print("pos update")
		clearNodes()
		let location = Location.init(fromIALocation: locations.last as! IALocation)
		currentLocation = location
		for target in targets {
			let (lat, long, alt) = location.distanceDeltas(with: nodes[target]!.wrappedNode.position)
			arNodes[target] = addArrow(x: long, y: alt, z: -lat)
		}
		navigate(from: "-L5W6_wCzliQ5q-VdWvi", to: "-L5W6wlziHejka5f8utU")
	}

	func indoorLocationManager(_ manager: IALocationManager, statusChanged status: IAStatus) {
		let statusNum = String(status.type.rawValue)
		print("Status: " + statusNum)
	}

	// MARK: - ARSCNViewDelegate

	func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
		guard let pointOfView = sceneView.pointOfView else { return }
		let transform = pointOfView.transform
		cameraPosition = SCNVector3(transform.m41, transform.m42, transform.m43)
//		print("Camera postiion", cameraPosition)
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

	/* Navigation */

	func navigate(from: String, to: String) {
		let fromArNode: SCNNode = arNodes[from]!
		let toArNode: SCNNode = arNodes[to]!
		addLine(from: fromArNode, to: toArNode)
	}

//	func closestNode() -> Node {
//		for node of nodes {
//
//		}
//	}

	/* Augmented Reality */

	func addArrow(x: Double = 0, y: Double = 0, z: Double = 0, eulerX: Double = 0, eulerY: Double = 0) -> SCNNode? {

//		print("Add arrow", x, y, z, eulerX, eulerY);

		guard let arrowScene = SCNScene(named: "art.scnassets/arrow/Arrow.scn") else { return nil }
		let arrowNode = SCNNode()
		let arrowSceneChildNodes = arrowScene.rootNode.childNodes

		for childNode in arrowSceneChildNodes {
			arrowNode.addChildNode(childNode)
		}

		arrowNode.position = SCNVector3(x + Double(cameraPosition.x), y + Double(cameraPosition.y), z + Double(cameraPosition.z))
//		arrowNode.position = SCNVector3(x, y, z)
		arrowNode.eulerAngles = SCNVector3(degreesToRadians(eulerX), degreesToRadians(eulerY), 0)
		arrowNode.scale = SCNVector3(0.5, 0.5, 0.5)
		sceneView.scene.rootNode.addChildNode(arrowNode)
		return arrowNode
	}

	func addLine(from: SCNNode, to: SCNNode) {
		let lineGeometry = lineFrom(fromVector: from.position, toVector: to.position)
		let lineNode = SCNNode(geometry: lineGeometry)
		lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
		sceneView.scene.rootNode.addChildNode(lineNode)
	}

	func lineFrom(fromVector: SCNVector3, toVector: SCNVector3) -> SCNGeometry {
		let indices: [Int32] = [0, 1]
		let source = SCNGeometrySource(vertices: [fromVector, toVector])
		let element = SCNGeometryElement(indices: indices, primitiveType: .line)
		return SCNGeometry(sources: [source], elements: [element])
	}

	func clearNodes() {
		let sceneChildNodes = sceneView.scene.rootNode.childNodes

		for childNode in sceneChildNodes {
			childNode.removeFromParentNode()
		}
	}

}

