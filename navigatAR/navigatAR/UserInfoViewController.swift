//
//  UserInfoViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/19/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class UserInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var buildingTable: UITableView!
	@IBOutlet weak var emailLabel: UILabel!
	var authListenerHandle: AuthStateDidChangeListenerHandle?
	
	var ref: DatabaseReference!
	
	var buildings: [Building] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		buildingTable.dataSource = self
		buildingTable.delegate = self
		buildingTable.register(BuildingTableViewCell.self, forCellReuseIdentifier: "buildingCell")
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
				self.ref.child("users/\(user!.uid)").observe(.value, with: { snapshot in
					guard !(snapshot.value! is NSNull) else { return }

					let user = try! FirebaseDecoder().decode(User.self, from: snapshot.value!)
					guard let buildingKeys = user.admin else { return }

					var buildingsQueued = 0
					buildingKeys.forEach() { key in
						self.ref.child("buildings/\(key)").observeSingleEvent(of: .value, with: { snapshot in
							guard !(snapshot.value! is NSNull) else { return }
							
							let building = try! FirebaseDecoder().decode(Building.self, from: snapshot.value!)
							buildingsQueued += 1
							self.buildings.append(building)
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
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return buildings.count
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let buildingCell = tableView.dequeueReusableCell(withIdentifier: "buildingCell", for: indexPath) as UITableViewCell
		buildingCell.textLabel!.text = buildings[indexPath.row].name
		return buildingCell
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
