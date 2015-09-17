//
//  ViewController.swift
//  Sales Whip
//
//  Created by Arun on 8/17/15.
//  Copyright (c) 2015 Arun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    //unwind segue(comming back) from RegisterViewController(Sign Up) to Login view
    @IBAction func unwindToLogin(segue : UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTF.delegate = self
        passwordTF.delegate = self
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //parse login action
    @IBAction func loginAction(sender: AnyObject) {
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        PFUser.logInWithUsernameInBackground(usernameTF.text, password: passwordTF.text)  { (getuser, error) -> Void in
            if getuser != nil {
                var currentuser : PFUser = PFUser.currentUser()!
                currentuser.setObject(true, forKey: "launchFirst")
                //record that the user previously logged in
                if UIDevice.currentDevice().model != "iPhone Simulator" {
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation["user"] = currentuser
                    currentInstallation.saveInBackground()
                }
                self.performSegueWithIdentifier(K_LOGIN_SUCESS_KEY, sender: self)
               // MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
               // MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let errorString = error!.userInfo?["error"] as? NSString {
                    var alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                    alert.show()
                }
            }
            
        }
        
    }
    //signup for new user
    @IBAction func signUpAction(sender: AnyObject) {
        self.performSegueWithIdentifier(K_REG_VC_KEY, sender: nil)
    }
    
    func createUser() {
        
        
        PFUser().signUpInBackgroundWithBlock {
            (succeeded, error) -> Void in
            if error == nil {
                self.performSegueWithIdentifier("signedup", sender: self)
            } else {
                if let errorString = error!.userInfo?["error"] as? NSString {
                    var alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                    alert.show()
                }
                
            }
        }
        
        
    }

    //signup login facebook
    @IBAction func loginFb(sender: AnyObject) {/*
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        var permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInWithPermissions(permissions, block: {
            (fbuser: PFUser!, error: NSError!) -> Void in
            if fbuser == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else if fbuser.isNew {
                NSLog("User signed up and logged in through Facebook!")
                justSignedUp = true
                currentuser = fbuser
                self.createFbUser()
                
            } else if fbuser != nil{
                NSLog("User logged in through Facebook!")
                currentuser = fbuser
                if UIDevice.currentDevice().model != "iPhone Simulator" {
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation["user"] = currentuser
                    currentInstallation.saveInBackground()
                }
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.performSegueWithIdentifier("logintotab", sender: self)
            } else {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let errorString = error.userInfo?["error"] as? NSString {
                    var alert = UIAlertView(title: "Error", message: errorString as String, delegate: self, cancelButtonTitle: "okay")
                    alert.show()
                }
            }
        })
    */}
    
    
    
    
    func createFbUser() {/*
        
        FBRequestConnection.startWithGraphPath("me", completionHandler: { (connection, fbuser, error) -> Void in
            
            if let useremail = fbuser.objectForKey("email") as? String {
                currentuser.email = useremail
            }
            
            currentuser["fname"] = fbuser.name // full name
            
            if let gender = fbuser.objectForKey("gender") as? String {
                if gender == "male" {
                    currentuser["gender"] = 1
                    currentuser["interested"] = 2
                } else  if gender == "female" {
                    currentuser["gender"] = 2
                    currentuser["interested"] = 1
                }
            }
            
            var id = fbuser.objectID as String
            var url = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=640&height=640")!
            var data = NSData(contentsOfURL: url)
            var image = UIImage(data: data!)
            var imageL = scaleImage(image!, and: 320) // save 640x640 image
            var imageS = scaleImage(image!, and: 60)
            var dataL = UIImageJPEGRepresentation(imageL, 0.9)
            var dataS = UIImageJPEGRepresentation(imageS, 0.9)
            currentuser["dpLarge"] = PFFile(name: "dpLarge.jpg", data: dataL)
            currentuser["dpSmall"] = PFFile(name: "dpSmall.jpg", data: dataS)
            currentuser["name"] = fbuser.first_name as String
            currentuser["fbId"] = fbuser.objectID as String
            currentuser["about"] = aboutme
            currentuser["age"] = 18
            currentuser["minAge"] = 18
            currentuser["maxAge"] = 60
            currentuser["locationLimit"] = 100
            currentuser.saveInBackgroundWithBlock({ (done, error) -> Void in
                if !(error != nil) {
                    if UIDevice.currentDevice().model != "iPhone Simulator" {
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation["user"] = currentuser
                        currentInstallation.saveInBackground()
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.performSegueWithIdentifier("logintotab", sender: self)
                } else {
                    println(error)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                }
            })
        })
        
    */}
    
    
    
    
    
    
    
    
    
    
    
    
}

