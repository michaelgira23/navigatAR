//
//  SecondViewController.swift
//  navigatAR
//
//  Created by Michael Gira on 2/1/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import Firebase

class MapViewController: UIViewController {

	var ref: DatabaseReference!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		ref = Database.database().reference();

		ref.observe(DataEventType.value, with: { (snapshot) in
			let postDict = snapshot.value as? [String : AnyObject] ?? [:]
			print(postDict)
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

