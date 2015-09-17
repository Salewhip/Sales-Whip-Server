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
        
        var crntUser = PFUser.currentUser()
        crntUser!.fetchIfNeeded()
        //store all favourite deals in a array
        if let hotDealsArr = crntUser!.objectForKey("FavouriteDeals") as? NSArray {
            
            var hotDealsArray : NSArray = hotDealsArr
            //Filter the deals that are marked as favourite deals
            var queryObjDeals = PFQuery(className: "AvailableDeals")
            //queryObjDeals.whereKey(HotDeals, equalTo: true)
            queryObjDeals.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if error == nil {
                    var pfObjects:[PFObject] = objects as! [PFObject]
                    for var i = 0; i < pfObjects.count; i++ {
                        var object = pfObjects[i]
                        self.dealsObj = pfObjects[i]
                        var dealsSelected = Bool()
                        dealsSelected = false
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