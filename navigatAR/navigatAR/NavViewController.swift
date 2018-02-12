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
import FuzzyMatchingSwift

class NavViewController: UIViewController, ARSCNViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {

	@IBOutlet weak var searchBlur: UIVisualEffectView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var sceneView: ARSCNView!
	
    var data: [String] = [" , "]
    var filteredData: [String] = [" , "]

	override func viewDidLoad() {
		super.viewDidLoad()

		/* Search Setup */

		tableView.dataSource = self
		searchBar.delegate = self
        tableView.delegate = self

		/* AR Setup */

		// Set the view's delegate
		sceneView.delegate = self

		// Show statistics such as fps and timing information
		sceneView.showsStatistics = false

		// Create a new scene
		let scene = SCNScene(named: "art.scnassets/ship.scn")!

		// Set the scene to the view
		sceneView.scene = scene
        
        self.updateDBData()
        
        // delete the dummy element in the array
        self.data.remove(at: 0)
        self.filteredData.remove(at: 0)
        self.tableView.reloadData()
	}
    
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
                    self.data.append(node.name + "," + String(describing: node.type))
                    self.filteredData.append(node.name + "," + String(describing: node.type))
                }
            }
            catch let error {
                print(error)
            }
        })
        self.tableView.reloadData()
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

	/* Search Handlers */

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

	// MARK: - ARSCNViewDelegate

	func session(_ session: ARSession, didFailWithError error: Error) {
		// Present an error message to the user

	}

	func sessionWasInterrupted(_ session: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay

	}

	func sessionInterruptionEnded(_ session: ARSession) {
		// Reset tracking and/or remove existing anchors if consistent tracking is required

	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDestinationDetail") {
            if let destination = segue.destination as? DestinationSelectionController {
                destination.dest = sender as! String
            }
        }
    }

}
