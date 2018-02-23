//
//  NewEventViewController.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/17/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Eureka
import Firebase
import CodableFirebase

class NewEventViewController: FormViewControllerWithBuilding {
	
	var availableNodes: [String] = []
	var selectedNodes: FirebaseArray<FirebasePushKey> = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.updateDBData()
		
		form +++ Section("Event Information")
			<<< TextRow("eventname") {
				$0.title = "Name"
//				row.placeholder = "Name"
				$0.value = "navigatAR Presentation"
			}
			
			<<< TextRow("eventdescription") {
				$0.title = "Description"
//				row.placeholder = "Description"
				$0.value = "Where we show off our super cool app"
			}
			
			+++ Section("Event Time")
			<<< DateTimeRow("eventstarttime") {
				$0.title = "Start Time"
				$0.dateFormatter?.dateStyle = DateFormatter.Style.full
				$0.value = Date(timeIntervalSince1970: 1519501500)
			}
			<<< DateTimeRow("eventendtime") {
				$0.title = "End Time"
				$0.dateFormatter?.dateStyle = DateFormatter.Style.full
				$0.value = Date(timeIntervalSince1970: 1519504200)
			}
			
			+++ ButtonRow("selectLocation") { row in
				row.title = "Select Locations (" + String(selectedNodes.count) + ")"
				row.onCellSelection { row, cell in
					self.performSegue(withIdentifier: "showSelectNodesForEvent", sender: nil)
					// TODO: store data in selectedNodes
				}
			}
		
			+++ ButtonRow() {
				$0.title = "Create Event"
				$0.onCellSelection { row, cell in
					let formValues = self.form.values()
					
					if formValues["eventname"] == nil || formValues["eventdescription"] == nil || self.selectedNodes.count == 0 {
						return
					}
					else {
						let newEvent = Event(
							name: formValues["eventname"] as! String,
							description: formValues["eventdescription"] as! String,
							locations: self.selectedNodes,
							start: formValues["eventstarttime"] as! Date,
							end: formValues["eventendtime"] as! Date
						)
						
						print("Creating event: \(newEvent)")
						
						let ref = Database.database().reference()
						ref.child("events").childByAutoId().setValue(try! FirebaseEncoder().encode(newEvent))
					}
					
					self.performSegue(withIdentifier: "unwindFromNewEventController", sender: self)
				}
		}
	}
	
	@IBAction func unwindBackFromSelectionsSegue(_ sender: UIStoryboardSegue) {
		print("Unwinding back to create event")
		
		guard let selections = sender.source as? SelectNodesViewController else { return }
	
		let keyArray = FirebaseArray(values: selections.selectedNodes.map({ (key, node) in
			return key
		}))
		selectedNodes = keyArray
		let selectLocationCell = form.rowBy(tag: "selectLocation")!
		selectLocationCell.title = "Select Locations (" + String(selectedNodes.count) + ")"
		selectLocationCell.reload()
	}
	
	func updateDBData() {
		// Get nodes from db and load into the array
		let ref = Database.database().reference()
		print("Loading available nodes for db")
		ref.child("nodes").observe(.value, with: { snapshot in
			guard snapshot.exists() else { return }
			let value = snapshot.value!
			
			do {
				let loc = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)
				self.availableNodes = loc.map { node in node.name }
			}
			catch let error {
				print(error)
			}
		})
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.availableNodes = []
	}
}

