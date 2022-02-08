//
//  ViewController.swift
//  NearbyRestaurants
//
//  Created by Karthikeyan K on 04/02/22.

import UIKit

class RestaurantsListViewController: UITableViewController {
    
    let cellId = "cellId"
    var resTableModel : [GApiResponse.NearBy]  = [GApiResponse.NearBy]()
    // MARK: - ViewController life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "Near By Restaurants"
        tableView.register(RestaurentTableCell.self, forCellReuseIdentifier: cellId)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if isConnectedToInternet() {
            showActivity()
            setupLocation()
            getCurrentlocCordinates()
            
        }else{
            
            let alertController = UIAlertController(title: Bundle.main.infoDictionary?["CFBundleName"] as? String, message: "The Internet connection appears to be offline.", preferredStyle: .alert)

            let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in

                
            }
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            
        }
  }
    // MARK: - Check Location Permission
    func setupLocation(){
        
        weak var weakSelf = self
        switch LocationService.shared.getLocationServiceStatus(onController: weakSelf!) {
        case .notDetermined:
            // Request when-in-use authorization initially
            print("notDetermined")
            hideActivity()
            break
            
        case .restricted, .denied:
            // Disable location features
            hideActivity()
            print("restricted")
            LocationService.shared.locationNotEnableAlertMessage(onController: weakSelf!)
            break
            
            
        case .authorizedWhenInUse:
            // Enable basic location features
            print("authorizedWhenInUse")
            LocationService.shared.escalateLocationServiceAuthorization()
            LocationService.shared.startTrackingLocation()
            
            break
            
            
        case .authorizedAlways:
            // Enable any of your app's location features
            print("authorizedAlways")
            LocationService.shared.escalateLocationServiceAuthorization()
            LocationService.shared.startTrackingLocation()
            break
        @unknown default:
            break
        }
        
    }
    // MARK: - Get current Location coordinates
    @objc func getCurrentlocCordinates(){
        
        LocationService.shared.trackLocation { (lat, long) in
            var location = GLocation()
            location.latitude = lat
            location.longitude = long
            self.getNearbyRestaurants(location: location)
            print(lat,long)
        }
    }
    // MARK: - Get 15 KM Radius Restaurants Using Google API nearbysearch
    func getNearbyRestaurants(location:GLocation?){
        
        var input = GInputParams()
        input.keyword = NearByTypes.restaurant.rawValue
        input.radius = 15000 //15 KM radius
        input.destinationCoordinate = location
        NearbyExtension.shared.completion = { response in
            if let data = response.data as? [GApiResponse.NearBy], response.isValidFor(.nearBy){
                
                self.resTableModel = data
                // create dispatch source that will handle events on main queue
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
                
            }
            
            hideActivity()
        }
        NearbyExtension.shared.getAllNearBy(input: input)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Delegates and DataSource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RestaurentTableCell
        let currentItem = resTableModel[indexPath.row]
        cell.restaurantItem = currentItem
        cell.updateCellWith(row: currentItem.photo_reference)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resTableModel.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentLastItem = resTableModel[indexPath.row]
        let resDetailVc = RestaurantsDetailViewController()
        resDetailVc.restaurentDetail = currentLastItem
        self.navigationController?.pushViewController(resDetailVc, animated: true)
    }
   
   
}
