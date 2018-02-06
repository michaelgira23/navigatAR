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

class ManageNodesViewController: UIViewController {
	
	@IBOutlet weak var nodeTable: UITableView!
	@IBAction func unwindToManageNodes(unwindSegue: UIStoryboardSegue) { }
	
	var nodes: [Node] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		nodeTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		nodeTable.delegate = self
		nodeTable.dataSource = self
		
		
		let ref = Database.database().reference()
		
		// Continuously update `nodes` from database
		ref.child("nodes").observe(.value, with: { snapshot in
			guard let value = snapshot.value else { return }
			
			do {
				self.nodes = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)
				print(self.nodes)
			} catch let error {
				print(error) // properly handle error
			}
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

extension ManageNodesViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return nodes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print(nodes)
		let cell: UITableViewCell = nodeTable.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
		cell.textLabel?.text = nodes[indexPath.row].name
		
		return cell
	}
}
