//
//  SIngleCategoryDealsVC.swift
//  Sales Whip Server
//
//  Created by Arun on 8/19/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation


class SIngleCategoryDealsVC : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrayDeals = NSMutableArray()
    var categoryName = String()
    var dealsObj : PFObject!
    @IBOutlet weak var dealsList_tableView: UITableView!
    
    override func viewDidLoad() {
        //show title of category selected under CategoryListVC class category list
        self.navigationItem.title = categoryName
        //filter all deals from the category selected
        var queryObjDeals = PFQuery(className: "AvailableDeals")
        queryObjDeals.whereKey(Category, equalTo: categoryName)
        queryObjDeals.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                for var i = 0; i < objects!.count; i++ {
                    var object = objects![i] as! PFObject
                    self.dealsObj = objects![i] as! PFObject
                    self.arrayDeals.addObject(self.dealsObj)
                    //adding deals of specific category to represent them in table
                }
            }
            //update table
            self.dealsList_tableView.reloadData()
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