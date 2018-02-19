//
//  AdminViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/2/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase
import UIKit
import IndoorAtlas

class AdminViewController: UIViewController {

	let locationManager = IALocationManager.sharedInstance()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		// Delegate methods to our custom location handler

		Database.database().reference().observeSingleEvent(of: .value, with: { snapshot in
			if let building = Building.current(root: snapshot) {
				print(building)
			} else {
				print("whoopsie")
			}
			guard let (nodes, graph) = populateGraph(rootSnapshot: snapshot) else { print("unable to get graph"); return }

			let myHouse = nodes["-L5VHbFv1Fwx3bHFvX_I"]!
			let stem252 = nodes["-L50XlMkv4OWKSN6y75D"]!
			
			print(graph.findPath(from: myHouse, to: stem252))
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
