//
//  HotDealsVC.swift
//  Sales Whip Server
//
//  Created by Arun on 8/19/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation

class HotDealsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrayDeals = NSMutableArray()
    var categoryName = String()
    var dealsObj : PFObject!
    @IBOutlet weak var dealsList_tableView: UITableView!
    
    override func viewDidLoad() {
        
        self.navigationItem.title = categoryName
        
        var crntUser = PFUser.currentUser()
        crntUser!.fetchIfNeeded()
        //store all HotDeals in a array

       // if let hotDealsArr = crntUser!.objectForKey("HotDeals") as? NSArray {
            //var hotDealsArray : NSArray = hotDealsArr
            //Filter the deals that are marked as HotDeals

            var queryObjDeals = PFQuery(className: "AvailableDeals")
            queryObjDeals.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if error == nil {
                    for var i = 0; i < objects!.count; i++ {
                        var object = objects![i] as! PFObject
                        self.dealsObj = objects![i] as! PFObject
                        
                        var dealsSelected = Bool()
                        dealsSelected = false
                        //Filtering

                            //var dealsId : String = hotDealsArray[j] as! String
                        if self.dealsObj[HotDeals] as! Bool == true {
                            dealsSelected = true
                        }
                        else {
                            continue;
                        }
                        
                        self.arrayDeals.addObject(self.dealsObj)
                        //storing deals object in array for representing in table

                    }
                }
                //update table

                self.dealsList_tableView.reloadData()
            }
            
        //}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDeals.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : DealsListTableCell!
        cell = dealsList_tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as? DealsListTableCell
        //set all filtered hot deals object in custom table cell (company , category)

        var objectCell = arrayDeals.objectAtIndex(indexPath.row) as! PFObject
        
        cell.label_company.text = objectCell.objectForKey(NameBusiness) as? String
        cell.label_category.text = objectCell.objectForKey(Category) as? String
        return cell
    }
}