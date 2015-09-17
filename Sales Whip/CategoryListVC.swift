//
//  CategoryListVC.swift
//  Sales Whip Client
//
//  Created by Arun on 8/18/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation

class CategoryListVC : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var arrayDeals = NSMutableArray()
    var indexSeleted = Int()
    
    override func viewDidLoad() {
        //storing all category of deals in a array for representing in table with their title,and showing all deals related to them on tapping
        arrayDeals.addObject("abc1")
        arrayDeals.addObject("abc2")
        arrayDeals.addObject("abc3")
        arrayDeals.addObject("abc4")
        arrayDeals.addObject("abc5")
        arrayDeals.addObject("abc6")
        arrayDeals.addObject("abc7")
        arrayDeals.addObject("abc8")
        arrayDeals.addObject("abc9")
        arrayDeals.addObject("abc10")
        arrayDeals.addObject("abc11")
        arrayDeals.addObject("abc12")
        arrayDeals.addObject("abc13")
        arrayDeals.addObject("abc14")
        arrayDeals.addObject("abc15")
    }
    //set category (selected one)name to title of their view(SIngleCategoryDealsVC) which shoeing all list of deals related to the selected category
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var segueVc = segue.destinationViewController as! SIngleCategoryDealsVC
        segueVc.categoryName = arrayDeals.objectAtIndex(indexSeleted) as! String
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDeals.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        //showing all list of deals in the table
        var catString = arrayDeals.objectAtIndex(indexPath.row) as! String
        cell.textLabel?.text = catString
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //store tapped cell index for referring the right object from the array
        indexSeleted = indexPath.row
        self.performSegueWithIdentifier(K_SINGLE_CAT_KEY, sender: self)
    }
}