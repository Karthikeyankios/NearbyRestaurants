// LocationService.swift

//  DESCRIPTION: How to use CLLocationManager as a singleton object with Swift. Modify according

//  IMPORTANT
//	  You MUST include one of the keys below in your Info.plist file with an appropiate description
//	according to the respected permission you've asked for. Otherwise CoreLocation won't function!
//
//	  - NSLocationWhenInUseUsageDescription - <your_description>
//	  - NSLocationAlwaysUsageDescription - <your_description>					(required by iBeacon usage)
//

import Foundation
import CoreLocation
import UIKit

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()     // Swifty way of singleton :]
    
    
    
    var locationFoundBlock: ((_ latitude: CLLocationDegrees,_ longitude:CLLocationDegrees)->())?
    var serviceSekerController:UIViewController!
    
    // set the manager object right when it gets initialized
    let manager: CLLocationManager = {
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.distanceFilter = kCLLocationAccuracyBest
        $0.requestWhenInUseAuthorization()
        //$0.allowsBackgroundLocationUpdates = true
        return $0
    }(CLLocationManager())
    
    
    
    private(set) var currentLocation: CLLocationCoordinate2D!
    private(set) var currentHeading: CLHeading!
    
    private override init() {
        super.init()
        manager.delegate = self
    }
    
    // start tracking
    func startTrackingLocation(){
        
        manager.delegate = self
        
        LocationService.shared.escalateLocationServiceAuthorization()
        // updates MUST start here
        manager.startUpdatingLocation()
        //        manager.startUpdatingHeading()
    }
    
    
    func trackLocation(locationFound: @escaping ((_ latitude: CLLocationDegrees, _ longitude:CLLocationDegrees)->())){
        manager.delegate = self
        
        LocationService.shared.escalateLocationServiceAuthorization()
        // updates MUST start here
        locationFoundBlock = locationFound
        
        manager.startUpdatingLocation()
        //        manager.startUpdatingHeading()
        
    }
    
    func stopTrackingLocation(){
        
        locationFoundBlock = nil
        manager.delegate = nil
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
    
    
    func escalateLocationServiceAuthorization() {
        // Escalate only when the authorization is set to when-in-use
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func locationNotEnableAlertMessage(onController:UIViewController){
        
        serviceSekerController = onController
        let alert = UIAlertController(title: "", message: "You have disallowed location access.  Please navigate to phone settings and allow app access to the location.", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action -> Void in
            //Just dismiss the action sheet
            
            let nc = onController.navigationController
            nc?.popViewController(animated: false)
        })
        
        let okAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action -> Void in
            //Just dismiss the action sheet
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        onController.present(alert, animated: false, completion: nil)
    }
    
    
    func getLocationServiceStatus(onController:UIViewController)->(CLAuthorizationStatus) {
        serviceSekerController = onController
        return CLLocationManager.authorizationStatus()
    }
    // MARK: Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If location data can be determined
        if let location = locations.last! as CLLocation? {
            
            let latFloat = location.coordinate.latitude //+ Double(0.001)
            let lonFloat = location.coordinate.longitude //+ Double(0.001)
            
            
            _ = "\(latFloat)" + "," + "\(lonFloat)"
            if locationFoundBlock != nil{
                locationFoundBlock!(latFloat,lonFloat)
                stopTrackingLocation()
            }
            currentLocation = location.coordinate
            print("didUpdateLocations", location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
    }
    
    // MARK: Heading Updates
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("didUpdateHeading")
        currentHeading = newHeading
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
    {
        
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            print("restricted, denied from didChangeAuthorization")
            locationNotEnableAlertMessage(onController: serviceSekerController)
            break
            
        case .authorizedWhenInUse:
            // Enable only your app's when-in-use features.
            print("enableMyWhenInUseFeatures from didChangeAuthorization")
            startTrackingLocation()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location services.
            print("authorizedAlways from didChangeAuthorization")
            startTrackingLocation()
            break
            
        case .notDetermined:
            print("notDetermined from didChangeAuthorization")
            break
            
        @unknown default:
            print("notDetermined from didChangeAuthorization")
            break
            
        }
        
    }
}
