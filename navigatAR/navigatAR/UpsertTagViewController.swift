//
//  UpsertTagViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Eureka

class UpsertTagViewController: FormViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		form +++ TextRow() { row in
			row.title = "Name"
			row.placeholder = "Ex. Room Number"
			}
			+++ SwitchRow("switchRowTag") { row in
				row.title = "Multiple"
			}
			+++ SelectableSection<ListCheckRow<String>>("Value Type", selectionType: .singleSelection(enableDeselection: true))
		let tagTypes = ["String", "Number"]
		for option in tagTypes {
			form.last! <<< ListCheckRow<String>(option){ listRow in
				listRow.title = option
				listRow.selectableValue = option
				listRow.value = nil
			}
		}

		form +++ ButtonRow() { row in
			row.title = "Create"
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}
