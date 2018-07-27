//
//  MapController.swift
//  TravelEntertainment
//
//  Created by Divya Godayal on 4/25/18.
//  Copyright © 2018 Divya Godayal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsDirections

class MapController: UIViewController, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate{
    
    
    @IBOutlet var viewForMap: GMSMapView!
    var fromLat: Double?
    var fromLong: Double?
    var originPlace: GMSPlace?
    var destinationPlaceID: String?
    var previousPolyline: GMSPolyline?
    var originMarker: GMSMarker?
    var isCustomLocationProvided = false
    var directionType: GoogleMapsDirections.TravelMode = .driving
    @IBOutlet var fromTextField: UITextField?
    
    @IBAction func directionSegmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0: self.directionType = .driving
                break
           
        case 1: self.directionType = .bicycling
                break
           
        case 2: self.directionType = .transit
                break
           
        case 3: self.directionType = .walking
                break
          
        default:
                break
        }
        directionsDiplay()
    }
    
    func showPath(polyStr :String){
        previousPolyline?.map  = nil
        
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        previousPolyline = polyline
        polyline.strokeWidth = 3.0
        polyline.map = viewForMap // Your map view
        
        
        var bounds = GMSCoordinateBounds()
        
        for index in 1...path!.count() {
            bounds = bounds.includingCoordinate((path?.coordinate(at: index))!)
        }
        
        viewForMap.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    func directionsDiplay(){
        
        let origin = GoogleMapsDirections.Place.coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: (self.originPlace?.coordinate.latitude)!, longitude: (self.originPlace?.coordinate.longitude)!)) //.placeID(id: self.destinationPlaceID!)
        let destination = GoogleMapsDirections.Place.coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: placeDetail.coordinate.latitude, longitude: placeDetail.coordinate.longitude))//GoogleMapsDirections.Place.placeID(id: placeDetail.placeID)
        GoogleMapsDirections.direction(fromOrigin: origin, toDestination: destination, travelMode: directionType) { (response, error) -> Void in
            // Check Status Code
            guard response?.status == GoogleMapsDirections.StatusCode.ok else {
                // Status Code is Not OK
                debugPrint(response?.errorMessage)
                return
            }
            
            // Use .result or .geocodedWaypoints to access response details
            // response will have same structure as what Google Maps Directions API returns
            debugPrint("it has \(response?.routes.count ?? 0) routes")
            let routes = response?.routes
            let route = routes?[0]
            let polyString = route?.overviewPolylinePoints as? String
            
            //Call this method to draw path on map
            self.showPath(polyStr: polyString!)
        }}
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        originMarker?.map = nil
        fromLat = place.coordinate.latitude
        fromLong = place.coordinate.longitude
        self.destinationPlaceID = place.placeID
        isCustomLocationProvided = true
        fromTextField?.text =  place.name
        
        // Setting the marker to the from location
        let marker = GMSMarker(position: place.coordinate)
        originMarker = marker
        marker.title = place.name
        marker.map = self.viewForMap
        self.originPlace = place
        
        //showing the direction
        directionsDiplay()
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hello Map"
        
        let camera = GMSCameraPosition.camera(withLatitude: placeDetail.coordinate.latitude, longitude: placeDetail.coordinate.longitude, zoom: 12.0)
        
        let marker = GMSMarker(position: placeDetail.coordinate)
        marker.title = placeDetail.name
        marker.map = self.viewForMap
        self.viewForMap.camera = camera
        
    }
    
    @IBAction func autoCompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
}



