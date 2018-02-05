//
//  UpsertTagViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Eureka
import Firebase

class UpsertTagViewController: FormViewController {

	let tagValueTypes: [(display: String, value: TagType)] = [(
		display: "String",
		value: .string
	), (
		display: "Number",
		value: .number
	)]

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
			form.last! <<< ListCheckRow<String>(String(describing: option.value)){ listRow in
				listRow.title = option.display
				listRow.selectableValue = String(describing: option.value)
				listRow.value = nil
			}
		}

		form +++ ButtonRow() { row in
			row.title = "Create"
//			row.disabled = Condition.function(["... Tags ..."]) { form in
//				return form.validate().count != 0
//			}
			row.onCellSelection(self.createTag)
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func createTag(cell: ButtonCellOf<String>, row: ButtonRow) {
		let formValues = form.values()

		var selectedTagValueType: TagType? = nil
		for tagValueType in tagValueTypes {
			if formValues[String(describing: tagValueType.value)] != nil {
				selectedTagValueType = tagValueType.value
			}
		}

		// Make sure user selected type
		/** @TODO Actually add form validation and disable button */
		if (formValues["name"] == nil || selectedTagValueType == nil) {
			return;
		}

		print("Create Tag!", selectedTagValueType!, form.validate(), form.values());
		
		let data = try! FirebaseEncoder().encode(TagInfo(
			building: "building_push_key", /** @TODO get actual building push key */
			multiple: formValues["multiple"] as! Bool,
			name: formValues["name"] as! String,
			type: selectedTagValueType!
		))

		Database.database().reference().child("tags").childByAutoId().setValue(data)

		_ = navigationController?.popViewController(animated: true)
	}

}
