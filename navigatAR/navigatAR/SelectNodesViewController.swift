//
//  SelectNodesViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/18/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import Firebase
import UIKit

class SelectNodesViewController: UITableViewController {

	@IBOutlet var nodesTable: UITableView!
	
	var nodes: [String] = ["hello", "world", "this", "is", "a", "test"]

	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

		nodesTable.dataSource = self
		
		let ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return nodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = nodesTable.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as UITableViewCell
		let node = nodes[indexPath.row]
		
		cell.textLabel?.text = node
		cell.detailTextLabel?.text = String(describing: node)
		
		return cell
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
