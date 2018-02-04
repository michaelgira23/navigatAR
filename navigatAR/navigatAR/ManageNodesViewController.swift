//
//  ManageNodesViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/3/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class ManageNodesViewController: UIViewController {

	@IBAction func unwindToManageNodes(segue: UIStoryboardSegue) { }

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		Database.database().reference().child("nodes/NodePushKey").observeSingleEvent(of: .value, with: { snapshot in
			guard let value = snapshot.value else { return }
			
			do {
				let node = try FirebaseDecoder().decode(Node.self, from: value)
				print("building key: \(node.building)")
				print("node name: \(node.name)")
				print("node type: \(node.type)")
				print("location: \(node.position)")
				print("teachers: \(node.tags["teachers"]!)")
				print("room number: \(node.tags["roomNumber"]!)")
			} catch let error {
				print(error)
			}
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

