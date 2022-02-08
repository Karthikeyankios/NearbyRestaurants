//
//  RestaurentTableCell.swift
//  NearbyRestaurants
//
//  Created by Karthikeyan K on 04/02/22.

import UIKit
import SDWebImage
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height


class RestaurentTableCell : UITableViewCell
{
    var restaurentPhotosArray: [String]?
    
    // MARK: - Assign values to restaurent respective fields
    var restaurantItem : GApiResponse.NearBy? {
        didSet {
            restaurentNameLabel.text = restaurantItem?.formattedAddress
            if restaurantItem?.rating != nil {
                storeRatingAvglbl.text = String(restaurantItem?.rating ?? 0) + ".0"
                ratingView.rating = Double(restaurantItem?.rating ?? 0)
                
            }else{
                storeRatingAvglbl.text = String(restaurantItem?.ratingFloat ?? 0)
                ratingView.rating = Double(restaurantItem?.ratingFloat ?? 0)
                
            }
            storeTotalRatinglbl.text = "(" + String(restaurantItem?.user_ratings_total ?? 0) + ")"
            
            if restaurantItem?.open_now  == 1 {
                openNowLable.text = "Open Now"
                openNowLable.textColor = .systemGreen
            }else{
                openNowLable.text = "Closed"
                openNowLable.textColor = .systemRed
            }
            
            var orderTypes = ""
            
            if restaurantItem?.types?.count ?? 0>0 {
                
                if restaurantItem!.types!.contains("meal_takeaway"){
                    
                    orderTypes = "Takeaway"
                }
                
                if restaurantItem!.types!.contains("meal_delivery") {
                    
                    if orderTypes != "" {
                        orderTypes = "Takeaway" + " • " + "Delivery"
                        
                    }else{
                        orderTypes =  "Delivery"
                        
                    }
                    
                }
            }
            
            
            foodOrderType.text = orderTypes
            fullAddressLabel.text = restaurantItem?.description
            
        }
        
        
        
    }
    
    // MARK: - Create needed UI Components
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
        collectionview.isPagingEnabled = true
        collectionview.dataSource = self
        collectionview.delegate = self
        
        return collectionview
    }()
    
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        return containerView
    }()
    
    
    // MARK: - Adding Subview to the tableCell in reuseIdentifier
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        selectionStyle = .none
        //containerView
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        //imageCollectionView
        containerView.addSubview(imageCollectionView)
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        imageCollectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        imageCollectionView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        imageCollectionView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        
        
        //restaurentNameLabel
        containerView.addSubview(restaurentNameLabel)
        restaurentNameLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurentNameLabel.topAnchor.constraint(equalTo: imageCollectionView.topAnchor, constant: 5).isActive = true
        restaurentNameLabel.leftAnchor.constraint(equalTo: imageCollectionView.rightAnchor, constant: 5).isActive = true
        restaurentNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        
        //ratingStackView
        containerView.addSubview(ratingStackView)
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.leftAnchor.constraint(equalTo: restaurentNameLabel.leftAnchor).isActive = true
        ratingStackView.topAnchor.constraint(equalTo: restaurentNameLabel.bottomAnchor, constant: 5).isActive = true
        ratingStackView.rightAnchor.constraint(equalTo: restaurentNameLabel.rightAnchor, constant: 0).isActive = true
        
        
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
        foodOrderType.leftAnchor.constraint(equalTo: openNowLable.rightAnchor, constant: 10).isActive = true
        
        //fullAddressLabel
        containerView.addSubview(fullAddressLabel)
        fullAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        fullAddressLabel.topAnchor.constraint(equalTo: openNowLable.bottomAnchor, constant: 5).isActive = true
        fullAddressLabel.leftAnchor.constraint(equalTo: openNowLable.leftAnchor, constant: 0).isActive = true
        fullAddressLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Collectionview DataSource assign
    func updateCellWith(row: [String]) {
        restaurentPhotosArray = row
        imageCollectionView.reloadData()
    }
    
}
// MARK: - CollectionView Delegates and DataSource methods
extension RestaurentTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.restaurentPhotosArray?.count ?? 0 > 0 {
            return self.restaurentPhotosArray?.count ?? 0
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
        
        if restaurentPhotosArray?.count ?? 0 > 0 {
            
            let photo_Reference = restaurentPhotosArray?[indexPath.row]
            //CateImg.image = UIImage.init(named: "no_Image")
            
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

