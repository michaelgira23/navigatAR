//
//  NewEventViewController.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/17/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation
import Eureka
import FirebaseDatabase
import CodableFirebase

class NewEventViewController: FormViewController {
	
	var availableNodes: [String] = [];
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.updateDBData()
		
		form +++ Section("Event Information")
			<<< TextRow("eventname") { row in
				row.title = "Event Name"
				row.placeholder = "Enter Name here"
			}
			
			<<< TextRow("eventdescription") { row in
				row.title = "Enter Description"
				row.placeholder = "Enter Description Here"
			}
			
			+++ Section("Event Start Date")
			<<< DateRow("eventstartdate") { row in
				row.title = "Start Date"
				row.dateFormatter?.dateStyle = DateFormatter.Style.full
			}
			
			<<< TimeRow("eventstarttime") { row in
				row.title = "Start Time"
			}
			
			+++ Section("Event End Date")
			<<< DateRow("eventenddate") { row in
				row.title = "End Date"
				row.dateFormatter?.dateStyle = DateFormatter.Style.full
			}
			<<< TimeRow("eventendtime") { row in
				row.title = "End Time"
			}
			
			+++ SelectableSection<ListCheckRow<String>>("Pick a location", selectionType: .singleSelection(enableDeselection: true))
		
			+++ ButtonRow() { row in
				row.title = "Create"
				row.onCellSelection { row, cell in
					// now we create the event
					let newEvent: Event = Event(name: self.form.values()["eventname"] as! String, description: self.form.values()["eventdescription"] as! String, nodeId: "dummyfornow", start: "\(self.form.values()["eventstartdate"] )@\(self.form.values()["eventstarttime"])", end: "\(self.form.values()["eventenddate"])@\(self.form.values()["eventendtime"])") // TODO: get the selected location
					
					let ref = Database.database().reference()
					ref.child("events").childByAutoId().setValue(try! FirebaseEncoder().encode(newEvent))
				}
			}
		
		// let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
		
		for option in self.availableNodes {
			form.last! <<< ListCheckRow<String>(option){ listRow in
				listRow.title = option
				listRow.selectableValue = option
				listRow.value = nil
			}
		}
	}
	
	func updateDBData() {
		// Get nodes from db and load into the array
		let ref = Database.database().reference()
		print("Loading available nodes for db")
		ref.child("nodes").observe(.value, with: { snapshot in
			guard let value = snapshot.value else { return }
			
			do {
				let loc = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)
				
				for node in loc {
					self.availableNodes.append(String(describing: node.name))
					self.availableNodes.append("Some dummy data")
					print(String(describing: node.name))
				}
			}
			catch let error {
				print(error)
			}
		})
		
		for section in form.allSections {
			section.reload()
		}
		
		// TODO: figure out how to reload the section so that our data actually is visible
	}
}
