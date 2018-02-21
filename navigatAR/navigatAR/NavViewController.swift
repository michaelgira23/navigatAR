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

class NavViewController: UIViewController, ARSCNViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, IALocationManagerDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var searchBlur: UIVisualEffectView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var direction: UILabel!
	@IBOutlet var sceneView: ARSCNView!

	let locationManager = IALocationManager.sharedInstance()
	let directionManager: CLLocationManager = {
		$0.requestWhenInUseAuthorization()
		$0.startUpdatingHeading()
		return $0
	}(CLLocationManager())

	var currentLocation: Location? = nil
	var cameraPosition = SCNVector3(0, 0, 0)

	var dbSnapshot: DataSnapshot? = nil
	var nodes: [FirebasePushKey: GKNodeWrapper] = [:]
	var nodesGraph: GKGraph? = nil

	var arNodes: [FirebasePushKey: SCNNode] = [:]

	// Camera position when they first press "navigate"
	var navStartPosition: SCNVector3? = nil
	// If nil, just show surrounding points. We aren't navigating anywhere
	var navigateTo: FirebasePushKey? = nil
//	var navigateTo: FirebasePushKey? = "-L5W6wlziHejka5f8utU" // Debug only!
	// Closest node to the user upon initial navigation. This is where we consider the path "starts"
	var navigateFrom: FirebasePushKey? = nil

	var data: [String] = [" , "]
	var filteredData: [String] = [" , "]

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

			// Check if we're navigating anywhere
			if (self.navigateTo != nil) {
				self.navigateFrom = self.closestNode()
				self.navStartPosition = self.cameraPosition
				self.navStartPosition!.y -= 1
			}
			self.redraw()

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
		
		self.directionManager.delegate = self
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
	
	/* Compass heading */
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		self.direction.text = self.determineCompassDirection(currentHeading: newHeading)
	}
	
	func determineCompassDirection(currentHeading heading: CLHeading) -> String {
		let angle = heading.magneticHeading
		
		// N - E
		if (angle > 0 && angle < 30) {
			return "N"
		}
		else if (angle > 30 && angle < 60) {
			return "NE"
		}
		else if (angle > 60 && angle < 90) {
			return "E"
		}
		// E - S
		if (angle > 90 && angle < 120) {
			return "E"
		}
		else if (angle > 120 && angle < 150) {
			return "SE"
		}
		else if (angle > 150 && angle < 180) {
			return "S"
		}
		// S - W
		if (angle > 180 && angle < 210) {
			return "S"
		}
		else if (angle > 210 && angle < 240) {
			return "SW"
		}
		else if (angle > 240 && angle < 270) {
			return "W"
		}
		// W - N
		if (angle > 270 && angle < 300) {
			return "W"
		}
		else if (angle > 300 && angle < 330) {
			return "NW"
		}
		else if (angle > 330 && angle < 360) {
			return "N"
		}
		else {
			return "D"
		}
	}

	/* Search Handlers */

	func updateDBData() {
		// Get nodes from db and load into the array
		let ref = Database.database().reference()
		ref.child("nodes").observe(.value, with: { snapshot in
			guard let value = snapshot.value else { return }

			do {
				let firebaseNodes = Array(try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value))
				self.data = [] // clear the data out so appending can work properly
				self.filteredData = []

                for node in firebaseNodes {
                    let str = "\(node.key),\(node.value.name),\(node.value.type),\(node.value.building),\(node.value.tags?.map(tagPairToString).joined(separator: ",") ?? "")"
                    self.data.append(str)
                    self.filteredData.append(str)
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

		cell.textLabel?.text = String(describing: parsed[1])
		cell.detailTextLabel?.text = String(describing: parsed[2])
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
		self.direction.fadeIn()
		self.tableView.reloadData()
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = false
		searchBar.resignFirstResponder()
		self.tableView.fadeOut()
		self.searchBlur.fadeOut()
		self.direction.fadeOut()
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
		currentLocation = Location(fromIALocation: locations.last as! IALocation)
		redraw()
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

	// Draw lines in AR according to pathfinding path
	func navigate(from inputtedFrom: FirebasePushKey? = nil, to: FirebasePushKey?) {
		if (arNodes.count == 0 || nodesGraph == nil || to == nil) { return }
		var from: FirebasePushKey? = nil
		if (inputtedFrom == nil) {
			from = closestNode()
		} else {
			from = inputtedFrom
		}
		if (from == nil) {
			return
		}

		let fromGraphNode: GKGraphNode = nodes[from!]!
		let toGraphNode: GKGraphNode = nodes[to!]!

		// Actual pathfinding algorithm
		let path = nodesGraph!.findPath(from: fromGraphNode, to: toGraphNode)

		if (path.count == 0) {
			// Do something if there's no pathway to available point
		}

		var firstNode: FirebasePushKey? = nil
		var lastNode: FirebasePushKey? = nil
		for pathNode in path {
			let pushKey = nodes.key(forValue: pathNode as! GKNodeWrapper)!

			if (firstNode == nil) {
				firstNode = pushKey
			}

			if (lastNode != nil) {
				_ = addLine(from: arNodes[lastNode!]!.position, to: arNodes[pushKey]!.position)
				arNodes[lastNode!]!.look(at: arNodes[pushKey]!.position)
			}

			lastNode = pushKey
		}

		arNodes[lastNode!] = addDestination(node: arNodes[lastNode!]!)

		if (navStartPosition != nil && firstNode != nil) {
			_ = addLine(from: navStartPosition!, to: arNodes[firstNode!]!.position)
		}
	}

	func closestNode(from: Location? = nil) -> FirebasePushKey? {
		var measureFrom: Location? = from
		if from == nil {
			if currentLocation == nil {
				return nil
			} else {
				measureFrom = currentLocation
			}
		}
		var closestDistance: Double? = nil
		var closestNode: FirebasePushKey? = nil

		for node in nodes {
			let distance = measureFrom!.distanceTo(node.value.wrappedNode.position)
			if (closestDistance == nil || distance < closestDistance!) {
				closestDistance = distance
				closestNode = node.key
			}
		}

		return closestNode
	}

	/* Augmented Reality */

	// Redraw all of the nodes and shiz that should be shown.
	// This is called upon initial startup and location update
	func redraw() {
		// We can't draw anything if we don't know location
		if (currentLocation == nil) { return }
		clearNodes()
		for node in nodes {
			let (lat, long, alt) = currentLocation!.distanceDeltas(with: node.value.wrappedNode.position)
			arNodes[node.key] = addArrow(x: long, y: alt, z: -lat)
		}
		if (navigateTo != nil) {
			navigate(from: navigateFrom, to: navigateTo)
		}
	}

	func addArrow(x: Double = 0, y: Double = 0, z: Double = 0, eulerX: Double = 0, eulerY: Double = 0) -> SCNNode? {

//		print("Add arrow", x, y, z, eulerX, eulerY);

		guard let arrowScene = SCNScene(named: "art.scnassets/arrow/Arrow.scn") else { return nil }
		let arrowNode = SCNNode()
		let arrowSceneChildNodes = arrowScene.rootNode.childNodes

		for childNode in arrowSceneChildNodes {
			arrowNode.addChildNode(childNode)
		}

		arrowNode.position = SCNVector3(x + Double(cameraPosition.x), y + Double(cameraPosition.y), z + Double(cameraPosition.z))
		arrowNode.eulerAngles = SCNVector3(degreesToRadians(eulerX), degreesToRadians(eulerY), 0)
		arrowNode.scale = SCNVector3(0.5, 0.5, 0.5)
		sceneView.scene.rootNode.addChildNode(arrowNode)
		return arrowNode
	}

	func addLine(from: SCNVector3, to: SCNVector3) -> SCNNode? {
		guard let lineScene = SCNScene(named: "art.scnassets/Line.scn") else { return nil }

		let lineNode = SCNNode()
		let lineSceneChildNodes = lineScene.rootNode.childNodes

		for childNode in lineSceneChildNodes {
			lineNode.addChildNode(childNode)
		}

		let distance = from.distance(vector: to)
		lineNode.position = from
		lineNode.scale = SCNVector3(1, 1, distance)
		lineNode.look(at: to)

		sceneView.scene.rootNode.addChildNode(lineNode)
		return lineNode
	}

	func addDestination(node: SCNNode) -> SCNNode? {
		guard let destinationScene = SCNScene(named: "art.scnassets/Destination.scn") else { return nil }

		let destinationNode = SCNNode()
		let destinationSceneChildNodes = destinationScene.rootNode.childNodes

		for childNode in destinationSceneChildNodes {
			destinationNode.addChildNode(childNode)
		}

		destinationNode.position = node.position
		destinationNode.look(at: cameraPosition)
		sceneView.scene.rootNode.addChildNode(destinationNode)

		node.removeFromParentNode()
		return destinationNode
	}

	func clearNodes() {
		let sceneChildNodes = sceneView.scene.rootNode.childNodes

		for childNode in sceneChildNodes {
			childNode.removeFromParentNode()
		}
	}

}

