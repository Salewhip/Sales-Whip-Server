//
//  GeofenceVC.swift
//  Sales Whip Server
//
//  Created by Arun on 10/10/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class GeofenceVC: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    let annotation = MKPointAnnotation()

    var geotifications = NSMutableArray()
    var locationManager = CLLocationManager() // Add this statement
    var _didStartMonitoringRegion = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                // 3

        
        locationManager = CLLocationManager()
        // locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // 1
        locationManager.delegate = self
        // 2
        locationManager.requestAlwaysAuthorization()

        var loc : CLLocation  = CLLocation(latitude: 37.35, longitude: -122.0310273);

        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0310273), span: span)
        mapView.setRegion(region, animated: true)
        centerMapOnLocation(loc)
        
        mapView.delegate = self
        //annotation view and pin
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0310273)
        annotation.title = "Current Location"
        annotation.subtitle = "India"
        mapView.addAnnotation(annotation)
        mapView.userTrackingMode = MKUserTrackingMode.Follow
        
        //self.geotifications = NSMutableArray()
    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
        mapView.showsUserLocation = true

    }
    @IBAction func addCurrentLocation(sender: AnyObject) {
        _didStartMonitoringRegion = false
        self.startMonitoringRegion()

        //self.locationManager.startUpdatingLocation()
    }
//    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
//        self.navigationItem.title = "entry"
//    }
//    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
//        self.navigationItem.title = "exit"
//    }
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
    }
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("Monitoring failed for region with identifier: \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location Manager failed with the following error: \(error)")
    }
    func startMonitoringRegion() {
        
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            println( "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            println( "Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")

        }

        var reg = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0310273), radius: 1000.0, identifier: NSUUID().UUIDString)
        reg.notifyOnEntry = true
        reg.notifyOnExit = false
        
        self.geotifications = NSMutableArray(object: reg)
        self.locationManager.startMonitoringForRegion(reg)
        //self.locationManager.stopUpdatingLocation()

    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations.count > 0 && !_didStartMonitoringRegion {
            _didStartMonitoringRegion = true
            var location: CLLocation = (locations as NSArray).objectAtIndex(0) as! CLLocation
            
            self.addRadiusOverlayForGeotification(location)
            
            var region = CLCircularRegion(center: location.coordinate, radius: 1000, identifier: NSUUID().UUIDString)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            self.locationManager.startMonitoringForRegion(region)
            self.locationManager.stopUpdatingLocation()
            self.geotifications.addObject(region)
            
            //self.tableView.beginUpdates()
            //self.tableView.insertRowsAtIndexPaths(NSIndexPath(forRow: self.geotifications.count - 1, inSection: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
            //self.tableView.endUpdates()
            self.tableView.reloadData()
            self.updateView()
        }

    }
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        
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
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 1000.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
//    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        let identifier = "myGeotification"
//        //if annotation is Geotification {
//            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
//            if annotationView == nil {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = true
//                var removeButton = UIButton.buttonWithType(.Custom) as! UIButton
//                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
//                //removeButton.setImage(UIImage(named: "DeleteGeotification")!, forState: .Normal)
//                annotationView?.leftCalloutAccessoryView = removeButton
//            } else {
//                annotationView?.annotation = annotation
//            }
//            return annotationView
//       // }
//        //return nil
//    }
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), animated: true)
    }
    func addRadiusOverlayForGeotification(loc: CLLocation) {
        mapView?.addOverlay(MKCircle(centerCoordinate:CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude) , radius: 1000))
    }

    func updateView() {
        if self.geotifications.count == 0 {
            //self.tableView.setEditing(false, animated: true)
            //self.navigationItem.rightBarButtonItem.setEnabled(false)
            //self.navigationItem.rightBarButtonItem.setTitle(NSLocalizedString("Edit", nil))
        }
        else {
            //self.navigationItem.rightBarButtonItem.setEnabled(true)
        }
        if self.geotifications.count < 20 {
            self.navigationItem.leftBarButtonItem?.enabled = true
        }
        else {
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        if let region = self.geotifications[indexPath.row] as? CLCircularRegion {
            cell.textLabel?.text = "\(region.center.latitude),\(region.center.longitude)"
        }
        //var coordinate : CLLocationCoordinate2D = region.
        
        return cell
    }
        //for deleting the cell
        //return total deals count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.geotifications.count
    }

}