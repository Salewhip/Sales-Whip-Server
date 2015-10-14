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
    var geofenceLocations = NSMutableArray()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //geofenceLocations = NSMutableArray()
        removeallGeoFenceRegions()
        addLocationOfAllDealsOnMap()
        
        //sortRegionDistanceWise()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.currentUser()?.username != "admin" && self.tabBarController?.viewControllers?.count == 5 {
            
            var indexToRemove : Int = 0;
            if let tabBarController = self.tabBarController {
                
                if indexToRemove < tabBarController.viewControllers?.count {
                    var viewControllers = tabBarController.viewControllers
                    viewControllers?.removeAtIndex(indexToRemove)
                    tabBarController.viewControllers = viewControllers
                    tabBarController.selectedIndex = 0
                }
            }
        }

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "catchLocalNotification:", name: LOCAL_NOTIFICATION, object: nil)
        
    }
    func catchLocalNotification(notif : NSNotification) {
        if let regionNotified = notif.object as? CLCircularRegion {
            var arrAnnot = self.mapView.annotations as! [MKAnnotation]
            for annotation: MKAnnotation in arrAnnot {
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(annotation)
            }

            var arrAnnot2 = self.mapView.annotations as! [MKAnnotation]
            for annotation: MKAnnotation in arrAnnot2 {
                if annotation.coordinate.latitude == regionNotified.center.latitude && annotation.coordinate.longitude == regionNotified.center.longitude {
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        let touchLocation = sender.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
            }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
        mapView.showsUserLocation = true
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        var lat = manager.location.coordinate.latitude
        var long = manager.location.coordinate.longitude
        var loc2d = CLLocationCoordinate2D(latitude: lat , longitude: long)
        
        let region = MKCoordinateRegion(center: loc2d , span: span)
        mapView.setRegion(region, animated: true)
        centerMapOnLocation(manager.location)
        
        mapView.delegate = self
        //annotation view and pin
        annotation.coordinate = loc2d
        annotation.title = "Current Location"
        annotation.subtitle = "India"
        mapView.addAnnotation(annotation)
    }
   /* func sortRegionDistanceWise() {
        if let geoUser = currentuser?.objectForKey("location") as? PFGeoPoint {
            for var i = 0 ; i < self.geofenceLocations.count ; i++ {
                var region = self.geofenceLocations.objectAtIndex(i) as! CLCircularRegion
                let distance:Double = geoUser.distanceInKilometersTo(PFGeoPoint(latitude: region.center.latitude, longitude: region.center.longitude))
                self.manager.stopMonitoringForRegion(region)
                self.geofenceLocations.removeObject(region)
            }
            
            
        }

    }*/
    func removeallGeoFenceRegions() {
        for var i = 0 ; i < self.geofenceLocations.count ; i++ {
            var region = self.geofenceLocations.objectAtIndex(i) as! CLCircularRegion
            self.manager.stopMonitoringForRegion(region)
            self.geofenceLocations.removeObject(region)
        }
    }
    func startMonitoringNearLocatedDeals() {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            println( "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            println( "Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
            
        }

        for var i = 0 ; i < self.geofenceLocations.count ; i++ {
            var region = self.geofenceLocations.objectAtIndex(i) as! CLCircularRegion
            region.notifyOnEntry = true
            region.notifyOnExit = false
            
            self.manager.startMonitoringForRegion(region)
        }
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
                    if let loc = object[location] as? PFGeoPoint {
                        self.showDealsAnotationOnMap(loc, objPf: object)
                        self.addRadiusOverlayForGeotification(CLLocation(latitude: loc.latitude, longitude: loc.longitude))

                            var region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude), radius: 1000, identifier: "\(object[NameBusiness])")
                        
                        self.geofenceLocations.addObject(region)
                    }
                }
                self.startMonitoringNearLocatedDeals()

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
        var once : Bool = false
        
        if locations.count > 0 {
            
            self.manager.stopUpdatingLocation()
            let loc : CLLocation = locations[0] as! CLLocation
            PFUser.currentUser()?.setObject(PFGeoPoint(location: loc), forKey: "location")
            if !once {
                //removeallGeoFenceRegions()
               // addLocationOfAllDealsOnMap()
                once = true
            }
            //zsrself.centerMapOnLocation(location)
        }
    }
//map current region radius(zoom in(<1000), zoom out(>1000))
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 500

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
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
    }
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("Monitoring failed for region with identifier: \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location Manager failed with the following error: \(error)")
    }

    func addRadiusOverlayForGeotification(loc: CLLocation) {
        mapView?.addOverlay(MKCircle(centerCoordinate:CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude) , radius: 1000))
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        return nil
    }

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), animated: true)
        PFUser.currentUser()?.setObject(PFGeoPoint(location: userLocation.location), forKey: "location")
        PFUser.currentUser()?.saveInBackground()
    }

    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        
    }
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        
    }
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        
    }
    
    
}