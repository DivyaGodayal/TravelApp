//
//  PlaceDetailController.swift
//  TravelEntertainment
//
//  Created by Divya Godayal on 4/24/18.
//  Copyright © 2018 Divya Godayal. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces

class CollectionImageCell: UICollectionViewCell{
    @IBOutlet var photoView: UIImageView!
}

class PhotosController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var imagesCollectionView: UICollectionView!
    var placeID: String?
    var photoResults: [GMSPlacePhotoMetadata]?
    
    override func viewDidLoad() {
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        
        self.loadFirstPhotoForPlace(placeID: placeID!)
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if (photos?.results.first) != nil {
                    self.photoResults = photos?.results
                    DispatchQueue.main.async {
                        self.imagesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.photoResults == nil){
            return 0
        }
        else{
            return (self.photoResults?.count)!
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionImage",
                                                      for: indexPath) as! CollectionImageCell
        //load meta data
        GMSPlacesClient.shared().loadPlacePhoto(self.photoResults![indexPath.row], callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                cell.photoView.image = photo;
                // self.attributionTextView.attributedText = photoMetadata.attributions;
            }
        })
        return cell
    }
    
}

