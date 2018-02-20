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

class SelectNodesViewController: UIViewControllerWithBuilding, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var nodesTable: UITableView!
	
	var availableNodes: [(FirebasePushKey, Node)] = []
	var selectedNodes: [(FirebasePushKey, Node)] = []

	override func viewDidLoad() {
        super.viewDidLoad()
		self.nodesTable.dataSource = self
		self.nodesTable.delegate = self
		self.getNodes()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.nodesTable.dequeueReusableCell(withIdentifier: "availableNodes", for: indexPath) as UITableViewCell
		
		cell.textLabel?.text = self.availableNodes[indexPath.row].1.name
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.availableNodes.count
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath :IndexPath) {
		self.selectedNodes.append(self.availableNodes[indexPath.row])
	}
	
	func getNodes() {
		let ref = Database.database().reference()
		ref.child("nodes").queryOrdered(byChild: "building").queryEqual(toValue: forBuilding.0).observe(.value, with: { (snapshot) in
			guard snapshot.exists(), let value = snapshot.value else { return }
			
			do {
				let firebaseNodes = Array(try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value))
				
				for node in firebaseNodes {
					self.availableNodes.append((node.key, node.value))
				}

				self.nodesTable.reloadData()
			}
			catch let error {
				print(error)
			}
		})
	}
}
