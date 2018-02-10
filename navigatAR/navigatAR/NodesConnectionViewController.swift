//
//  NodesConnectionViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/10/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import IndoorAtlas

class NodesConnectionViewController: UIViewController {

	@IBOutlet weak var connectionsView: UIView!
	@IBOutlet weak var floorPlanImageView: UIImageView!
	
	var locationManager: IALocationManager?
	var resourceManager: IAResourceManager?
	var floorPlan: IAFloorPlan?
	var floorPlanImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		locationManager = IALocationManager.sharedInstance()
		resourceManager = IAResourceManager(locationManager: locationManager)
		locationManager!.delegate = self
		if let location = locationManager!.location {
			setFloorPlanImage(region: location.region!)
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
		
    }
	
	func setFloorPlanImage(region: IARegion) {
		print("called set Image")
		guard region.type == ia_region_type.iaRegionTypeFloorPlan else {
			print(region)
			return
		}
		resourceManager?.fetchFloorPlan(withId: region.identifier) { (floorPlan, error) in
			if error != nil {
				print(error as Any)
				return
			} else {
				self.floorPlan = floorPlan!
				self.resourceManager?.fetchFloorPlanImage(with: floorPlan!.imageUrl!) { (data, error) in
					if error != nil {
						print(error as Any)
						return
					} else {
						self.floorPlanImage = UIImage.init(data: data!)!
						self.floorPlanImageView.image = self.floorPlanImage
					}
				}
			}
		}
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

extension NodesConnectionViewController: IALocationManagerDelegate {
	func indoorLocationManager(_ manager: IALocationManager, didEnter region: IARegion) {
		setFloorPlanImage(region: region)
	}
}
