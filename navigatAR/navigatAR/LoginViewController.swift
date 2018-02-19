//
//  LoginViewController.swift
//  navigatAR
//
//  Created by Nick Clifford on 2/16/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import Eureka

class LoginViewController: FormViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		form +++ Section("Login")
			<<< EmailRow("email") { row in
				row.title = "Email"
				row.placeholder = "bob@example.com"
			}
			<<< PasswordRow("password") { row in
				row.title = "Password"
			}
		
		form +++ ButtonRow { row in
			row.title = "Login"
			row.onCellSelection(self.login)
		}
	}
	
	func login(cell: ButtonCellOf<String>, row: ButtonRow) {
		let formValues = form.values()
		
		guard let email = formValues["email"]!, let password = formValues["password"]! else { return }
		
		Auth.auth().signIn(withEmail: email as! String, password: password as! String) { (user, error) in
			if user == nil {
				print("sign in failed I guess") // TODO: handle error properly
				return
			}

			_ = self.navigationController?.popViewController(animated: true)
		}
	}
}
