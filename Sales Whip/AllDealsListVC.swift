//
//  AllDealsListVC.swift
//  Sales Whip
//
//  Created by Arun on 8/18/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation

class AllDealsListVC: UIViewController ,UITableViewDelegate , UITableViewDataSource{
    
    //this class contains all the deals available till date
    //by tapping and swiping on left on any row containing deals we can edit and delete that cell from view and server(parse)
    //we can add another new deals also
    
    @IBOutlet weak var dealsList_tableView: UITableView!
    var arrayDeals = NSMutableArray()
    var objectDeals : PFObject!
    var boolAdd = Bool()
    var indexTapped = Int()
    
    //come back from saving deals (after editing or adding new one)
    @IBAction func unwindToAllDeals(segue : UIStoryboardSegue) {
        self.arrayDeals = NSMutableArray()
        self.viewDidLoad()
    }
    override func viewDidLoad() {
//send the reference of cell tapped to retreive the exact cell data from array using this index
        indexTapped = -1
        //retreive the data from parse class "AvailableDeals" which contain all the deals available today
        var queryObjDeals = PFQuery(className: "AvailableDeals")
        queryObjDeals.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                
                for var i = 0 ; i < objects!.count ; i++ {
                    var object = objects![i] as! PFObject
                    self.objectDeals = objects![i] as! PFObject
                    self.arrayDeals.addObject(self.objectDeals)
                }
                //and storing in array for displaying them in tableview
                self.dealsList_tableView.reloadData()
            }
        }
    }
    //before going to another segue destination chk the source ,sourch can ask for editing and adding new one deals
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var addDealsVc = segue.destinationViewController as! AddDealsVC
        addDealsVc.boolAdd = boolAdd
//from bool variable of adding new one deal we chk that what we have to ask from segue view
        if boolAdd {
            addDealsVc.titleTextString = "AddDeal"
        }
        else {
            addDealsVc.titleTextString = "EditDeal"
            addDealsVc.objectDealEditable = arrayDeals[indexTapped] as! PFObject
        }
    }
    // adding new deal
    @IBAction func button_add_tapped(sender: AnyObject) {
        boolAdd = true
        self.performSegueWithIdentifier(K_ADD_DEALS_SEGUE, sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : DealsListTableCell!
        cell = dealsList_tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as? DealsListTableCell
        
        var objectCell = arrayDeals.objectAtIndex(indexPath.row) as! PFObject
        
        cell.label_company.text = objectCell.objectForKey(NameBusiness) as? String
        cell.label_category.text = objectCell.objectForKey(Category) as? String
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        indexTapped = indexPath.row
        boolAdd = false
        self.performSegueWithIdentifier(K_ADD_DEALS_SEGUE, sender: self)

        
    }
    //for deleting the cell
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //update on deleting object from table , parse and array
            var cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.removeFromSuperview()
            
            var dealsObj: PFObject = arrayDeals[indexPath.row] as! PFObject
            arrayDeals.removeObjectAtIndex(indexPath.row)
            dealsObj.deleteInBackgroundWithBlock({ (sucess, error) -> Void in
                self.dealsList_tableView.reloadData()
            })
        }
    }
//return total deals count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDeals.count
    }
}