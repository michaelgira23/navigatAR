//
//  EventInformationViewController.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/22/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit

class EventInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var eventData: String = ""
	var eventNodes: [Node] = []
	
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var desc: UILabel!
	@IBOutlet weak var startTime: UILabel!
	@IBOutlet weak var endTime: UILabel!
	
	@IBOutlet weak var nodesTable: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		nodesTable.dataSource = self
		nodesTable.delegate = self
		
		nodesTable.reloadData()
	}
	
	// MARK: Table view data source methods
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		<#code#>
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		<#code#>
	}
	
	// MARK: Table view delegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		<#code#>
	}
}
