//
//  AddDealsVC.swift
//  Sales Whip
//
//  Created by Arun on 8/18/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import Foundation

class AddDealsVC: UIViewController , UITextFieldDelegate, AddDealsLocationDelegate {
    
    //This class is for editing and adding new detail
    //
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var CategoryTextField: UITextField!
    @IBOutlet weak var hotDealsTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var startingTextField: UITextField!
    @IBOutlet weak var closingTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var hotDealSwitch: UISwitch!
    @IBOutlet weak var addLocationButton: UIButton!
    
    var dealsLocation : CLLocation!
    var boolAdd : Bool!
    var locationSet : Bool!
    var objectDealEditable : PFObject!
    var titleTextString : String!
    
 // MARK:
    //getting useful info (which will decide the main use of this class(for adding or editing deal))from source view(AllDealsListVC)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        //refresh previous location to nil
        
        if !boolAdd {
            
            self.navigationItem.title = objectDealEditable.objectForKey(NameBusiness) as? String
            var pfLoc = objectDealEditable.objectForKey(location) as! PFGeoPoint
            dealsLocation = CLLocation(latitude: pfLoc.latitude, longitude: pfLoc.longitude)
            self.edit_deal()
        }
        else {
            
                    }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var segueLocationVc: AnyObject = segue.destinationViewController
        if segueLocationVc.isKindOfClass(AddDealsLocationVC) {
            if var segueVc : AddDealsLocationVC = segueLocationVc as? AddDealsLocationVC {
            segueVc.delegate = self
                segueVc.locationAdded = boolAdd
                if !boolAdd {
                    //segueVc.dealsPrevLoc = objectDealEditable.objectForKey(location) as! PFGeoPoint
                    segueVc.dealsPrevLoc = PFGeoPoint(location: dealsLocation)
                    
                }
                else {
                    var appD = UIApplication.sharedApplication().delegate as! AppDelegate
                    if appD.previousLoc.coordinate.latitude != 0.0 && appD.previousLoc.coordinate.longitude != 0.0 {
                        segueVc.locationAdded = false

                        segueVc.dealsPrevLoc = PFGeoPoint(location: dealsLocation)
                    }
                }
            }
        }
        
    }
    func changeAddLocationButtonStateToSelected(loc: CLLocationCoordinate2D) {
        
        //addLocationButton.selected = true
        addLocationButton.setBackgroundImage(UIImage(named: "star"), forState: UIControlState.Normal)
        locationTextField.text = "\((loc.latitude,loc.longitude))"
        dealsLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        
        var appD = UIApplication.sharedApplication().delegate as! AppDelegate
        appD.previousLoc = dealsLocation
    }
    //change the preference of the deal to true or false as HotDeal status
    @IBAction func hotDeal_switch_value_changed(sender: AnyObject) {
        var hotDealSwitch : UISwitch! = sender as! UISwitch
        
        if hotDealSwitch.on {
            //hotDealSwitch.setOn(!hotDealSwitch.on, animated: true)
        }
        else {
            //hotDealSwitch.setOn(!hotDealSwitch.on, animated: true)
        }
    }
    //before saving, checking whether all field are filled
    @IBAction func button_save_tapped(sender: AnyObject) {
        if (!nameTextField.text.isEmpty && !CategoryTextField.text.isEmpty && !hotDealsTextField.text.isEmpty && !addressTextField.text.isEmpty && !cityTextField.text.isEmpty && !stateTextField.text.isEmpty && !zipTextField.text.isEmpty && !startingTextField.text.isEmpty && !closingTextField.text.isEmpty && locationSet != false) {
            
            
            //if source of this view is asking for adding new deals
            if boolAdd != false {
                var objDeals : PFObject = PFObject(className: "AvailableDeals")
                //different type of detail of deals saving in parse under AvailableDeals class
                objDeals = self.updatePfobjectOfDeals(objDeals)
                
                objDeals.saveEventually({ (sucess, error) -> Void in
                    if error == nil {
                        self.performSegueWithIdentifier(K_UNWIND_TO_ALL_DEALS, sender: self)
                    }
                })
                
            }
                //if source of this view is asking for editting previous deals
                
            else {
                //retreiving that old object and setting new value and saving again
                objectDealEditable = self.updatePfobjectOfDeals(objectDealEditable)
                
                objectDealEditable.saveEventually({ (sucess, error) -> Void in
                    if error == nil {
                        self.performSegueWithIdentifier(K_UNWIND_TO_ALL_DEALS, sender: self)
                    }
                })
            }
            
        }
        
    }
    @IBAction func AddLocationOnMap(sender: AnyObject) {
        self.performSegueWithIdentifier(K_ADD_LOCATION_ON_MAP, sender: self)
    }
    //send text of all textfield to parse object
    func updatePfobjectOfDeals(dealsObject : PFObject)-> PFObject {
        dealsObject.setObject(nameTextField.text, forKey: NameBusiness)
        dealsObject.setObject(CategoryTextField.text, forKey: Category)
        dealsObject.setObject(hotDealSwitch.on, forKey: HotDeals)
        dealsObject.setObject(hotDealsTextField.text, forKey: Discount)
        dealsObject.setObject(addressTextField.text, forKey: Address)
        dealsObject.setObject(cityTextField.text, forKey: City)
        dealsObject.setObject(stateTextField.text, forKey: State)
        dealsObject.setObject(zipTextField.text, forKey: zip)
        dealsObject.setObject(startingTextField.text, forKey: StartingDate)
        dealsObject.setObject(closingTextField.text, forKey: ClosingDate)
        dealsObject.setObject(PFGeoPoint(location: dealsLocation), forKey: location)
        
        return dealsObject
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        println("touch")
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue() , { () -> Void in
            self.navigationItem.title = self.nameTextField.text
        })

        return true
    }
    //fetching detail of editable deal and and setting value in view
    func edit_deal() {
        
        nameTextField.text = objectDealEditable.objectForKey(NameBusiness) as! String
        CategoryTextField.text = objectDealEditable.objectForKey(Category) as! String
        hotDealsTextField.text = objectDealEditable.objectForKey(Discount) as! String
        hotDealSwitch.setOn(objectDealEditable.objectForKey(HotDeals) as! Bool, animated: true)
        addressTextField.text = objectDealEditable.objectForKey(Address) as! String
        cityTextField.text = objectDealEditable.objectForKey(City) as! String
        stateTextField.text = objectDealEditable.objectForKey(State) as! String
        zipTextField.text = objectDealEditable.objectForKey(zip) as! String
        startingTextField.text = objectDealEditable.objectForKey(StartingDate) as! String
        closingTextField.text = objectDealEditable.objectForKey(ClosingDate) as! String
        
        var pfLocGeo = objectDealEditable.objectForKey(location) as! PFGeoPoint
        var latitude: CLLocationDegrees = pfLocGeo.latitude
        var longtitude: CLLocationDegrees = pfLocGeo.longitude
        
        var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)

        locationTextField.text = "\((locationCoordinate.latitude,locationCoordinate.longitude))"
        
    }
}