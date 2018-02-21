//
//  ManageConnectionsViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/20/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import GoogleMaps
import IndoorAtlas
import Firebase

class ManageConnectionsViewController: UIViewControllerWithBuilding {
	
	var ref: DatabaseReference!

	var floorPlan = IAFloorPlan()
	var locationManager = IALocationManager.sharedInstance()
	var resourceManager = IAResourceManager()

	var mapView: GMSMapView?
	var floorplan: IAFloorPlan?
	var floorplanImage: UIImage?
	var overlay: GMSGroundOverlay?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.resourceManager = IAResourceManager(locationManager: self.locationManager)!

		if let floorplanId = self.forBuilding.1.indoorAtlasFloors.first?.0 {
			self.resourceManager.fetchFloorPlan(withId: floorplanId, andCompletion: { (floorplan, err) in
				guard err == nil else { print(err as Any); return }
				print("got floor plan")
				
				self.floorplan = floorplan
				let camera = GMSCameraPosition.camera(withTarget: floorplan!.center, zoom: 20)
				self.mapView = GMSMapView.map(withFrame: .zero, camera: camera)
				self.view = self.mapView!

				self.resourceManager.fetchFloorPlanImage(with: floorplan!.imageUrl!, andCompletion: { (data, err) in
					guard err == nil else { print(err as Any); return }
					print("got image")
					
					self.floorplanImage = UIImage(data: data!)
					
					let southWest = floorplan?.bottomLeft
					let northEast = floorplan?.topRight
					let overlayBounds = GMSCoordinateBounds(coordinate: southWest!, coordinate: northEast!)
					self.overlay = GMSGroundOverlay(bounds: overlayBounds, icon: self.floorplanImage)

					self.overlay!.bearing = floorplan!.bearing
					self.overlay!.map = self.mapView
				})
				
				self.ref = Database.database().reference()
			})
		}
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
