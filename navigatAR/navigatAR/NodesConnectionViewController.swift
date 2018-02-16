//
//  NodesConnectionViewController.swift
//  navigatAR
//
//  Created by Jack Cai on 2/10/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import UIKit
import MapKit
import IndoorAtlas
import SVProgressHUD
import Firebase
import CodableFirebase

// Blue dot annotation class
class BlueDotAnnotation: MKPointAnnotation {
	var radius: Double
	
	required init(radius: Double) {
		self.radius = radius
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// Class for map overlay object
class MapOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D
	var boundingMapRect: MKMapRect
	
	
	// Initializer for the class
	init(floorPlan: IAFloorPlan, andRotatedRect rotated: CGRect) {
		coordinate = floorPlan.center
		
		// Area coordinates for the overlay
		let topLeft = MKMapPointForCoordinate(floorPlan.topLeft)
		boundingMapRect = MKMapRectMake(topLeft.x + Double(rotated.origin.x), topLeft.y + Double(rotated.origin.y), Double(rotated.size.width), Double(rotated.size.height))
	}
}

// Class for rendering map overlay objects
class MapOverlayRenderer: MKOverlayRenderer {
	var overlayImage: UIImage
	var floorPlan: IAFloorPlan
	var rotated: CGRect
	
	init(overlay:MKOverlay, overlayImage:UIImage, fp: IAFloorPlan, rotated: CGRect) {
		self.overlayImage = overlayImage
		self.floorPlan = fp
		self.rotated = rotated
		super.init(overlay: overlay)
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in ctx: CGContext) {
		
		// Width and height in MapPoints for the floorplan
		let mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(floorPlan.center.latitude)
		let rect = CGRect(x: 0, y: 0, width: Double(floorPlan.widthMeters) * mapPointsPerMeter, height: Double(floorPlan.heightMeters) * mapPointsPerMeter)
		ctx.translateBy(x: -rotated.origin.x, y: -rotated.origin.y)
		
		// Rotate around top left corner
		ctx.rotate(by: CGFloat(degreesToRadians(floorPlan.bearing)));
		
		// Draw the floorplan image
		UIGraphicsPushContext(ctx)
		overlayImage.draw(in: rect, blendMode: CGBlendMode.normal, alpha: 1.0)
		UIGraphicsPopContext();
	}
}

class NodesConnectionViewController: UIViewController, IALocationManagerDelegate, MKMapViewDelegate {
	
	var ref: DatabaseReference!
	var refHandle: UInt!
	
	var floorPlanFetch:IAFetchTask!
	var imageFetch:AnyObject!
	
	var fpImage = UIImage()
	
	var map = MKMapView()
	var camera = MKMapCamera()
	var circle = MKCircle()
	var currentCircle: BlueDotAnnotation? = nil
	var nodeCircles: [BlueDotAnnotation?] = []
	var updateCamera = true
	
	var floorPlan = IAFloorPlan()
	var locationManager = IALocationManager.sharedInstance()
	var resourceManager = IAResourceManager()
	
	var rotated = CGRect()
	
	var label = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ref = Database.database().reference()
		
		refHandle = ref.child("nodes").observe(.value, with: { snapshot in
			let nodes = Array(try! FirebaseDecoder().decode([FirebasePushKey: Node].self, from: snapshot.value!).values)
			for node in nodes {
				let nodeCircle = BlueDotAnnotation(radius: 20)
				nodeCircle.coordinate = CLLocationCoordinate2D(latitude: node.position.latitude, longitude: node.position.longitude)
				self.map.addAnnotation(nodeCircle)
				self.nodeCircles.append(nodeCircle)
			}
			print(self.nodeCircles)
		})

		SVProgressHUD.show(withStatus: NSLocalizedString("Waiting for location data", comment: ""))
	}
	
	// Function to change the map overlay
	func changeMapOverlay() {
		
		//Width and height in MapPoints for the floorplan
		let mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(floorPlan.center.latitude)
		let widthMapPoints = floorPlan.widthMeters * Float(mapPointsPerMeter)
		let heightMapPoints = floorPlan.heightMeters * Float(mapPointsPerMeter)
		
		let cgRect = CGRect(x: 0, y: 0, width: CGFloat(widthMapPoints), height: CGFloat(heightMapPoints))
		let a = degreesToRadians(self.floorPlan.bearing)
		rotated = cgRect.applying(CGAffineTransform(rotationAngle: CGFloat(a)));
		let overlay = MapOverlay(floorPlan: floorPlan, andRotatedRect: rotated)
		map.add(overlay)
	}
	
	// Function for rendering overlay objects
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		var circleRenderer:MKCircleRenderer!
		
		// If it is possible to convert overlay to MKCircle then render the circle with given properties. Else if the overlay is class of MapOverlay set up its own MapOverlayRenderer. Else render red circle.
		if let overlay = overlay as? MKCircle {
			circleRenderer = MKCircleRenderer(circle: overlay)
			circleRenderer.fillColor = UIColor(red: 0.08627, green: 0.5059, blue: 0.9843, alpha:1.0)
			return circleRenderer
			
		} else if overlay is MapOverlay {
			let overlayView = MapOverlayRenderer(overlay: overlay, overlayImage: fpImage, fp: floorPlan, rotated: rotated)
			return overlayView
			
		} else {
			circleRenderer = MKCircleRenderer(overlay: overlay)
			circleRenderer.fillColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 1.0)
			return circleRenderer
		}
	}
	
	func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {
		
		// Convert last location to IALocation
		let l = locations.last as! IALocation
		
		// Check that the location is not nil
		if let newLocation = l.location?.coordinate {
			
			SVProgressHUD.dismiss()
			
			// The accuracy of coordinate position depends on the placement of floor plan image.
			let point = floorPlan.coordinate(toPoint: (l.location?.coordinate)!)
			
			
			guard let accuracy = l.location?.horizontalAccuracy else { return }
			let conversion = floorPlan.meterToPixelConversion
			
			let size = CGFloat(accuracy * Double(conversion))
			
			var radiusPoints = (l.location?.horizontalAccuracy)! / MKMetersPerMapPointAtLatitude((l.location?.coordinate.latitude)!)
			
			// Remove the previous circle overlay and set up a new overlay
			if currentCircle == nil {
				currentCircle = BlueDotAnnotation(radius: 25)
				map.addAnnotation(currentCircle!)
			}
			currentCircle?.coordinate = newLocation
			
			//map.remove(circle as MKOverlay)
			//circle = MKCircle(center: newLocation, radius: 1)
			//map.add(circle)
			
			if updateCamera {
				// Ask Map Kit for a camera that looks at the location from an altitude of 300 meters above the eye coordinates.
				camera = MKMapCamera(lookingAtCenter: (l.location?.coordinate)!, fromEyeCoordinate: (l.location?.coordinate)!, eyeAltitude: 300)
				
				// Assign the camera to your map view.
				map.camera = camera
				updateCamera = false
			}
		}
		
		if let traceId = manager.extraInfo?[kIATraceId] as? NSString {
			label.text = "TraceID: \(traceId)"
		}
	}
	
	// Fetches image with the given IAFloorplan
	func fetchImage(_ floorPlan:IAFloorPlan) {
		imageFetch = self.resourceManager.fetchFloorPlanImage(with: floorPlan.imageUrl!, andCompletion: { (data, error) in
			if (error != nil) {
				print(error as Any)
			} else {
				self.fpImage = UIImage.init(data: data!)!
				self.changeMapOverlay()
			}
		})
	}
	
	func indoorLocationManager(_ manager: IALocationManager, didEnter region: IARegion) {
		
		guard region.type == ia_region_type.iaRegionTypeFloorPlan else { return }
		
		updateCamera = true
		
		if (floorPlanFetch != nil) {
			floorPlanFetch.cancel()
			floorPlanFetch = nil
		}
		
		// Fetches the floorplan for the given region identifier
		floorPlanFetch = self.resourceManager.fetchFloorPlan(withId: region.identifier, andCompletion: { (floorplan, error) in
			
			if (error == nil) {
				self.floorPlan = floorplan!
				self.fetchImage(floorplan!)
			} else {
				print("There was an error during floorplan fetch: ", error as Any)
			}
		})
	}
	
	// Authenticate to IndoorAtlas services and request location updates
	func requestLocation() {
		
		locationManager.delegate = self
		
		resourceManager = IAResourceManager(locationManager: locationManager)!
		
		locationManager.startUpdatingLocation()
	}
	
	// Called when view will appear and sets up the map view and its bounds and delegate. Also requests location
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		updateCamera = true
		
		map = MKMapView()
		map.frame = view.bounds
		map.delegate = self
		map.isPitchEnabled = false
		view.addSubview(map)
		view.sendSubview(toBack: map)
		
		label.frame = CGRect(x: 8, y: 14, width: view.bounds.width - 16, height: 42)
		label.textAlignment = NSTextAlignment.center
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 0
		view.addSubview(label)
		
		requestLocation()
	}
	
	// Called when view will disappear and will remove the map from the view and sets its delegate to nil
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		
		map.delegate = nil
		map.removeFromSuperview()
		label.removeFromSuperview()
		
		SVProgressHUD.dismiss()
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? BlueDotAnnotation {
			let type = "blueDot"
			let color = UIColor(red: 0, green: 125/255, blue: 1, alpha: 1)
			let alpha: CGFloat = 1.0
			
			let borderWidth:CGFloat = 3
			let borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
			
			let annotationView: MKAnnotationView = map.dequeueReusableAnnotationView(withIdentifier: type) ?? MKAnnotationView.init(annotation: annotation, reuseIdentifier: type)
			
			annotationView.annotation = annotation
			annotationView.frame = CGRect(x: 0, y: 0, width: annotation.radius, height: annotation.radius)
			annotationView.backgroundColor = color
			annotationView.alpha = alpha
			annotationView.layer.borderWidth = borderWidth
			annotationView.layer.borderColor = borderColor.cgColor
			annotationView.layer.cornerRadius = annotationView.frame.size.width / 2
			
			let mask = CAShapeLayer()
			mask.path = UIBezierPath(ovalIn: annotationView.frame).cgPath
			annotationView.layer.mask = mask
			
			return annotationView
			
		}
		return nil
	}
}
