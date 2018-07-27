//
//  ResultsController.swift
//  TravelEntertainment
//
//  Created by Divya Godayal on 4/21/18.
//  Copyright © 2018 Divya Godayal. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireImage
import SwiftSpinner


var place_id_global = ""
var name_global:String = ""
var address_global:String = ""
var image_global:Any?

var favsButtonNav: UIBarButtonItem!

class resultsCell : UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet var resultsImage: UIImageView!
    @IBOutlet var hiddenPlaceID: UILabel!
    @IBOutlet var favsButton: UIButton!
    @IBAction func upadteFavorites(_ sender: UIButton) {
        
        let place_id = hiddenPlaceID.text
        print(favoritesData[place_id!] != nil)
        if (favoritesData[place_id!] != nil) {
            favsButton.setImage(UIImage(named: "Favorite_Empty.png"), for: UIControlState.normal)
            favoritesData.removeValue(forKey: place_id!)
           
        } else {
            favsButton.setImage(UIImage(named: "Favorite_Filled.png"), for: UIControlState.normal)
            favoritesData[place_id!] = ["name": name.text!, "address": address.text!, "image": resultsImage.image as Any]
        }
    }
    
}

class ResultsController: UITableViewController{
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    var data:Any?
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var placesData: [Dictionary<String,String>]?
    var twitterURL: String?
    
    // back button functionality
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
 
    func getSearchResults(searchTerm: String) {
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: "http://dg-webapp.appspot.com/api/search") {
            urlComponents.query = searchTerm
            guard let url = urlComponents.url else { return }
            print(url)
            dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!)
                }
                else{
                    if let urlContent = data{
                        do{
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                            self.placesData = (jsonResult["nearbyPlaces"] as! [Dictionary<String, String>])
                            SwiftSpinner.hide()
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        catch{
                            print("JSON parsing failed")
                        }
                    }
                }
            }
            // 7
            dataTask?.resume()
        }
    }
    
    func jsonToString(json: Any) -> String{
        let data =  try! JSONSerialization.data(withJSONObject: json, options: [])
        return String(data:data, encoding:.utf8)!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if(segue.identifier == "placesDetailSegue"){
            if let navController = segue.destination as? UINavigationController {
                let detailController = navController.viewControllers.first as? UITabBarController
                var indexPathRow = self.tableView.indexPath(for: sender as! resultsCell)
                
                place_id_global = self.placesData![indexPathRow!.row]["place_id"]!
                //setting the title in the navigation bar
                navController.navigationBar.topItem?.title = self.placesData![indexPathRow!.row]["name"]
                
                let navigationItems = navController.navigationBar.items![0]
                
                //back button click
                 navigationItems.leftBarButtonItems![0].action =   #selector(backButtonClick)
                
                //forward click
                var website = ""
                
                var name = self.placesData![indexPathRow!.row]["name"]
                var address = self.placesData![indexPathRow!.row]["address"]
                if let web = self.placesData![indexPathRow!.row]["website"]{
                    website = web + self.placesData![indexPathRow!.row]["website"]!
                }
                self.twitterURL = "https://twitter.com/intent/tweet?"
                var query = "text=Check out "
                query = query + name!
                query = query + " located at "
                query = query + address!
                query = query + website
                    
//                + name + " located at " + address + ". Website: " + website
//
                self.twitterURL =  self.twitterURL! + query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                
                 navigationItems.rightBarButtonItems![1].action =   #selector(twitterButtonClick)
                
                
                //Alamofire code for images
                Alamofire.request(self.placesData![indexPathRow!.row]["category"]!).responseImage { response in
                    if let image = response.result.value {
                        image_global = image
                    }
                }
                name_global = name!
                address_global = address!
                
                
                let favButton = navigationItems.rightBarButtonItems![0]
                if(favoritesData[place_id_global] != nil){
                    favButton.image = UIImage(named: "Favorite_Filled.png")
                }
                else{
                    favButton.image = UIImage(named: "Favorite_Empty.png")
                }
                 navigationItems.rightBarButtonItems![0].action =   #selector(favButtonClick)
                 favsButtonNav = navigationItems.rightBarButtonItems![0]
                
                (detailController?.viewControllers![0] as! PlaceDetailController).placeID = self.placesData![indexPathRow!.row]["place_id"]
                (detailController?.viewControllers![1] as! PhotosController).placeID = self.placesData![indexPathRow!.row]["place_id"]
            }
        }
    }

    @IBAction func backButtonClick() {
       self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func favButtonClick() {
        
        let place_id = place_id_global
        print(favoritesData[place_id] != nil)
        if (favoritesData[place_id] != nil) {
            favsButtonNav.image = UIImage(named: "Favorite_Empty.png")
//            favsButtonNav.setImage(UIImage(named: "Favorite_Empty.png"), for: UIControlState.normal)
            favoritesData.removeValue(forKey: place_id)
            
        } else {
            favsButtonNav.image = UIImage(named: "Favorite_Filled.png")
//            favsButtonNav.setImage(UIImage(named: "Favorite_Filled.png"), for: UIControlState.normal)
            favoritesData[place_id] = ["name": name_global, "address": address_global, "image": image_global]
        }
        
    }
    
    
    @IBAction func twitterButtonClick() {
        print(self.twitterURL!)
        if let url = URL(string: self.twitterURL!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    override func viewDidLoad() {
        SwiftSpinner.show("Searching...")
        var cLocation: String = ""
        var fData: String = ""
        if let jsondata = data as? [String: Any], let currentLocation = jsondata["currentLocation"] as? [String: Any], let formData = jsondata["formData"] as? [String: Any]{
            cLocation = jsonToString(json: currentLocation)
            fData = jsonToString(json: formData)
        }
        
        getSearchResults(searchTerm: "currentLocation=\(cLocation)&formData=\(fData)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.placesData != nil){
            return (self.placesData!.count)

        }
        else{
            return 0        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! resultsCell
        let place = self.placesData![indexPath.row]
        cell.name.text = place["name"]
        cell.address.text = place["address"]
        
        cell.hiddenPlaceID.text = place["place_id"]
        
        if(favoritesData[cell.hiddenPlaceID.text!] != nil){
            cell.favsButton.setImage(UIImage(named: "Favorite_Filled.png"), for: UIControlState.normal)
        }
        else{
            cell.favsButton.setImage(UIImage(named: "Favorite_Empty.png"), for: UIControlState.normal)
        }
        
        //Alamofire code for images
        Alamofire.request(place["category"]!).responseImage { response in
            debugPrint(response)
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                cell.resultsImage?.image = image
            }
        }
        
        
        return cell
    }

}
