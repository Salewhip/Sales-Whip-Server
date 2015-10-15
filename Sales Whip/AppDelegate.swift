 //
//  AppDelegate.swift
//  Sales Whip
//
//  Created by Arun on 8/17/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    //location object
    var manager:CLLocationManager = CLLocationManager()
    var previousLoc:CLLocation = CLLocation()
    
    enum Actions:String{
        case favourite = "FAVOURITE"
        case map = "MAP"
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        previousLoc = CLLocation(latitude: 0.0, longitude: 0.0)
        // Override point for customization after application launch.
        
        // Remove the third tab from a tab bar controlled by a tab bar controller
    
                //location manager
        
        GMSServices.provideAPIKey(googleMapOfficialKey)

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if iOS8 {
            //manager.requestWhenInUseAuthorization()
        }
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        
        //***************************
        //Parse key initiallization
        //it is used for login(authorizing client user and server business user)
        //and storing the data of deals which is created , updated and deleted by business and viewed by both
        Parse.setApplicationId(appId, clientKey: appSecret)
        // check if user is logged in
        if PFUser.currentUser() != nil && PFUser.currentUser()!.isAuthenticated() {
            //if user is logged in, go to default view
            if let tabBarController = self.window?.rootViewController as? UITabBarController {
                var indexToRemove : Int = 1

                if PFUser.currentUser()?.username != "admin" {
                    indexToRemove = 0
                    if indexToRemove < tabBarController.viewControllers?.count {
                        var viewControllers = tabBarController.viewControllers
                        viewControllers?.removeAtIndex(indexToRemove)
                        tabBarController.viewControllers = viewControllers
                        tabBarController.selectedIndex = 0
                    }

                }
                            }
        } else {
            //if user is not logged ,in go to login page
            var gotologin = storyb.instantiateViewControllerWithIdentifier(K_LOGGEDIN_VC_KEY) as! LoginViewController
            window!.rootViewController = gotologin
        }

        addButtonInLocalNotification()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        // Handle notification action *****************************************
        if notification.category == "METHOD_CATEGORY" {
            
            let action = Actions(rawValue: identifier!)!
            
            switch action{
                
            case Actions.favourite:
                saveTappedFromNotificationBanner(notification)
                
            case Actions.map:
                mapTappedFromNotificationBanner(notification)
                
            }
        }
    }
    func mapTappedFromNotificationBanner(notification : UILocalNotification) {
        var tabBarVC = UITabBarController()
        if let tabBarCont = self.window?.rootViewController as? UITabBarController {
            tabBarVC = tabBarCont
        }
        else if let tabBarCont = self.window?.rootViewController?.presentedViewController as? UITabBarController {
            tabBarVC = tabBarCont
        }
        tabBarVC.selectedIndex = 0
        NSNotificationCenter.defaultCenter().postNotificationName(LOCAL_NOTIFICATION_MAP, object: notification.region)
    }
    func saveTappedFromNotificationBanner(notification : UILocalNotification) {
        var tabBarVC = UITabBarController()
        if let tabBarCont = self.window?.rootViewController as? UITabBarController {
            tabBarVC = tabBarCont
        }
        else if let tabBarCont = self.window?.rootViewController?.presentedViewController as? UITabBarController {
            tabBarVC = tabBarCont
        }
        tabBarVC.selectedIndex = 3
        
        NSNotificationCenter.defaultCenter().postNotificationName(LOCAL_NOTIFICATION_FAVOURITE, object: notification.region)

    }
    func addButtonInLocalNotification() {
        let favourite = UIMutableUserNotificationAction()
        favourite.identifier = Actions.favourite.rawValue
        favourite.title = "FAVOURITE"
        favourite.activationMode = UIUserNotificationActivationMode.Foreground
        favourite.authenticationRequired = true
        favourite.destructive = false
        
        // decrement Action
        let map = UIMutableUserNotificationAction()
        map.identifier = Actions.map.rawValue
        map.title = "MAP"
        map.activationMode = UIUserNotificationActivationMode.Foreground
        map.authenticationRequired = true
        map.destructive = false
        
        let methodCategory = UIMutableUserNotificationCategory()
        methodCategory.identifier = "METHOD_CATEGORY"
        
        // B. Set actions for the minimal context
        methodCategory.setActions([favourite, map],
            forContext: UIUserNotificationActionContext.Default)
        
        let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound | UIUserNotificationType.Badge
        let settings = UIUserNotificationSettings(forTypes: types, categories: NSSet(object: methodCategory) as Set<NSObject>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        //application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        
    }

    func handleRegionEvent(region: CLRegion) {
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            if let message = region.identifier {
                if let viewController = window?.rootViewController {
                    showSimpleAlertWithTitle(nil, message: message, viewController: viewController)
                }
            }
        } else {
            // Otherwise present a local notification
            var notification = UILocalNotification()
            notification.alertBody = region.identifier
            notification.soundName = "Default";
            notification.category = "METHOD_CATEGORY"
            notification.region = region
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        
        var lastLocation = manager.location
        
        var doesItContainMyPoint : Bool = false
        
        if lastLocation==nil{
            doesItContainMyPoint = false
        }
        else
        {
            var theLocationCoordinate = lastLocation.coordinate as CLLocationCoordinate2D
            var theRegion = region as! CLCircularRegion
            doesItContainMyPoint = theRegion.containsCoordinate(theLocationCoordinate)
        }

        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }
    
    func notefromRegionIdentifier(identifier: String) -> String? {
//        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
//            for savedItem in savedItems {
//                if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
//                    if geotification.identifier == identifier {
//                        return geotification.note
//                    }
//                }
//            }
//        }
        return nil
    }


}

