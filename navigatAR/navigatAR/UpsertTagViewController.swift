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

	let tagValueTypes: [(display: String, value: TagType, canBeMultiple: Bool)] = [(
		display: "Text",
		value: .string,
		canBeMultiple: true
	), (
		display: "Number",
		value: .number,
		canBeMultiple: true
	), (
		display: "True/False",
		value: .boolean,
		canBeMultiple: false
	)]

	override func viewDidLoad() {
		super.viewDidLoad()

		form +++ Section()
			<<< TextRow("name") {
				$0.title = "Name"
				$0.placeholder = "Ex. Room Number"
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

				if !option.canBeMultiple {
					listRow.hidden = Condition.function(["multiple"], { form in
						return (form.rowBy(tag: "multiple") as? SwitchRow)?.value ?? false
					})
				}
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

		let tagValues = formValues["multiple"]! as! Bool ? tagValueTypes.filter { $0.canBeMultiple } : tagValueTypes
		for tagValueType in tagValues {
			if formValues[String(describing: tagValueType.value)]! != nil {
				selectedTagValueType = tagValueType.value
			}
		}

		// Make sure user selected type
		/** @TODO Actually add form validation and disable button */
		if (formValues["name"] == nil || selectedTagValueType == nil) {
			return;
		}
		
		let ref = Database.database().reference()
		
		ref.observeSingleEvent(of: .value, with: { snapshot in
			guard let currentBuilding = Building.current(root: snapshot) else { print("not in a building"); return }
			
			print("Create Tag!", selectedTagValueType!, self.form.validate(), self.form.values());
			
			let data = try! FirebaseEncoder().encode(TagInfo(
				building: currentBuilding.id,
				multiple: formValues["multiple"] as! Bool,
				name: formValues["name"] as! String,
				type: selectedTagValueType!
			))

			ref.child("tags").childByAutoId().setValue(data)

			_ = self.navigationController?.popViewController(animated: true)
		})
	}

}
