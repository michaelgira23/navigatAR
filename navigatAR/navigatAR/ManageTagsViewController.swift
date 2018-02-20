//
//  ManageTagsViewController.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/10/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class ManageTagsViewController: UIViewControllerWithBuilding, UITableViewDataSource {
	@IBOutlet weak var tagsTable: UITableView!
	@IBAction func unwindToManageNodes(unwindSegue: UIStoryboardSegue) { }
	
	var tags: [TagInfo] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view, typically from a nib.
		
		navigationItem.prompt = forBuilding.1.name
		
		tagsTable.dataSource = self
		
		let ref = Database.database().reference()
		
		// Continuously update `tags` from database
		ref.child("tags").queryOrdered(byChild: "building").queryEqual(toValue: forBuilding.0).observe(.value, with: { snapshot in
			guard snapshot.exists(), let value = snapshot.value else { return }
			
			do {
				//guard let currentBuilding = Building.current(root: snapshot) else { print(""); return }
				
				self.tags = Array((try FirebaseDecoder().decode([FirebasePushKey: TagInfo].self, from: value)).values)//.filter({ $0.building == currentBuilding.id })
				self.tagsTable.reloadData()
			} catch let error {
				print(error) // TODO: properly handle error
			}
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: TableView functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tagsTable.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as UITableViewCell
		let tag = tags[indexPath.row]
		
		cell.textLabel?.text = tag.name
		cell.detailTextLabel?.text = String(describing: tag.type)
		
		return cell
	}
}
