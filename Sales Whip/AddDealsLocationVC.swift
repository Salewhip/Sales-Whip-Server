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

    @IBOutlet weak var mapView: MKMapView!
    //location object
    var manager:CLLocationManager = CLLocationManager()
    let annotation = MKPointAnnotation()
    var dealsPrevLoc = PFGeoPoint()
    var locationAdded = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show previous location if any
        if !locationAdded {
            var latitude: CLLocationDegrees = dealsPrevLoc.latitude
            var longtitude: CLLocationDegrees = dealsPrevLoc.longitude
            
            var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)

            annotation.coordinate = locationCoordinate
            annotation.title = "New Deal"
            annotation.subtitle = "India"
            mapView.addAnnotation(annotation)
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
    }
    //set that deals location is added by admin once
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var seguePopVc = segue.destinationViewController as! AddDealsVC
        seguePopVc.addLocationButton.selected = true
    }
    //anotation view manipulation
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotatiobView : MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotatiobView.image = UIImage(named: "star")
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
        mapView.addAnnotation(annotation)
        locationAdded = true;
        self.delegate?.changeAddLocationButtonStateToSelected(locationCoordinate)
    }
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        
    }
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        
    }
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        
    }
    
    
}