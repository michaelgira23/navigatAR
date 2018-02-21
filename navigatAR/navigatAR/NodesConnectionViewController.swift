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
import Firebase
import CodableFirebase

let nodeTypeToEmoji: [NodeType : String] = [
	.pointOfInterest : "🧐",
	.pathway : "🛣",
	.printer : "🖨",
	.fountain : "⛲️",
	.room : "🏡",
	.sportsVenue : "🎾",
	.bathroom : "🚻"
]

// Blue dot annotation class
class BlueDotAnnotation: MKPointAnnotation {
	var radius: Double
//	var color: UIColor

	required init(radius: Double) {
		self.radius = radius
//		self.color = color
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class NodeAnnotation: MKPointAnnotation {
	var glyphText: String
	var reuseIdentifier: String = "NodeAnnotation"
	var highPriority: Bool = false
	
	init(glyphText: String, highPriority: Bool) {
		self.glyphText = glyphText
		self.highPriority = highPriority
		super.init()
	}
}

//class nodeConnectionOverlay: MKPolyline {
//	var color: UIColor
//
//	init(color: UIColor, coordinates: UnsafePointer<CLLocationCoordinate2D>, count: Int) {
//		self.color = color
//		super.init(coordinates: coordinates, count: count)
//	}
//}

//class nodeConnectionAnnotationView: MKAnnotationView {
//
//}

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

class NodesConnectionViewController: UIViewControllerWithBuilding, IALocationManagerDelegate, MKMapViewDelegate {
	
	var ref: DatabaseReference!
	var refHandle: UInt!
	
	var floorPlanFetch:IAFetchTask!
	var imageFetch:AnyObject!
	
	var fpImage = UIImage()
	
	var map: MKMapView? = MKMapView()
	var camera = MKMapCamera()
	var circle = MKCircle()
	var currentCircle: BlueDotAnnotation? = nil
	var nodeCircles: [NodeCircle] = []
	var updateCamera = false
	var polyToDelete: MKPolyline?
	
	var floorPlan = IAFloorPlan()
	var locationManager = IALocationManager.sharedInstance()
	var resourceManager = IAResourceManager()
	
	var rotated = CGRect()
	
	var label = UILabel()
	
	var connectionFrom: NodeCircle?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ref = Database.database().reference()

		NodeCircle.getNodeCircles(from: ref, map: map!, buildingId: forBuilding.0, callback: { self.nodeCircles = $0 })
	}
	
//	// functions to handle drags and touches
//
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print("Begin")
//	}
//
//	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if touches.first!.view is MKAnnotationView, (touches.first!.view as! MKAnnotationView).annotation is MKPointAnnotation  {
//			let circleView = touches.first!.view as! MKAnnotationView
//			let touchedCircle = circleView.annotation as! BlueDotAnnotation
//			// find the annotation from list of node annotations and change state
//			for nodeCircle in nodeCircles {
//				if (touchedCircle == nodeCircle.MKAnnotation && nodeCircle.touched == false) {
//					nodeCircle.touched(true)
//					connectionFrom = nodeCircle
//				}
//			}
////			print((touches.first!.view as! MKAnnotationView).annotation)
//		}
//	}
//
//	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		for nodeCircle in nodeCircles {
//			nodeCircle.touched(false)
//		}
//		if connectionFrom != nil, touches.first!.view is MKAnnotationView, (touches.first!.view as! MKAnnotationView).annotation is MKPointAnnotation  {
//			print("hi")
//			let circleView = touches.first!.view as! MKAnnotationView
//			let touchedCircle = circleView.annotation as! BlueDotAnnotation
//			// find the annotation from list of node annotations and connect nodes
//			for nodeCircle in nodeCircles {
//				if (touchedCircle == nodeCircle.MKAnnotation && nodeCircle.touched == false) {
//					connectionFrom?.makeConnection(to: nodeCircle)
//				}
//			}
//		}
////		if touches.first!.view is MKOverlayView, (touches.first!.view as! MKOverlayView)
//	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		let selectedCircle = view.annotation as! MKPointAnnotation
		// find the annotation from list of node annotations and connect nodes
		for nodeCircle in nodeCircles {
			if selectedCircle == nodeCircle.MKAnnotation {
				if connectionFrom != nil {
					print("yuh")
					connectionFrom?.makeConnection(to: nodeCircle, visualOnly: false)
					connectionFrom = nodeCircle
				} else {
					connectionFrom = nodeCircle
				}
			}
		}
		
	}
	
	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//		let selectedCircle = view.annotation as! MKPointAnnotation
//		// find the annotation from list of node annotations
//		for nodeCircle in nodeCircles {
//			if (selectedCircle == nodeCircle.MKAnnotation) {
//			}
//		}
	}
	
	@IBAction func mapTapped(_ tap: UITapGestureRecognizer) {
		if tap.state == .recognized && tap.state == .recognized {
			// Get map coordinate from touch point
			let touchPt: CGPoint = tap.location(in: map)
			let coord: CLLocationCoordinate2D = map!.convert(touchPt, toCoordinateFrom: map)
			let maxMeters: Double = meters(fromPixel: 22, at: touchPt)
			var nearestDistance: Float = MAXFLOAT
			var nearestPoly: MKPolyline? = nil
			// for every overlay ...
			for overlay: MKOverlay in map!.overlays {
				// .. if MKPolyline ...
				if (overlay is MKPolyline) {
					// ... get the distance ...
					let distance: Float = Float(distanceOf(pt: MKMapPointForCoordinate(coord), toPoly: overlay as! MKPolyline))
					// ... and find the nearest one
					if distance < nearestDistance {
						nearestDistance = distance
						nearestPoly = overlay as? MKPolyline
					}
					
				}
			}
			
			if Double(nearestDistance) <= maxMeters {
				print("Touched poly: \(String(describing: nearestPoly)) distance: \(nearestDistance)")
				for fromCircle in nodeCircles {
					for (line, toCircle) in fromCircle.connections {
						if line == nearestPoly! {
							if polyToDelete == nil {
								map!.remove(nearestPoly!)
								polyToDelete = nearestPoly
								map!.add(nearestPoly!)
							} else if nearestPoly != polyToDelete {
								print("switch", nearestPoly, polyToDelete)
								let oldPolyToDelete = polyToDelete!
								map!.remove(nearestPoly!)
								map!.remove(polyToDelete!)
								polyToDelete = nearestPoly!
								map!.add(nearestPoly!)
								map!.add(oldPolyToDelete)
							} else {
								print("boutta remove")
								polyToDelete = nil
								fromCircle.removeConnection(to: toCircle)
								connectionFrom = nil
							}
						}
					}
				}
				
			}
		}
	}
	
	func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
		var distance: Double = Double(MAXFLOAT)
		for n in 0..<poly.pointCount - 1 {
			let ptA = poly.points()[n]
			let ptB = poly.points()[n + 1]
			let xDelta: Double = ptB.x - ptA.x
			let yDelta: Double = ptB.y - ptA.y
			if xDelta == 0.0 && yDelta == 0.0 {
				// Points must not be equal
				continue
			}
			let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
			var ptClosest: MKMapPoint
			if u < 0.0 {
				ptClosest = ptA
			}
			else if u > 1.0 {
				ptClosest = ptB
			}
			else {
				ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta)
			}
			
			distance = min(distance, MKMetersBetweenMapPoints(ptClosest, pt))
		}
		return distance
	}
	
	func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
		let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
		let coordA: CLLocationCoordinate2D = map!.convert(pt, toCoordinateFrom: map)
		let coordB: CLLocationCoordinate2D = map!.convert(ptB, toCoordinateFrom: map)
		return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB))
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
		map?.add(overlay, level: .aboveRoads)
	}
	
	// Function for rendering overlay objects
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		var circleRenderer:MKCircleRenderer!
		var polyLineRenderer: MKPolylineRenderer!
		
		// If it is possible to convert overlay to MKCircle then render the circle with given properties. Else if the overlay is class of MapOverlay set up its own MapOverlayRenderer. Else render red circle.
		if let overlay = overlay as? MKCircle {
			circleRenderer = MKCircleRenderer(circle: overlay)
			circleRenderer.fillColor = UIColor(red: 0.08627, green: 0.5059, blue: 0.9843, alpha:1.0)
			return circleRenderer
			
		} else if overlay is MapOverlay {
			let overlayView = MapOverlayRenderer(overlay: overlay, overlayImage: fpImage, fp: floorPlan, rotated: rotated)
			return overlayView
			
		} else if let overlay = overlay as? MKPolyline {
			polyLineRenderer = MKPolylineRenderer(polyline: overlay)
			polyLineRenderer.lineWidth = 5
			if (overlay == polyToDelete) {
				polyLineRenderer.strokeColor = UIColor.red
			} else {
				polyLineRenderer.strokeColor = UIColor.blue
			}
			return polyLineRenderer
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
			
			// The accuracy of coordinate position depends on the placement of floor plan image.
			let point = floorPlan.coordinate(toPoint: (l.location?.coordinate)!)
			
			
			guard let accuracy = l.location?.horizontalAccuracy else { return }
			let conversion = floorPlan.meterToPixelConversion
			
			let size = CGFloat(accuracy * Double(conversion))
			
			var radiusPoints = (l.location?.horizontalAccuracy)! / MKMetersPerMapPointAtLatitude((l.location?.coordinate.latitude)!)
			
			// Remove the previous circle overlay and set up a new overlay
			if currentCircle == nil {
				currentCircle = BlueDotAnnotation(radius: 25)
				map?.addAnnotation(currentCircle!)
			}
			currentCircle?.coordinate = newLocation
			
			//map.remove(circle as MKOverlay)
			//circle = MKCircle(center: newLocation, radius: 1)
			//map.add(circle)
			
			if updateCamera {
				// Ask Map Kit for a camera that looks at the location from an altitude of 300 meters above the eye coordinates.
				camera = MKMapCamera(lookingAtCenter: (l.location?.coordinate)!, fromEyeCoordinate: (l.location?.coordinate)!, eyeAltitude: 300)
				
				// Assign the camera to your map view.
				map?.camera = camera
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
		
		updateCamera = false
		
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
		updateCamera = false
		
		map?.frame = view.bounds
		map?.delegate = self
		map?.isPitchEnabled = false
		view.addSubview(map!)
		view.sendSubview(toBack: map!)
		
		let mapTap = UITapGestureRecognizer()
		mapTap.numberOfTapsRequired = 1
		mapTap.numberOfTouchesRequired = 1
		mapTap.addTarget(self, action: #selector(NodesConnectionViewController.mapTapped(_:)))
		map?.addGestureRecognizer(mapTap)

		label.frame = CGRect(x: 8, y: 14, width: view.bounds.width - 16, height: 42)
		label.textAlignment = NSTextAlignment.center
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 0
		view.addSubview(label)
		
		requestLocation()
		
		if (floorPlanFetch != nil) {
			floorPlanFetch.cancel()
			floorPlanFetch = nil
		}

		self.resourceManager.fetchFloorPlan(withId: forBuilding.1.indoorAtlasFloors.first?.key, andCompletion: { (floorPlan, error) in
			guard error == nil, floorPlan != nil else { print("There was an error during floorplan fetch: ", error as Any); return }

			self.floorPlan = floorPlan!
			self.fetchImage(floorPlan!)
//			let direction = CLLocationDirection(floorPlan!.bearing)
//			let newCam = self.map!.camera.copy() as! MKMapCamera
//			newCam.heading = direction
//			self.map!.setCamera(newCam, animated: true)
			let viewRegion = MKCoordinateRegionMakeWithDistance(floorPlan!.center, Double(floorPlan!.widthMeters)/5, Double(floorPlan!.heightMeters)/5)
			self.map!.setRegion(viewRegion, animated: true)
			
		})
	}
	
	// Called when view will disappear and will remove the map from the view and sets its delegate to nil
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		
		locationManager.stopUpdatingLocation()
		locationManager.delegate = nil
		
		// clean ram
		switch (self.map!.mapType) {
		case MKMapType.hybrid:
				self.map!.mapType = MKMapType.standard
				break;
			case MKMapType.standard:
				self.map!.mapType = MKMapType.hybrid
				break;
			default:
				break;
		}
		self.map!.showsUserLocation = false
		self.map!.delegate = nil
		self.map!.removeFromSuperview()
		self.map = nil
		label.removeFromSuperview()
		
		ref.removeAllObservers()
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? BlueDotAnnotation {
			let type = "blueDot"
			let color = UIColor(red: 0, green: 125/255, blue: 1, alpha: 1)
			let alpha: CGFloat = 1.0

			let borderWidth:CGFloat = 3
			let borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

			let annotationView: MKAnnotationView = map!.dequeueReusableAnnotationView(withIdentifier: type) ?? MKAnnotationView.init(annotation: annotation, reuseIdentifier: type)

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
			
		} else if let annotation = annotation as? NodeAnnotation {
			if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.reuseIdentifier){
				return view
			} else {
				let annotationView = MKMarkerAnnotationView.init(annotation: annotation, reuseIdentifier: annotation.reuseIdentifier)
				annotationView.glyphText = annotation.glyphText
				annotationView.titleVisibility = .visible
				print(annotation.highPriority)
				if annotation.highPriority {
					annotationView.displayPriority = .defaultHigh
				} else {
					annotationView.displayPriority = .defaultLow
				}
				return annotationView
			}
		}

		return nil
	}
}

class NodeCircle {
	var MKAnnotation: MKPointAnnotation
	var touched: Bool = false
	var nodeInfo: (FirebasePushKey, Node)
	var map: MKMapView
	var connections: [(MKPolyline, NodeCircle)] = []
	var ref: DatabaseReference!

	init(db: DatabaseReference, mapView map: MKMapView, nodeInfo node: (FirebasePushKey, Node)) {
		self.map = map
		nodeInfo = node
		if let _ = nodeInfo.1.highPriority {
			MKAnnotation = NodeAnnotation(glyphText: nodeTypeToEmoji[node.1.type]!, highPriority: nodeInfo.1.highPriority!)
		} else {
			MKAnnotation = NodeAnnotation(glyphText: nodeTypeToEmoji[node.1.type]!, highPriority: false)
		}
		MKAnnotation.coordinate = CLLocationCoordinate2D(latitude: node.1.position.latitude, longitude: node.1.position.longitude)
		MKAnnotation.title = nodeInfo.1.name
		map.addAnnotation(MKAnnotation)
		ref = db
	}

//	func touched(_ touched: Bool) {
//		if touched {
//			// change node point style
//			self.touched = true
//			map.removeAnnotation(MKAnnotation)
//			MKAnnotation.radius = 50
//			map.addAnnotation(MKAnnotation)
//		} else {
//			self.touched = false
//			map.removeAnnotation(MKAnnotation)
//			MKAnnotation.radius = 50
//			map.addAnnotation(MKAnnotation)
//		}
//	}
	
	static func getNodeCircles(from ref: DatabaseReference, map: MKMapView, buildingId: String, callback: @escaping (_ nodes: [NodeCircle]) -> Void) -> Void {
		// Only query WWT nodes
		var nodeCircles: [NodeCircle] = []
		ref.child("nodes").queryOrdered(byChild: "building").queryEqual(toValue: buildingId).observeSingleEvent(of: .value, with: { snapshot in
			let nodes = try! FirebaseDecoder().decode([FirebasePushKey: Node].self, from: snapshot.value!)
			var connections: [String: String] = [:]
			for node in nodes {
				let newNodeCircle = NodeCircle(db: ref, mapView: map, nodeInfo: node)
				nodeCircles.append(newNodeCircle)
			}
			for fromNodeCircle in nodeCircles {
				for toNodeCircle in nodeCircles {
					if fromNodeCircle.nodeInfo.1.connectedTo != nil {
						for pushKey in fromNodeCircle.nodeInfo.1.connectedTo! {
							if pushKey == toNodeCircle.nodeInfo.0 {
								print("connection", pushKey, toNodeCircle.nodeInfo.0)
								fromNodeCircle.makeConnection(to: toNodeCircle, visualOnly: true)
							}
						}
					}
				}
			}
			print(nodeCircles)
			callback(nodeCircles)
		})
	}

	func makeConnection(to nodeCircle: NodeCircle, visualOnly: Bool) {
		if nodeCircle.MKAnnotation != self.MKAnnotation {
			if nodeCircle.nodeInfo.1.connectedTo == nil {
				nodeCircle.nodeInfo.1.connectedTo = []
			}
			if self.nodeInfo.1.connectedTo == nil {
				self.nodeInfo.1.connectedTo = []
			}
			var alreadyConnected = false
			for connectedCircle in self.connections {
				if connectedCircle.1.MKAnnotation == nodeCircle.MKAnnotation {
					alreadyConnected = true
					break
				}
			}
			if !alreadyConnected {
				if !visualOnly {
					self.nodeInfo.1.connectedTo?.values.append(nodeCircle.nodeInfo.0)
					print(self.nodeInfo.1.connectedTo)
					let connectionDictionary = Dictionary(uniqueKeysWithValues: nodeInfo.1.connectedTo!.values.map({ ($0, true) }))
					//				try! ref.child("nodes").child(nodeInfo.0).setValue(FirebaseEncoder().encode(nodeInfo.1))
					ref.updateChildValues(["/nodes/\(self.nodeInfo.0)/connectedTo": connectionDictionary])
				}
				let points = [nodeCircle.nodeInfo.1.position.toCLLocationCoordinate2D(), self.nodeInfo.1.position.toCLLocationCoordinate2D()]
				let line = MKPolyline(coordinates: points, count: points.count)
				connections.append((line, nodeCircle))
				map.add(line)
			}
//			map.deselectAnnotation(nodeCircle.MKAnnotation, animated: false)
		}
	}
	
	func removeConnection(to nodeCircle: NodeCircle) {
		var index = 0
		connections.forEach({ connection in
			if connection.1.MKAnnotation == nodeCircle.MKAnnotation {
				map.remove(connection.0)
				connections.remove(at: index)
				for (index, pushKey) in self.nodeInfo.1.connectedTo!.values.enumerated() {
					if pushKey == nodeCircle.nodeInfo.0 {
						self.nodeInfo.1.connectedTo!.values.remove(at: index)
						break
					}
				}
			}
			index += 1
		})
		print(nodeInfo.1.connectedTo)
		let connectionDictionary = Dictionary(uniqueKeysWithValues: nodeInfo.1.connectedTo!.values.map({ ($0, true) }))
//		try! ref.child("nodes").child(nodeInfo.0).setValue(FirebaseEncoder().encode(nodeInfo.1))
		ref.updateChildValues(["/nodes/\(self.nodeInfo.0)/connectedTo": connectionDictionary])
	}

//	func updateDBConnection() {
//
//	}
}
