//
//  AppDelegate.swift
//  NearbyRestaurants
//
//  Created by Karthikeyan K on 04/02/22.
//

import UIKit
import GoogleMaps
import SystemConfiguration
import Foundation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GoogleApi.shared.initialiseWithKey("")
        GMSServices.provideAPIKey(GoogleApi.shared.googleApiKey)
       // GMSPlacesClient.provideAPIKey(GoogleApi.shared.googleApiKey)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: RestaurantsListViewController.init())
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        navigationController.navigationBar.backgroundColor = .white
        navigationController.addCustomBottomLine(color: UIColor.gray, height: 0.5)

        self.window?.rootViewController = navigationController
        
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        return true
    }



}
public func showActivity()
 {
     SKActivityIndicator.spinnerStyle(.spinningHalfCircles)
     SKActivityIndicator.spinnerColor(UIColor.systemRed)
     SKActivityIndicator.show("", userInteractionStatus: false)
    
 }

public func hideActivity()
 {
     SKActivityIndicator.dismiss()
 }
public func isConnectedToInternet() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    if flags.isEmpty {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    return (isReachable && !needsConnection)
}
extension UINavigationController
{
    func addCustomBottomLine(color:UIColor,height:Double)
    {
        //Hiding Default Line and Shadow
        navigationBar.setValue(true, forKey: "hidesShadow")
    
        //Creating New line
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:0, height: height))
        lineView.backgroundColor = color
        navigationBar.addSubview(lineView)
    
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.widthAnchor.constraint(equalTo: navigationBar.widthAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        lineView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
        lineView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
    }
}
