//
//  UserHomeVC.swift
//  Sales Whip Server
//
//  Created by Arun on 8/19/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation
import MapKit
enum MapType: Int {
    case Standard = 0
    case Hybrid
    case Satellite
}

class UserHomeVC: UIViewController , MKMapViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    //location object
    var manager:CLLocationManager = CLLocationManager()
    let annotation = MKPointAnnotation()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addLocationOfAllDealsOnMap()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "revealRegionDetailsWithLongPressOnMap:"))

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
//annotation view and pin
        annotation.coordinate = location
        annotation.title = "Current Location"
        annotation.subtitle = "India"
        mapView.addAnnotation(annotation)
        
    }
    //parse log out functionality
    @IBAction func logOutTapped(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if error == nil {
                self.performSegueWithIdentifier(K_USER_LOG_OUT, sender: self)
            }
        }
    }
    //load all deals on map using their location stored in parse
    func addLocationOfAllDealsOnMap() {
        
        var queryObjDeals = PFQuery(className: "AvailableDeals")
        //queryObjDeals.whereKey(l, equalTo: true)
        queryObjDeals.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                for var i = 0; i < objects!.count; i++ {
                    var object : PFObject = objects![i] as! PFObject
                    self.showDealsAnotationOnMap(object[location] as! PFGeoPoint, objPf: object)
                    
                }
            }
        }

        
    }
    //adjust view display of anotation view
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
    //set user current location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations.count > 0 {
            self.manager.stopUpdatingLocation()
            let loc : CLLocation = locations[0] as! CLLocation
            PFUser.currentUser()?.setObject(PFGeoPoint(location: loc), forKey: "location")
            //zsrself.centerMapOnLocation(location)
        }
    }
//map current region radius(zoom in(<1000), zoom out(>1000))
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func showDealsAnotationOnMap(pfLocGeo: PFGeoPoint, objPf : PFObject) {
//converting PFGeoPoint into CLLocationCoordinate2D for adding all deals location anotation
        var latitude: CLLocationDegrees = pfLocGeo.latitude
        var longtitude: CLLocationDegrees = pfLocGeo.longitude
        
        var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        
        var annotationNewDeal = MKPointAnnotation()
        annotationNewDeal.coordinate = locationCoordinate
        annotationNewDeal.title = objPf[NameBusiness] as! String
        annotationNewDeal.subtitle = objPf[Category] as! String
        mapView.addAnnotation(annotationNewDeal)

    }
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        
    }
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        
    }
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        
    }
    
    
}