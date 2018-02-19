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
	
	var availableNodes: [String] = ["dummyData"]

	override func viewDidLoad() {
        super.viewDidLoad()
		self.nodesTable.dataSource = self
		self.nodesTable.delegate = self
		self.nodesTable.reloadData()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.nodesTable.dequeueReusableCell(withIdentifier: "availableNodes", for: indexPath) as UITableViewCell
		
		cell.textLabel?.text = self.availableNodes[indexPath.row]
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.availableNodes.count
	}
}
