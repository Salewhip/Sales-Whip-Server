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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Remove the third tab from a tab bar controlled by a tab bar controller
    
                //location manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if iOS8 {
            manager.requestWhenInUseAuthorization()
        }
        
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


}

