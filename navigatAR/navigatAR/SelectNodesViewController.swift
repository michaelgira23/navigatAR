//
//  SelectNodesViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/18/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class SelectNodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var nodesTable: UITableView!
	
	var availableNodes: [Node] = []
	var selectedNodes: [Node] = []

	override func viewDidLoad() {
        super.viewDidLoad()
		self.getNodes()
		self.nodesTable.reloadData()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.nodesTable.dequeueReusableCell(withIdentifier: "availableNodes", for: indexPath) as UITableViewCell
		
		cell.textLabel?.text = self.availableNodes[indexPath.row].name
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.availableNodes.count
	}
	
	func getNodes() {
		let ref = Database.database().reference()
		ref.child("nodes").observe(.value, with: { (snapshot) in
			guard let value = snapshot.value else { return }
			
			do {
				let firebaseNodes = Array(try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value))
				
				for node in firebaseNodes {
					self.availableNodes.append(node.value)
				}
			}
			catch let error {
				print(error)
			}
			
			self.nodesTable.dataSource = self
			self.nodesTable.delegate = self
		})
	}
}
