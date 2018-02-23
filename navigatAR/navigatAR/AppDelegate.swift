//
//  AppDelegate.swift
//  navigatAR
//
//  Created by Michael Gira on 2/1/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import CodableFirebase
import UIKit
import Firebase
import IndoorAtlas
import HCKalmanFilter

func getConfigItem(name: String) -> String? {
	let filePath = Bundle.main.path(forResource: "config", ofType: "plist")
	let plist = NSDictionary(contentsOfFile: filePath!)
	if let value = plist!.object(forKey: name) as? String {
		return value
	} else {
		return nil
	}
}

extension FloatingPoint {
	var degreesToRadians: Self { return self * .pi / 180 }
	var radiansToDegrees: Self { return self * 180 / .pi }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IALocationManagerDelegate {

	var window: UIWindow?

	weak var locationDelegate: LocationDelegate?

	var locationManager: IALocationManager?

	var currentLocation: Location? = nil
	var kalmanLocation: CLLocation? = nil
	var resetKalmanFilter: Bool = false
	var hcKalmanFilter: HCKalmanAlgorithm? = nil
	
	func authenticateAndRequestLocation() {
		
		// Get IALocationManager shared instance and point delegate to receiver
		locationManager = IALocationManager.sharedInstance()
		
		// Set IndoorAtlas API key and secret
		let IAAPIKeyId = getConfigItem(name: "IAAPIKeyId")!
		let IAAPIKeySecret = getConfigItem(name: "IAAPIKeySecret")!
		locationManager!.setApiKey(IAAPIKeyId, andSecret: IAAPIKeySecret)

		// Start listening for location
		locationManager!.delegate = self
		locationManager!.startUpdatingLocation()
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		FirebaseApp.configure()
		authenticateAndRequestLocation()
		
//		let GMSAPIKey = getConfigItem(name: "GMSAPIKey")
//		GMSServices.provideAPIKey(GMSAPIKey!)
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	// Custom URL handler
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let arController = storyboard.instantiateViewController(withIdentifier: "arController") as! NavViewController
		
		// Navigate to NavViewController, perform respective segue upon completion
		switch url.host {
		case .some("node"):
			window?.rootViewController!.present(arController, animated: true) {
				Database.database().reference(withPath: "nodes/\(url.lastPathComponent)").observeSingleEvent(of: .value, with: { snapshot in
					guard snapshot.exists(), let value = snapshot.value else { return }
					let node = try! FirebaseDecoder().decode(Node.self, from: value)
					arController.performSegue(withIdentifier: "showDestinationDetail", sender: "\(url.lastPathComponent),\(node.name),\(node.type),\(node.building)")
				})
			}
			return true
		case .some("event"):
			window?.rootViewController!.present(arController, animated: true) {
				Database.database().reference(withPath: "events/\(url.lastPathComponent)").observeSingleEvent(of: .value, with: { snapshot in
					guard snapshot.exists(), let value = snapshot.value else { return }
					let event = try! FirebaseDecoder().decode(Event.self, from: value)
					arController.performSegue(withIdentifier: "showEventInfo", sender: "_event,\(event.name),\(event.description),\(event.start.timeIntervalSinceReferenceDate),\(event.end.timeIntervalSinceReferenceDate),\(event.locations.joined(separator: ","))")
				})
			}
			return true
		default:
			return false
		}
	}

	func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {
		print("pos update app delegate")
		currentLocation = Location(fromIALocation: locations.last as! IALocation)
		let currentCLLocation = CLLocation(
			coordinate: CLLocationCoordinate2DMake(currentLocation!.latitude, currentLocation!.altitude),
			altitude: currentLocation!.altitude,
			horizontalAccuracy: currentLocation!.horizontalAccuracy,
			verticalAccuracy: currentLocation!.verticalAccuracy,
			timestamp: Date()
		)
		if hcKalmanFilter == nil {
			self.hcKalmanFilter = HCKalmanAlgorithm(initialLocation: currentCLLocation)
		}
		else {
			if let hcKalmanFilter = self.hcKalmanFilter {
				if resetKalmanFilter == true {
					hcKalmanFilter.resetKalman(newStartLocation: currentCLLocation)
					resetKalmanFilter = false
				}
				else {
//					kalmanLocation = Location(hcKalmanFilter.processState(currentLocation: currentCLLocation))
//					print(kalmanLocation.coordinate)
					kalmanLocation = hcKalmanFilter.processState(currentLocation: currentCLLocation)
					locationDelegate?.locationUpdate(currentLocation: currentLocation, kalmanLocation: kalmanLocation)
				}
			}
		}
	}

}
