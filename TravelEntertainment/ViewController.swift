//
//  ViewController.swift
//  TravelEntertainment
//
//  Created by Divya Godayal on 4/20/18.
//  Copyright © 2018 Divya Godayal. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

var favoritesData: Dictionary<String, Any> = [:]

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var favsTable: UITableView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        switch(segmentedControl.selectedSegmentIndex)
        {
        case 0: self.view.viewWithTag(20)?.isHidden = true
                break
        case 1: self.view.viewWithTag(20)?.isHidden = false
        let tableView = (self.view.viewWithTag(20) as! UITableView)
        if (favoritesData.count == 0) {
            
            tableView.reloadData()
            let emptyStateLabel = UILabel(frame: tableView.frame)
            emptyStateLabel.text = "No Favorites"
            emptyStateLabel.textAlignment = NSTextAlignment.center
            tableView.backgroundView = emptyStateLabel
            tableView.tableFooterView = UIView()
        }
        else{
            tableView.backgroundView = nil
            tableView.reloadData()
        }
        
        tableView.reloadData()
                break
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(favoritesData.count)
        return (favoritesData.count)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! resultsCell
        let placeID = Array(favoritesData.keys)[indexPath.row]
        
        let place = favoritesData[placeID] as! Dictionary<String, Any>
        
        cell.name.text = place["name"] as? String
        cell.address.text = place["address"] as? String
        cell.resultsImage?.image = place["image"] as? UIImage
        cell.hiddenPlaceID.text = placeID
        cell.hiddenPlaceID.isHidden = true
        cell.favsButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let tableViewCell = tableView.cellForRow(at: indexPath) as! resultsCell
        
        if editingStyle == .delete {
            favoritesData.removeValue(forKey: tableViewCell.hiddenPlaceID.text!)

            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if (favoritesData.count == 0) {
                let emptyStateLabel = UILabel(frame: tableView.frame)
                emptyStateLabel.text = "No Favorites"
                emptyStateLabel.textAlignment = NSTextAlignment.center
                tableView.backgroundView = emptyStateLabel
                tableView.tableFooterView = UIView()
            }
            
        }
    }
    
    // MARK: Properties
    
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView! = UIPickerView()
    @IBOutlet weak var categoryTextFiled: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet var fromTextField: UITextField?
    
    var locationManager:CLLocationManager!
    var currentLat: Double?
    var currentLong: Double?
    var customLat: Double?
    var customLong: Double?
    var isCustomLocationProvided = false
    
    var categories = ["Default", "Accounting", "Airport", "Amusement_Park", "Aquarium", "Art_Gallery", "Atm", "Bakery", "Bank", "Bar", "Beauty_Salon", "Bicycle_Store", "Book_Store", "Bowling_Alley", "Bus_Station", "Cafe", "Campground", "Car_Dealer", "Car_Rental", "Car_Repair", "Car_Wash", "Casino", "Cemetery", "Church", "City_Hall", "Clothing_Store", "Convenience_Store", "Courthouse", "Dentist", "Department_Store", "Doctor", "Electrician", "Electronics_Store", "Embassy", "Fire_Station", "Florist", "Funeral_Home", "Furniture_Store", "Gas_Station", "Gym", "Hair_Care", "Hardware_Store", "Hindu_Temple", "Home_Goods_Store", "Hospital", "Insurance_Agency", "Jewelry_Store", "Laundry", "Lawyer", "Library", "Liquor_Store", "Local_Government_Office", "Locksmith", "Lodging", "Meal_Delivery", "Meal_Takeaway", "Mosque", "Movie_Rental", "Movie_Theater", "Moving_Company", "Museum", "Night_Club", "Painter", "Park", "Parking", "Pet_Store", "Pharmacy", "Physiotherapist", "Plumber", "Police", "Post_Office", "Real_Estate_Agency", "Restaurant", "Roofing_Contractor", "Rv_Park", "School", "Shoe_Store", "Shopping_Mall", "Spa", "Stadium", "Storage", "Store", "Subway_Station", "Supermarket", "Synagogue", "Taxi_Stand", "Train_Station", "Transit_Station", "Travel_Agency", "Veterinary_Care", "Zoo"]
    
   
    @IBAction func clearAction(_ sender: UIButton) {
        self.keywordTextField.text = ""
        self.categoryTextFiled.text = "Default"
        self.fromTextField?.text = "Your Location"
        isCustomLocationProvided = false
        self.distanceTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favsTable.delegate = self
        self.favsTable.dataSource = self
        // Connect data:
        self.view.viewWithTag(20)?.isHidden = true
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self as UIPickerViewDataSource
        categoryPicker.isHidden = true;
        categoryTextFiled.text = categories[0]
        
        // To get the current location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    

        if(segue.identifier == "resultsSegue"){
            var Distance = distanceTextField.text
            if(distanceTextField.text == ""){
                Distance = "10"
            }
            
            var coordinate: Any
            var location: String
            
            if(isCustomLocationProvided){
                coordinate = ["lat":customLat,"lng":customLong]
                location = "custom-location"
            }
            else{
                coordinate = ["lat":currentLat,"lng":currentLong]
                location = "current-location"
            }
            
            let data = [
                "formData": [
                    "category": ["id":categoryTextFiled.text as Any,
                                 "name":categoryTextFiled.text as Any],
                    "location": location,
                    "keyword": keywordTextField.text as Any,
                    "distance": Distance as Any,
                    "customLocationCoordinates": coordinate,
                    "customLocation": fromTextField?.text as Any
                ],
                "currentLocation": coordinate,
                
                ]
            if let resultsController = segue.destination as? ResultsController {
                resultsController.data = data
            }
        }
        
        
        if(segue.identifier == "showFavDetail"){
            if let navController = segue.destination as? UINavigationController {
                let detailController = navController.viewControllers.first as? UITabBarController
                var cell = sender as! resultsCell
                
                place_id_global = cell.hiddenPlaceID.text!
                //setting the title in the navigation bar
                navController.navigationBar.topItem?.title = cell.name.text
                
                let navigationItems = navController.navigationBar.items![0]
                
                let favButton = navigationItems.rightBarButtonItems![0]
                if(favoritesData[place_id_global] != nil){
                    favButton.image = UIImage(named: "Favorite_Filled.png")
                }
                else{
                    favButton.image = UIImage(named: "Favorite_Empty.png")
                }
                
                //back button click
                navigationItems.leftBarButtonItems![0].action =   #selector(backButtonClick)
                

                (detailController?.viewControllers![0] as! PlaceDetailController).placeID = place_id_global
                (detailController?.viewControllers![1] as! PhotosController).placeID = place_id_global
            }
        }
    }
    
    @IBAction func backButtonClick() {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    // Current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        currentLat = locValue.latitude
        currentLong = locValue.longitude
    }
    
    // MARK : Actions
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        categoryTextFiled.text = categories[row]
        categoryPicker.isHidden = true;
    }

    @IBAction func textFieldShouldEdit(_ sender: UITextField) {
        categoryPicker.isHidden = false
    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @IBAction func autoCompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func autoCompleteFunc(place: GMSPlace){
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        customLat = place.coordinate.latitude
        customLong = place.coordinate.longitude
        isCustomLocationProvided = true
        fromTextField?.text = place.name
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        autoCompleteFunc(place: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


