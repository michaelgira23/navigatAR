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
	
	var availableNodes: [String] = []
	var nodeCells: SelectableSection<ListCheckRow<String>>!
	
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
			
			+++ ButtonRow() { row in
				row.title = "Create"
				row.onCellSelection { row, cell in
					// now we create the event
					let name: String = String(describing: self.form.values()["eventname"])
					let description: String = String(describing: self.form.values()["eventdescription"])
					
					let startDate: String = String(describing: self.form.values()["eventstartdata"])
					let startTime: String = String(describing: self.form.values()["eventstarttime"])
					
					let endDate: String = String(describing: self.form.values()["eventenddata"])
					let endTime: String = String(describing: self.form.values()["eventenddata"])
					
					let nodeId: String = "dummy id" // TODO: put in the id
					
					let newEvent: Event = Event(name: name, description: description, nodeId: nodeId, start: "\(startDate)@\(startTime)", end: "\(endDate)@\(endTime)")
					
					let ref = Database.database().reference()
					ref.child("events").childByAutoId().setValue(try! FirebaseEncoder().encode(newEvent))
				}
			}
			
			+++ Section("Pick a location")
		
		self.nodeCells = SelectableSection<ListCheckRow<String>>("Pick a location", selectionType: .singleSelection(enableDeselection: true))
		
		self.nodeCells.onSelectSelectableRow = { (cell, cellRow) in
			print("A thing has been clicked")
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
				}
				
				// print out the array before loading
				print("Available nodes array")
				
				// TODO: figure out how to reload the section so that our data actually is visible
				for option in self.availableNodes {
					self.form.last! <<< ListCheckRow<String>(option){ listRow in
						listRow.title = option
						listRow.selectableValue = option
						listRow.value = nil
						listRow.deselect()
					}
				}
				
				self.availableNodes = []
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
