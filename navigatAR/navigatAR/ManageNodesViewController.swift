//
//  ManageNodesViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class ManageNodesViewController: UIViewControllerWithBuilding, UITableViewDataSource {

	@IBOutlet weak var nodeTable: UITableView!
	@IBAction func unwindToManageNodes(unwindSegue: UIStoryboardSegue) { }
	
	var nodes: [Node] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view, typically from a nib.
		
		navigationItem.prompt = forBuilding.1.name
		
		nodeTable.dataSource = self
		
		let ref = Database.database().reference()
		
		// Continuously update `nodes` from database
		ref.child("nodes").queryOrdered(byChild: "building").queryEqual(toValue: forBuilding.0).observe(.value, with: { snapshot in
			guard snapshot.exists(), let value = snapshot.value else { return }
			
			do {
				//guard let currentBuilding = Building.current(root: snapshot) else { print(""); return }
				
				self.nodes = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)//.filter({ $0.building == currentBuilding.id })
				self.nodeTable.reloadData()
			} catch let error {
				print(error) // TODO: properly handle error
			}
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: TableView functions

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return nodes.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = nodeTable.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as UITableViewCell
		let node = nodes[indexPath.row]

		cell.textLabel?.text = node.name
		cell.detailTextLabel?.text = String(describing: node.type)

		return cell
	}
}
