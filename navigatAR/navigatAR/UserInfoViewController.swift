//
//  UserInfoViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/19/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Firebase
import UIKit

class UserInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var buildingTable: UITableView!
	@IBOutlet weak var emailLabel: UILabel!
	var authListenerHandle: AuthStateDidChangeListenerHandle?
	
	var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
				self.ref.child("user").child(user!.uid).observe(.value, with: { snapshot in
					
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
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
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
