//
//  UpsertNodeViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Eureka

class UpsertNodeViewController: FormViewController {

	let nodeTypes = [[
		"display": "Pathway",
		"value": "pathway"
	],[
		"display": "Bathroom",
		"value": "bathroom"
	],[
		"display": "Printer",
		"value": "printer"
	],[
		"display": "Water Fountain",
		"value": "waterFountain"
	],[
		"display": "Room",
		"value": "room"
	],[
		"display": "Sports Venue",
		"value": "sportsVenue"
	]]

	override func viewDidLoad() {
		super.viewDidLoad()

		form +++ Section()
			<<< TextRow("name") { row in
				row.title = "Name"
				row.placeholder = "Ex. STEM 252"
			}
			+++ SelectableSection<ListCheckRow<String>>("Node Type", selectionType: .singleSelection(enableDeselection: true))

		for option in nodeTypes {
			form.last! <<< ListCheckRow<String>(option["value"]){ listRow in
				listRow.title = option["display"]
				listRow.selectableValue = option["value"]
				listRow.value = nil
			}
		}

		form +++ ButtonRow() { row in
			row.title = "Create"
//			row.disabled = Condition.function(["... Tags ..."]) { form in
//				return form.validate().count != 0
//			}
			row.onCellSelection(self.createNode)
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func createNode(cell: ButtonCellOf<String>, row: ButtonRow) {
		let formValues = form.values()

		var selectedNodeType: String = ""
		for nodeType in nodeTypes {
			if formValues[nodeType["value"]!]! != nil {
				selectedNodeType = nodeType["value"]!
			}
		}

		// Make sure user selected type
		/** @TODO Actually add form validation and disable button */
		if (formValues["name"]! == nil || selectedNodeType == "") {
			return;
		}

		print("Create Node!", selectedNodeType, form.validate(), form.values());

		/** @TODO Put Firebase logic here for adding node to database */

//		_ = navigationController?.popViewController(animated: true)
		performSegue(withIdentifier: "NodePositionSegue", sender: self)
	}

}
