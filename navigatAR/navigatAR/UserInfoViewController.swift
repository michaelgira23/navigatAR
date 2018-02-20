//
//  UserInfoViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/19/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import Eureka
import UIKit

class UserInfoViewController: UIViewControllerWithBuilding, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var buildingTable: UITableView!
	@IBOutlet weak var emailLabel: UILabel!
	var authListenerHandle: AuthStateDidChangeListenerHandle?
	
	var ref: DatabaseReference!
	var userHandle: DatabaseHandle?
	var buildingHandle: DatabaseHandle?
	
	var buildings: [(FirebasePushKey, Building)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		buildingTable.dataSource = self
		buildingTable.delegate = self
//		buildingTable.register(BuildingTableViewCell.self, forCellReuseIdentifier: "buildingCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewWillAppear(_ animated: Bool) {
		ref = Database.database().reference()
		authListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
			if let _ = user {
				self.emailLabel.text = "Email: " + user!.email!
				self.userHandle = self.ref.child("users/\(user!.uid)").observe(.value, with: { snapshot in
					guard !(snapshot.value! is NSNull) else { return }

					let user = try! FirebaseDecoder().decode(User.self, from: snapshot.value!)
					guard let buildingKeys = user.admin else { return }

					var buildingsQueued = 0
					buildingKeys.forEach() { key in
						self.ref.child("buildings/\(key)").observeSingleEvent(of: .value, with: { snapshot in
							guard !(snapshot.value! is NSNull) else { return }
							
							let building = try! FirebaseDecoder().decode(Building.self, from: snapshot.value!)
							buildingsQueued += 1
							self.buildings.append((key, building))
							if (buildingsQueued == buildingKeys.count) {
								print(self.buildings)
								self.buildingTable.reloadData()
							}
						})
					}
				})
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		Auth.auth().removeStateDidChangeListener(authListenerHandle!)
		ref.removeAllObservers()
		buildings = []
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return buildings.count
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let buildingCell = tableView.dequeueReusableCell(withIdentifier: "buildingCell", for: indexPath) as? BuildingTableViewCell else { return UITableViewCell() }
		buildingCell.textLabel!.text = buildings[indexPath.row].1.name
		buildingCell.detailTextLabel!.text =  "Floors: " + String(buildings[indexPath.row].1.indoorAtlasFloors.count)
		buildingCell.accessoryType = .disclosureIndicator
		return buildingCell
	}
	

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		forBuilding = buildings[indexPath.row]
		return indexPath
	}

}

class UIViewControllerWithBuilding: UIViewController, ViewControllerWithBuilding {
	var forBuilding: (FirebasePushKey, Building)!

	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard var view = segue.destination as? ViewControllerWithBuilding else { return }
		view.forBuilding = forBuilding
	}
}

class FormViewControllerWithBuilding: FormViewController, ViewControllerWithBuilding {
	var forBuilding: (FirebasePushKey, Building)!
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		guard var view = segue.destination as? ViewControllerWithBuilding else { return }
		view.forBuilding = forBuilding
	}
}

protocol ViewControllerWithBuilding {
	var forBuilding: (FirebasePushKey, Building)! { get set }
}
