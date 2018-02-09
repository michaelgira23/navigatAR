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

class ManageNodesViewController: UIViewController, UITableViewDataSource {
	
	@IBOutlet weak var loadButtonOutlet: UIButton!
	@IBOutlet weak var nodeTable: UITableView!
	@IBAction func unwindToManageNodes(unwindSegue: UIStoryboardSegue) { }
	
	var nodes: [Node] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view, typically from a nib.
		
		nodeTable.dataSource = self
		
		let ref = Database.database().reference()
		
		// Continuously update `nodes` from database
		ref.observe(.value, with: { snapshot in
			guard let value = snapshot.childSnapshot(forPath: "nodes").value else { return }
			
			do {
				guard let currentBuilding = Building.current(root: snapshot) else { print(""); return }
				guard let buildingId = currentBuilding.id else { print("id is nil wtf"); return }
				
				self.nodes = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values).filter({ $0.building == buildingId })
			} catch let error {
				print(error) // TODO: properly handle error
			}
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func loadButtonHandler(_ sender: UIButton) {
		print("ayyuh")
		nodeTable.reloadData()
	}

	// MARK: TableView functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return nodes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print(nodes)
		let cell: UITableViewCell = nodeTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
		cell.textLabel?.text = nodes[indexPath.row].name
		
		return cell
	}
}
