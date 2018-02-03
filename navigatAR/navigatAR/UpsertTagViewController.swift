//
//  UpsertTagViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Eureka

class UpsertTagViewController: FormViewController {

	let tagValueTypes = [[
		"display": "String",
		"value": "string"
	], [
		"display": "Number",
		"value": "number"
	]]

	override func viewDidLoad() {
		super.viewDidLoad()

		form +++ Section()
			<<< TextRow("name") { row in
				row.title = "Name"
				row.placeholder = "Ex. Room Number"
//				row.add(rule: RuleRequired())
//				row.validationOptions = .validatesOnChange
			}
			<<< SwitchRow("multiple") { row in
				row.title = "Multiple"
				row.value = false;
			}
			+++ SelectableSection<ListCheckRow<String>>("Value Type", selectionType: .singleSelection(enableDeselection: false))

		for option in tagValueTypes {
			form.last! <<< ListCheckRow<String>(option["value"]){ listRow in
				listRow.title = option["display"]
				listRow.selectableValue = option["value"]
				listRow.value = nil
			}
		}

		form +++ ButtonRow() { row in
			row.title = "Create"
			row.disabled = Condition.function(["... Tags ..."]) { form in
				return form.validate().count != 0
			}
			row.onCellSelection(self.createTag)
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func createTag(cell: ButtonCellOf<String>, row: ButtonRow) {
		let formValues = form.values()

		var tagType: String = ""
		for tagValueType in tagValueTypes {
			if formValues[tagValueType["value"]!]! != nil {
				print("Above evals to true");
				tagType = tagValueType["value"]!
			}
		}

		print("Create Tag!", tagType, form.validate(), form.values());

		/** @TODO Put Firebase logic here for adding tag to database */

		_ = navigationController?.popViewController(animated: true)
	}

}
