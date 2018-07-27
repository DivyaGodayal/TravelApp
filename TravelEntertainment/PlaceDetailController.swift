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

var placeDetail: GMSPlace!

class InfoCell : UITableViewCell{
    @IBOutlet var leftCol: UILabel!
    @IBOutlet var rightCol: UITextView!
}

class PlaceDetailController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableInfoView: UITableView!
    var placesClient: GMSPlacesClient!
    var placeID: String?
    var rowCount: Int = 5
    
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(placeDetail == nil){
            return 0
        }
        
        if(indexPath.row == 0)
        {
            if(placeDetail?.formattedAddress != nil){
                return 70
            }
        }
        else if(indexPath.row == 1)
        {
            if(placeDetail?.phoneNumber != nil){
                return 70
            }
        }
        else if(indexPath.row == 2)
        {
            if((placeDetail?.priceLevel.rawValue)! > 0){
                return 70
            }
        }
        else if(indexPath.row == 3)
        {
            if((placeDetail?.rating)! >= 0.0){
                return 70
            }
        }
        else if(indexPath.row == 4)
        {
            if(placeDetail?.website != nil){
                return 70
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
        if(placeDetail == nil){
              return cell
        }
        
        if(indexPath.row == 0)
        {
            cell.leftCol.text = "Address"
            cell.rightCol.text = placeDetail?.formattedAddress
        }
        else if(indexPath.row == 1)
        {
            cell.leftCol.text = "Phone Number"
            cell.rightCol.text = placeDetail?.phoneNumber
        }
        else if(indexPath.row == 2)
        {
            cell.leftCol.text = "Price Level"
            print(String(repeating: "$", count: placeDetail!.priceLevel.rawValue + 1))
            cell.rightCol.text =  String(repeating: "$", count: placeDetail!.priceLevel.rawValue + 1)
            
        }
        else if(indexPath.row == 3)
        {
            cell.leftCol.text = "Rating"
            cell.rightCol.text = String(placeDetail!.rating)
        }
        else if(indexPath.row == 4)
        {
            cell.leftCol.text = "Website"
            cell.rightCol.text = placeDetail?.website?.absoluteString

        }
        
        return cell
    }
    
    
    @IBAction func gestureLink(sender:UITapGestureRecognizer) {
        
        let searchlbl:UILabel = (sender.view as! UILabel)
        print(searchlbl.text!)
        if let url = URL(string: searchlbl.text!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    
    
  
    override func viewDidLoad() {
        tableInfoView.delegate = self
        tableInfoView.dataSource = self
        
        placesClient = GMSPlacesClient.shared()
        
        placesClient.lookUpPlaceID(self.placeID!, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details")
                return
            }
            placeDetail = place
            DispatchQueue.main.async {
                self.tableInfoView.reloadData()
            }
           
        })
    }
  
    
}


