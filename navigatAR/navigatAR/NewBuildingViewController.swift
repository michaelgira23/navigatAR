//
//  NewBuildingViewController.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/15/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Foundation
import Eureka
import IndoorAtlas
import CodableFirebase
import Firebase

class NewBuildingViewController: FormViewController {
	
	var regions: [IARegion] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		form +++ Section("Building Information")
			<<< TextRow("buildingname") { row in
				row.title = "Name"
				row.placeholder = "Building Name"
				row.value = "WWT"
			}
			
			+++ MultivaluedSection(multivaluedOptions: .Insert, header: "Add Floors") { sec in
				sec.addButtonProvider = { _ in return ButtonRow {
					$0.title = "Add Floor"
					
					}.cellUpdate { cell, row in
						cell.textLabel?.textAlignment = .left
					}
				}
				
				sec.multivaluedRowToInsertAt = { index in return LabelRow { row in
					guard let region = IALocationManager.sharedInstance().location?.region else {
						print("oh bother") // TODO: actual error handling
						return
					}
					
					row.title = region.name
					self.regions.append(region)
					}
				}
				
				sec.showInsertIconInAddButton = true
			}
			+++ Section()
			<<< ButtonRow() { row in
				row.title = "Create"
				row.onCellSelection { cell, row in
					guard let buildingName = self.form.values()["buildingname"] as? String else { return }
					
					let building = Building(
						name: buildingName,
						indoorAtlasFloors: self.regions.reduce(into: [:], { (result, region) in result[region.identifier] = region.name })
					)
					
					let ref = Database.database().reference()
					ref.child("buildings").childByAutoId().setValue(try! FirebaseEncoder().encode(building));
					
					_ = self.navigationController?.popViewController(animated: true)
				}
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		// view did disappear; we can do cleanup
	}
}
