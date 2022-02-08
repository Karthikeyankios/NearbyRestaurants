//
//  RestaurantsDetailViewController.swift
//  NearbyRestaurants
//
//  Created by Karthikeyan K on 05/02/22.
//

import UIKit
import GoogleMaps
class RestaurantsDetailViewController: UIViewController {
    
    // MARK: - Global Variables
    var mapView = GMSMapView()
    var restaurentDetail : GApiResponse.NearBy?
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var polypath = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer?
    var restaurentPhotosArray: [String]?
    var placeDetails : GApiResponse.PlaceInfo?
    
    // MARK: - ViewController life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: nil, action: nil)
        self.title = "Direction"
        self.view.backgroundColor = .white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CreateDesign()
        getPlaceDetails(placeId: restaurentDetail?.placeId ?? "")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    // MARK: - Get current Location coordinates
    @objc func getCurrentlocCordinates(){
        
        LocationService.shared.trackLocation { [self] (lat, long) in
            CATransaction.begin()
            CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
            let city = GMSCameraPosition.camera(withLatitude: lat,longitude: long, zoom: 12)
            self.mapView.animate(to: city)
            CATransaction.commit()
            var location = GLocation()
            location.latitude = lat
            location.longitude = long
            self.polyLinePathApi(sourcelocation: location)
            print(lat,long)
        }
    }
    // MARK: - Get restarent Details from Google API
    func getPlaceDetails(placeId:String)
    {
        if isConnectedToInternet() {
            showActivity()
            var input = GInputParams()
            input.keyword = placeId
            GoogleApi.shared.callApi(.placeInformation,input: input) { (response) in
                if let place =  response.data as? GApiResponse.PlaceInfo, response.isValidFor(.placeInformation) {
                    // create dispatch source that will handle events on main queue
                    DispatchQueue.main.async {
                        self.placeDetails = place
                        self.imageCollectionView.reloadData()
                        if place.internationNumber != nil || place.phone != nil{
                            self.phoneNumberLable.text = "Phone : \(place.internationNumber ?? place.phone ?? "-")"
                        }
                        
                        
                    }
                    
                    
                } else { print(response.error ?? "ERROR") }
                
                self.setupLocation()
                self.getCurrentlocCordinates()
            }

            
        }else{
            
            let alertController = UIAlertController(title: Bundle.main.infoDictionary?["CFBundleName"] as? String, message: "The Internet connection appears to be offline.", preferredStyle: .alert)

            let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in

                
            }
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            
        }
      
    }
    // MARK: - Get PolyLine path from Google API
    func polyLinePathApi(sourcelocation:GLocation)
    {
        let positionSource = CLLocationCoordinate2DMake(sourcelocation.latitude ?? 0,sourcelocation.longitude ?? 0)
        let sourceMarker = GMSMarker(position: positionSource)
        sourceMarker.title = "Source"
        sourceMarker.map = mapView
        
        let positionDest = CLLocationCoordinate2DMake(restaurentDetail?.location.latitude ?? 0,restaurentDetail?.location.longitude ?? 0)
        let destinationMarker = GMSMarker(position: positionDest)
        destinationMarker.title = "Destination"
        destinationMarker.map = mapView
        
        
        var input = GInputParams()
        input.destinationCoordinate = restaurentDetail?.location
        input.originCoordinate = sourcelocation
        GoogleApi.shared.callApi(.path , input: input) { (response) in
            if let path = response.data as? GApiResponse.Path, response.isValidFor(.path) {
                
                if path.points != "" {
                    // create dispatch source that will handle events on main queue
                    DispatchQueue.main.async {
                        print(path.points)
                        
                        self.drawPolyline(encodedString: path.points)
                        
                    }
                    
                }
                
            } else { print(response.error ?? "ERROR") }
            hideActivity()
        }
        
    }
    // MARK: - Draw PolyLine set animation timer
    func drawPolyline(encodedString:String)
    {
        self.polypath = GMSPath.init(fromEncodedPath: encodedString)!
        
        self.polyline.path = self.polypath
        self.polyline.strokeColor = UIColor.systemBlue //UIColor(red: 0, green: 0, blue: 255, alpha: 0.5)
        self.polyline.strokeWidth = 5.0
        self.polyline.map = self.mapView
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.003, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
        
    }
    // MARK: - PolyLine creating with animation
    @objc func animatePolylinePath() {
        if (self.i < self.polypath.count()) {
            self.animationPath.add(self.polypath.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.systemGreen
            self.animationPolyline.strokeWidth = 5
            self.animationPolyline.map = self.mapView
            self.i += 1
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
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
            print("restricted")
            hideActivity()
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
    // MARK: - Create needed UI Components
    func CreateDesign()
    {
        let camera = GMSCameraPosition.camera(withLatitude: restaurentDetail?.location.latitude ?? 0, longitude: restaurentDetail?.location.longitude ?? 0, zoom: 12)
        let naviBottom = self.navigationController?.navigationBar.frame.maxY ?? 0
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: naviBottom).isActive = true
        mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: SCREEN_HEIGHT-(280+naviBottom)).isActive = true
        
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 0).isActive = true
        containerView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 0).isActive = true
        containerView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        //imageCollectionView
        containerView.addSubview(imageCollectionView)
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        imageCollectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        imageCollectionView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        imageCollectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        
        
        //restaurentNameLabel
        containerView.addSubview(restaurentNameLabel)
        restaurentNameLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurentNameLabel.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 5).isActive = true
        restaurentNameLabel.leftAnchor.constraint(equalTo: imageCollectionView.leftAnchor, constant: 10).isActive = true
        restaurentNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        
        //ratingStackView
        containerView.addSubview(ratingStackView)
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.leftAnchor.constraint(equalTo: restaurentNameLabel.leftAnchor).isActive = true
        ratingStackView.topAnchor.constraint(equalTo: restaurentNameLabel.bottomAnchor, constant: 5).isActive = true
        ratingStackView.rightAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 10).isActive = true
        
        // ratingStackView.rightAnchor.constraint(equalTo: restaurentNameLabel.rightAnchor, constant: 0).isActive = true
        
        
        //storeRatingAvglbl
        ratingStackView.addArrangedSubview(storeRatingAvglbl)
        storeRatingAvglbl.translatesAutoresizingMaskIntoConstraints = false
        storeRatingAvglbl.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor, constant: 0).isActive = true
        
        storeRatingAvglbl.leftAnchor.constraint(equalTo: ratingStackView.leftAnchor, constant: 0).isActive = true
        
        //ratingView
        ratingStackView.addArrangedSubview(ratingView)
        ratingView.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor, constant: 10).isActive = true
        ratingView.leftAnchor.constraint(equalTo: storeRatingAvglbl.rightAnchor, constant: 5).isActive = true
        ratingView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //storeTotalRatinglbl
        ratingStackView.addArrangedSubview(storeTotalRatinglbl)
        storeTotalRatinglbl.translatesAutoresizingMaskIntoConstraints = false
        storeTotalRatinglbl.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor, constant: 0).isActive = true
        storeTotalRatinglbl.leftAnchor.constraint(equalTo: ratingView.rightAnchor, constant: 5).isActive = true
        
        
        //openNowLable
        containerView.addSubview(openNowLable)
        openNowLable.translatesAutoresizingMaskIntoConstraints = false
        openNowLable.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 5).isActive = true
        openNowLable.leftAnchor.constraint(equalTo: ratingStackView.leftAnchor, constant: 0).isActive = true
        
        
        
        //foodOrderType
        containerView.addSubview(foodOrderType)
        foodOrderType.translatesAutoresizingMaskIntoConstraints = false
        foodOrderType.centerYAnchor.constraint(equalTo: openNowLable.centerYAnchor, constant: 0).isActive = true
        foodOrderType.leftAnchor.constraint(equalTo: openNowLable.rightAnchor, constant: 5).isActive = true
        
        //phoneNumberLable
        
        containerView.addSubview(phoneNumberLable)
        phoneNumberLable.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberLable.centerYAnchor.constraint(equalTo: openNowLable.centerYAnchor, constant:0).isActive = true
        phoneNumberLable.leftAnchor.constraint(equalTo: foodOrderType.rightAnchor, constant: 5).isActive = true
        
        //fullAddressLabel
        containerView.addSubview(fullAddressLabel)
        fullAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        fullAddressLabel.topAnchor.constraint(equalTo: openNowLable.bottomAnchor, constant: 5).isActive = true
        fullAddressLabel.leftAnchor.constraint(equalTo: openNowLable.leftAnchor, constant: 0).isActive = true
        fullAddressLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        
        self.restaurantSetValue = restaurentDetail
    }
    
    private let restaurentNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        
        return lbl
    }()
    
    private let foodOrderType : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        
        return lbl
    }()
    private let storeRatingAvglbl : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    private let storeTotalRatinglbl : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    lazy var ratingStackView : UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 5
        return stackView
    }()
    private let ratingView : CosmosView = {
        let cosmosViewFull = CosmosView()
        cosmosViewFull.settings.starSize = 20
        cosmosViewFull.settings.fillMode = .half
        cosmosViewFull.rating = 0
        cosmosViewFull.isUserInteractionEnabled = false
        cosmosViewFull.settings.filledBorderColor = UIColor.clear
        cosmosViewFull.settings.emptyBorderColor = UIColor.lightGray
        cosmosViewFull.settings.filledColor = UIColor.systemYellow
        
        return cosmosViewFull
    }()
    
    private let fullAddressLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textAlignment = .left
        lbl.numberOfLines = 3
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    private let openNowLable : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .systemGreen
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    private let phoneNumberLable : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .systemGray
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    private let pageController:UIPageControl = {
        
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .systemGray
        pageControl.pageIndicatorTintColor = .systemGray
        return pageControl
    }()
    
    lazy var imageCollectionView : UICollectionView = {
        
        // TODO: need to setup collection view flow layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 125, height: 125)
        
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 5.0
        let collectionview = UICollectionView(frame:CGRect.zero , collectionViewLayout: flowLayout)
        
        collectionview.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionview.isScrollEnabled = true
        collectionview.dataSource = self
        collectionview.delegate = self
        
        return collectionview
    }()
    
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        return containerView
    }()
    
    // MARK: - Assign values to restaurent respective fields
    var restaurantSetValue : GApiResponse.NearBy? {
        didSet {
            restaurentNameLabel.text = restaurantSetValue?.formattedAddress
            if restaurantSetValue?.rating != nil {
                storeRatingAvglbl.text = String(restaurantSetValue?.rating ?? 0) + ".0"
                ratingView.rating = Double(restaurantSetValue?.rating ?? 0)
                
            }else{
                storeRatingAvglbl.text = String(restaurantSetValue?.ratingFloat ?? 0)
                ratingView.rating = Double(restaurantSetValue?.ratingFloat ?? 0)
                
            }
            storeTotalRatinglbl.text = "(" + String(restaurantSetValue?.user_ratings_total ?? 0) + ")"
            
            if restaurantSetValue?.open_now  == 1 {
                openNowLable.text = "Open Now"
                openNowLable.textColor = .systemGreen
            }else{
                openNowLable.text = "Closed"
                openNowLable.textColor = .systemRed
            }
            
            var orderTypes = ""
            
            if restaurantSetValue?.types?.count ?? 0>0 {
                
                if restaurantSetValue!.types!.contains("meal_takeaway"){
                    
                    orderTypes = "Takeaway"
                }
                
                if restaurantSetValue!.types!.contains("meal_delivery") {
                    
                    if orderTypes != "" {
                        orderTypes = "Takeaway" + " • " + "Delivery"
                        
                    }else{
                        orderTypes =  "Delivery"
                        
                    }
                    
                }
            }
            
            
            foodOrderType.text = orderTypes
            fullAddressLabel.text = restaurantSetValue?.description
            pageController.numberOfPages = restaurantSetValue?.photo_reference.count ?? 0
            
        }
        
        
        
    }
    
}
// MARK: - CollectionView Delegates and DataSource methods
extension RestaurantsDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.placeDetails?.photo_reference.count ?? 0 > 0 {
            return self.placeDetails?.photo_reference.count ?? 0
        }
        return  1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    // Set the data for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Cell", for: indexPath as IndexPath)
        
        for lbl in cell.contentView.subviews {
            
            lbl.removeFromSuperview()
            
        }
        
        let CateImg = UIImageView()
        cell.contentView.addSubview(CateImg)
        CateImg.contentMode  = .scaleToFill
        CateImg.layer.cornerRadius = 10
        CateImg.layer.masksToBounds = true
        CateImg.anchor(top: cell.contentView.topAnchor, left: cell.contentView.leftAnchor, bottom: cell.contentView.bottomAnchor, right: cell.contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 140, height: 140, enableInsets: false)
        
        if self.placeDetails?.photo_reference.count ?? 0 > 0 {
            
            let photo_Reference = self.placeDetails?.photo_reference[indexPath.row]
            CateImg.image = UIImage.init(named: "no_Image")
            
            let imageUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photo_Reference ?? "")&key=\(GoogleApi.shared.googleApiKey)"
            CateImg.sd_setImage(with: URL(string:imageUrl), placeholderImage: UIImage(named: "no_Image"))
            
        }else{
            
            CateImg.image = UIImage.init(named: "no_Image")
            
            
        }

        return cell
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
}
