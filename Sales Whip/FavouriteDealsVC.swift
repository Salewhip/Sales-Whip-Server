//
//  FavouriteDealsVC.swift
//  Sales Whip Server
//
//  Created by Arun on 8/19/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation

class FavouriteDealsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrayDeals = NSMutableArray()
    var categoryName = String()
    var dealsObj : PFObject!
    @IBOutlet weak var dealsList_tableView: UITableView!
    
    override func viewDidLoad() {
        
        self.navigationItem.title = categoryName
        self.arrayDeals = NSMutableArray()
        updateFavouriteAvailableDeals(false, notifLoc: CLLocationCoordinate2D())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "catchLocalNotification:", name: LOCAL_NOTIFICATION_FAVOURITE, object: nil)

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.arrayDeals = NSMutableArray()

        updateFavouriteAvailableDeals(false, notifLoc: CLLocationCoordinate2D())

    }
    func catchLocalNotification(notif : NSNotification) {
        self.arrayDeals = NSMutableArray()

        var notifLoc2d = (notif.object as! CLCircularRegion).center
        updateFavouriteAvailableDeals(true, notifLoc: notifLoc2d)
    
    }
    
    func updateFavouriteAvailableDeals(update : Bool,notifLoc : CLLocationCoordinate2D) {
        var crntUser = PFUser.currentUser()
        crntUser!.fetchIfNeeded()
        //store all favourite deals in a array
        if var hotDealsArr = crntUser!.objectForKey(FavouriteDeals) as? NSArray {
            findInParseAllTheDealsWhichAreFavouriteOfCurrentUser(hotDealsArr, update: update, notifLoc: notifLoc)
                    }
        else {
            var array = NSArray()
            findInParseAllTheDealsWhichAreFavouriteOfCurrentUser(array, update: update, notifLoc: notifLoc)
        }

    }
    func findInParseAllTheDealsWhichAreFavouriteOfCurrentUser(hotDealsArr : NSArray,update : Bool,notifLoc : CLLocationCoordinate2D) {
        
        var hotDealsArray : NSArray = hotDealsArr
        //Filter the deals that are marked as favourite deals
        var queryObjDeals = PFQuery(className: AvailableDeals)
        //queryObjDeals.whereKey(HotDeals, equalTo: true)
        queryObjDeals.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                var pfObjects:[PFObject] = objects as! [PFObject]
                for var i = 0; i < pfObjects.count; i++ {
                    var object = pfObjects[i]
                    self.dealsObj = pfObjects[i]
                    var dealsSelected = Bool()
                    dealsSelected = false
                    if update {
                        if self.dealsObj[location]?.latitude == notifLoc.latitude && self.dealsObj[location]?.longitude == notifLoc.longitude {
                            var array = NSMutableArray(array: hotDealsArr)
                            array.addObject(self.dealsObj.objectId!)
                            
                            hotDealsArray = array.valueForKeyPath("@distinctUnionOfObjects.self") as! NSArray
                        
                            currentuser?.setObject(hotDealsArray, forKey: FavouriteDeals)
                            currentuser?.saveInBackground()
                        }
                    }
                    //Filtering
                    for var j = 0; j < hotDealsArray.count; j++ {
                        var dealsId : String = hotDealsArray[j] as! String
                        if self.dealsObj.objectId == dealsId {
                            dealsSelected = true
                        }
                    }
                    if !dealsSelected {
                        continue
                    }
                    self.arrayDeals.addObject(self.dealsObj)
                    //storing deals object in array for representing in table
                    
                }
            }
            

            //update table
            self.dealsList_tableView.reloadData()
        }

    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDeals.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : DealsListTableCell!
        cell = dealsList_tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as? DealsListTableCell
        //set all filtered favourite deals object in custom table cell (company , category)
        var objectCell = arrayDeals.objectAtIndex(indexPath.row) as! PFObject
        
        cell.label_company.text = objectCell.objectForKey(NameBusiness) as? String
        cell.label_category.text = objectCell.objectForKey(Category) as? String
        return cell
    }
}