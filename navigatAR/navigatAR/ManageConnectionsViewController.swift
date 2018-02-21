////
////  ManageConnectionsViewController.swift
////  navigatAR
////
////  Created by Jack Cai on 2/20/18.
////  Copyright © 2018 MICDS Programming. All rights reserved.
////
//
//import UIKit
//import GoogleMaps
//import IndoorAtlas
//import Firebase
//import CodableFirebase
//
//class ManageConnectionsViewController: UIViewControllerWithBuilding {
//	
//	var ref: DatabaseReference!
//
//	var floorPlan = IAFloorPlan()
//	var locationManager = IALocationManager.sharedInstance()
//	var resourceManager = IAResourceManager()
//
//	var mapView: GMSMapView?
//	var floorplan: IAFloorPlan?
//	var floorplanImage: UIImage?
//	var overlay: GMSGroundOverlay?
//	
//	var nodes: [FirebasePushKey : Node] = [:]
//	var nodeMarkers: [GMSMarker] = []
//	
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//		
//		self.resourceManager = IAResourceManager(locationManager: self.locationManager)!
//
//		if let floorplanId = self.forBuilding.1.indoorAtlasFloors.first?.0 {
//			self.resourceManager.fetchFloorPlan(withId: floorplanId, andCompletion: { (floorplan, err) in
//				guard err == nil else { print(err as Any); return }
//				print("got floor plan")
//				
//				self.floorplan = floorplan
//				let camera = GMSCameraPosition.camera(withTarget: floorplan!.center, zoom: 30)
//				self.mapView = GMSMapView.map(withFrame: .zero, camera: camera)
//				self.mapView!.mapType = .normal
//				self.view = self.mapView!
//
//				self.resourceManager.fetchFloorPlanImage(with: floorplan!.imageUrl!, andCompletion: { (data, err) in
//					guard err == nil else { print(err as Any); return }
//					print("got image")
//					
//					self.floorplanImage = UIImage(data: data!)
//
////					let path = GMSMutablePath()
////					let midPoint = floorplan!.center
////					let rotation = degreesToRadians(floorplan!.bearing)
////					path.add(floorplan!.topRight)
////					path.add(floorplan!.topLeft)
////					path.add(floorplan!.bottomLeft)
////					let latDelta = midPoint.latitude - floorplan!.topLeft.latitude
////					let longDelta = midPoint.longitude - floorplan!.topLeft.longitude
////					let bottomRight = CLLocationCoordinate2DMake(floorplan!.topLeft.latitude + 2 * latDelta, floorplan!.topLeft.longitude + 2 * longDelta)
////					path.add(bottomRight)
////					path.add(self.rotatePt(floorplan!.topRight, around: midPoint, rotateRad: degreesToRadians(floorplan!.bearing)))
////					let rectangle = GMSPolygon(path: path)
////					rectangle.map = self.mapView
//					
//					let southWest = floorplan!.bottomLeft
//					let latDistance = self.distance(southWest, floorplan!.topLeft)
//					let longDistance = self.distance(floorplan!.topLeft, floorplan!.topRight)
//					let northEast = CLLocationCoordinate2DMake(southWest.latitude + latDistance, southWest.longitude + longDistance)
//					let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
////					let overlayBounds = GMSCoordinateBounds(path: path)
//
//					self.overlay = GMSGroundOverlay(bounds: overlayBounds, icon: self.floorplanImage)
////					self.overlay = GMSGroundOverlay(position: floorplan!.center, icon: self.floorplanImage!, zoomLevel: 19.5)
//					self.overlay!.bearing = floorplan!.bearing
//					self.overlay!.position = floorplan!.center
//
//					self.overlay!.map = self.mapView
//				})
//				
//				self.ref = Database.database().reference()
//				
//				self.ref.child("nodes").queryOrdered(byChild: "building").queryEqual(toValue: self.forBuilding.0).observe(.value, with: { snapshot in
//					guard snapshot.exists() else { return }
//				
//					self.nodes = try! FirebaseDecoder().decode([FirebasePushKey : Node].self, from: snapshot.value!)
//
//					for node in self.nodes {
//						let newMarker = GMSMarker(position: node.1.position.toCLLocationCoordinate2D())
//						newMarker.title = node.1.name
//						newMarker.map = self.mapView
//						self.nodeMarkers.append(newMarker)
//					}
//				})
//			})
//		}
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//	
//	func rotatePt (_ point: CLLocationCoordinate2D, around: CLLocationCoordinate2D, rotateRad rotate: Double) -> CLLocationCoordinate2D {
//		let long1 = point.longitude - around.longitude
//		let lat1 = point.latitude - around.latitude
//		
//		let lat2 = lat1 * cos(rotate) - long1 * sin(rotate)
//		let long2 = long1 * sin(rotate) + lat1 * cos(rotate)
//		
//		return CLLocationCoordinate2DMake(lat2 + around.latitude, long2 + around.longitude)
//	}
//	func distance(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
//		let xDist = a.latitude - b.latitude
//		let yDist = a.longitude - b.longitude
//		return Double(sqrt((xDist * xDist) + (yDist * yDist)))
//	}
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

