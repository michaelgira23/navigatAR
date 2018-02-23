//
//  EventInformationViewController.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/22/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class EventInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	// "_event,\(event.name),\(event.description),\(event.start.timeIntervalSinceReferenceDate),\(event.end.timeIntervalSinceReferenceDate),\(event.locations.joined(separator: ","))"
	var eventData: String = ""
	var eventNodes: [(FirebasePushKey, Node)] = []
	
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var desc: UILabel!
	@IBOutlet weak var startTime: UILabel!
	@IBOutlet weak var endTime: UILabel!
	
	@IBOutlet weak var nodesTable: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let splitData = eventData.split(separator: ",").map { String(describing: $0) } // Convert from Substring to String
		
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		
		name.text = "Name: " + splitData[1]
		desc.text = "Description: " + splitData[2]
		startTime.text = "Start Time: " + formatter.string(from: Date(timeIntervalSinceReferenceDate: Double(splitData[3])!))
		endTime.text = "End Time: " + formatter.string(from: Date(timeIntervalSinceReferenceDate: Double(splitData[4])!))
		
		// Table setup
		nodesTable.dataSource = self
		nodesTable.delegate = self
		
		// Database setup
		Database.database().reference().child("nodes").observe(.value, with: { snapshot in
			guard snapshot.exists(), let nodesValue = snapshot.value else { return }
			
			let allNodes = try! FirebaseDecoder().decode([FirebasePushKey: Node].self, from: nodesValue)
			self.eventNodes = Array(splitData.dropFirst(5)).map { ($0, allNodes[$0]!) }
			
			self.nodesTable.reloadData()
		})
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showNodeDetail" {
			if let destination = segue.destination as? DestinationSelectionController {
				destination.dest = sender as! String
			}
		}
	}
	
	// MARK: Table view data source methods
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return eventNodes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = nodesTable.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath) as UITableViewCell
		let (_, node) = eventNodes[indexPath.row]
		
		cell.textLabel?.text = node.name
		cell.detailTextLabel?.text = String(describing: node.type)
		
		return cell
	}
	
	// MARK: Table view delegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let (pushKey, node) = eventNodes[indexPath.row]
		performSegue(withIdentifier: "showNodeDetail", sender: "\(pushKey),\(node.name),\(node.type),\(node.building),\(node.tags?.map(tagPairToString).joined(separator: ",") ?? "")")
	}
}
