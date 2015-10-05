//
//  UserHomeVC.swift
//  Sales Whip Server
//
//  Created by Arun on 8/19/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation
import MapKit

//delegate method 
protocol AddDealsLocationDelegate {
    //func controller(controller: AddItemViewController, didAddItem: String)
    func changeAddLocationButtonStateToSelected(loc : CLLocationCoordinate2D)
}

class AddDealsLocationVC: UIViewController , MKMapViewDelegate,CLLocationManagerDelegate{
    
    var delegate: AddDealsLocationDelegate?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var apiKey: String?
    var places = [Place]()
    var placeType: PlaceType = .All
    var locationBias: LocationBias?
    //var delegate: GooglePlacesAutocompleteDelegate?
    var placeMarker = GMSMarker()

    @IBOutlet weak var mapView: MKMapView!
    //location object
    var manager:CLLocationManager = CLLocationManager()
    let annotation = CustomPointAnnotation()
    var dealsPrevLoc = PFGeoPoint()
    var locationAdded = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show previous location if any
        apiKey = googlePlacesOfficialKey

        if !locationAdded {
            var latitude: CLLocationDegrees = dealsPrevLoc.latitude
            var longtitude: CLLocationDegrees = dealsPrevLoc.longitude
            
            var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)

            annotation.coordinate = locationCoordinate
            annotation.title = "New Deal"
            annotation.subtitle = "India"
            annotation.imageName = "food"
            mapView.addAnnotation(annotation)
            mapView.delegate = self

            locationAdded = true;

        }
        //on long press add location
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "revealRegionDetailsWithLongPressOnMap:"))

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if iOS8 {
            manager.requestWhenInUseAuthorization()
        }
        
        manager.startUpdatingLocation()
        var loc : CLLocation  = CLLocation(latitude: +28.63148846, longitude: +77.07574058);
        let location = CLLocationCoordinate2D(
            latitude: +28.63148846,
            longitude: +77.07574058
        )
        //let loc = CLLocation(latitude: 21.282778, longitude: -157.829444)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        centerMapOnLocation(loc)

        mapView.delegate = self
        
//annotation view and pin of current location
        var annotationCrntLoc = MKPointAnnotation()
        annotationCrntLoc.coordinate = location
        annotationCrntLoc.title = "Current Location"
        annotationCrntLoc.subtitle = "India"
        mapView.addAnnotation(annotationCrntLoc)
        
        tableView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.8)
    }
    //set that deals location is added by admin once
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var seguePopVc = segue.destinationViewController as! AddDealsVC
        seguePopVc.addLocationButton.selected = true
    }
    //anotation view manipulation
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.title == "Current Location" {
            var annotatiobView : MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotatiobView.image = UIImage(named: "star")
            annotatiobView.canShowCallout = true
            return annotatiobView
        }
        var annotatiobView : MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotatiobView.image = UIImage(named: "food")
        annotatiobView.canShowCallout = true
        return annotatiobView
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations.count > 0 {
            self.manager.stopUpdatingLocation()
            let loc : CLLocation = locations[0] as! CLLocation
            //currentuser["location"] = loc

            //currentuser["location"] = PFGeoPoint(location: loc)
            //zsrself.centerMapOnLocation(location)
        }
    }
//zoom in(<1000), zoom out(>1000) map region
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //on long press on anotation view show the deatail
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        let touchLocation = sender.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
        annotation.coordinate = locationCoordinate
        annotation.title = "New Deal"
        annotation.subtitle = "India"
        annotation.imageName = "food"
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        locationAdded = true;
        self.delegate?.changeAddLocationButtonStateToSelected(locationCoordinate)
    }
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        
    }
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        
    }
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        
    }
    
    // MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
    //extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView()
        return view
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        return view
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 5 {
            return 3
        }
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // Get the corresponding candy from our candies array
        let place = self.places[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        //cell.textLabel?.font = fontRg14
        // Configure the cell
        cell.textLabel!.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var placeObj : Place = (self.places[indexPath.row] as! Place)
        showPlacesInMap(placeObj.id)
        self.searchBar.endEditing(true)
    }
    // MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
    //extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.places = []
            tableView.hidden = true
        } else {
            getPlaces(searchText)
        }
        //self.mapContView.bringSubviewToFront(self.tableView)
        self.view.bringSubviewToFront(self.tableView)
        self.view.bringSubviewToFront(self.searchBar)
        //self.tableView.hidden = false
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    private func getPlaces(searchString: String) {
        var params = [
            "input": searchString,
            "types": placeType.description,
            "key": apiKey ?? ""
        ]
        
        if let bias = locationBias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
            ) { json in
                if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                    self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
                        return Place(prediction: prediction, apiKey: self.apiKey)
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.hidden = false
                    //self.delegate?.placesFound?(self.places)
                }
        }
    }
    //}
    //MARK: - show place in map
    func showPlacesInMap(placeId : String) {
        //self.mapView.clear()
        
        var placeClient = GMSPlacesClient()
        self.placeMarker = GMSMarker()
        
        placeClient.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            if error == nil {
                
                var placeCoordinate = place?.coordinate
                var camera = GMSCameraPosition.cameraWithLatitude(placeCoordinate!.latitude,
                    longitude: placeCoordinate!.longitude, zoom: 5)
                if self.mapView.superview == nil {
                    
                    // self.mapContView = self.mapView
                }
//                CATransaction.begin()
//                CATransaction.setValue(NSNumber(float: 3), forKey: kCATransactionAnimationDuration)
//                //self.mapView.animateToCameraPosition(camera)
//                //self.mapView.animateWithCameraUpdate(GMSCameraUpdate.setCamera(camera))
//                CATransaction.commit()
                
                                self.annotation.title = "New Deal"
                self.annotation.subtitle = "India"
                CATransaction.begin()
                CATransaction.setValue(NSNumber(float: 3), forKey: kCATransactionAnimationDuration)
                UIView.animateWithDuration(3, animations: { () -> Void in
                    self.annotation.coordinate = place!.coordinate
                    self.annotation.imageName = "food"
                    self.mapView.delegate = self

                    self.mapView.addAnnotation(self.annotation)
                    self.mapView.setCenterCoordinate(place!.coordinate, animated: true)
                })

                CATransaction.commit()
                
                self.locationAdded = true;
                self.delegate?.changeAddLocationButtonStateToSelected(place!.coordinate)

                // self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
                //self.tableView.hidden = true
                //self.mapView.hidden = false
                self.view.bringSubviewToFront(self.mapView)
                self.view.bringSubviewToFront(self.searchBar)
                
                //self.mapContView.bringSubviewToFront(self.mapView)
                //self.view.bringSubviewToFront(self.searchBar)
                
                self.searchBar.text = place!.name
                
            
        }
        
    })
    }
    
    // MARK: - GooglePlaceDetailsRequest
    class GooglePlaceDetailsRequest {
        let place: Place
        
        init(place: Place) {
            self.place = place
        }
        
        func request(result: PlaceDetails -> ()) {
            GooglePlacesRequestHelpers.doRequest(
                "https://maps.googleapis.com/maps/api/place/details/json",
                params: [
                    "placeid": place.id,
                    "key": place.apiKey ?? ""
                ]
                ) { json in
                    result(PlaceDetails(json: json as! [String: AnyObject]))
            }
        }
    }
    
    // MARK: - GooglePlacesRequestHelpers
    class GooglePlacesRequestHelpers {
        /**
        Build a query string from a dictionary
        
        :param: parameters Dictionary of query string parameters
        :returns: The properly escaped query string
        */
        private class func query(parameters: [String: AnyObject]) -> String {
            var components: [(String, String)] = []
            for key in sorted(Array(parameters.keys), <) {
                let value: AnyObject! = parameters[key]
                components += [(escape(key), escape("\(value)"))]
            }
            
            return join("&", components.map{"\($0)=\($1)"} as [String])
        }
        
        private class func escape(string: String) -> String {
            let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
            return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
        }
        
        private class func doRequest(url: String, params: [String: String], success: NSDictionary -> ()) {
            var request = NSMutableURLRequest(
                URL: NSURL(string: "\(url)?\(query(params))")!
            )
            
            var session = NSURLSession.sharedSession()
            var task = session.dataTaskWithRequest(request) { data, response, error in
                self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error, success: success)
            }
            
            task.resume()
        }
        
        private class func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!, success: NSDictionary -> ()) {
            if let error = error {
                println("GooglePlaces Error: \(error.localizedDescription)")
                return
            }
            
            if response == nil {
                println("GooglePlaces Error: No response from API")
                return
            }
            
            if response.statusCode != 200 {
                println("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
                return
            }
            
            var serializationError: NSError?
            var json: NSDictionary = NSJSONSerialization.JSONObjectWithData(
                data,
                options: NSJSONReadingOptions.MutableContainers,
                error: &serializationError
                ) as! NSDictionary
            
            if let error = serializationError {
                println("GooglePlaces Error: \(error.localizedDescription)")
                return
            }
            
            if let status = json["status"] as? String {
                if status != "OK" {
                    println("GooglePlaces API Error: \(status)")
                    return
                }
            }
            
            // Perform table updates on UI thread
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                success(json)
            })
        }
        
    }

}