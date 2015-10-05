//
//  Constants-Variables.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit




let phonewidth = UIScreen.mainScreen().bounds.width
let phoneheight = UIScreen.mainScreen().bounds.height

let Device = UIDevice.currentDevice()

let iosVersion = NSString(string: Device.systemVersion).doubleValue

let iOS8 = iosVersion >= 8
let iOS7 = iosVersion >= 7 && iosVersion < 8

let googleMapOfficialKey = "AIzaSyCjnyx5_bYXZUcMJuOpeekNn51I1d3wDiI"
let googlePlacesOfficialKey = "AIzaSyDEQuw1ZwVGlWDQOa5WWoThd89_D6maU7A"


let storyb = UIStoryboard(name: "Main", bundle: nil)

var currentuser = PFUser.currentUser()
let userpf = PFUser()
var justSignedUp = false

var distance:CGFloat = phonewidth/22    // distance between card view origin X
var navHeight:CGFloat = 64 // navigation Bar Height
var tabHeight:CGFloat = 49
var yesnoButtonHeight:CGFloat = 90
var cardHeight:CGFloat = phoneheight - (navHeight + tabHeight + yesnoButtonHeight)
var frontCardFrame = CGRectMake(distance, navHeight + 5, phonewidth - distance*2, cardHeight)
var backCardFrame = CGRectMake(distance - 4, navHeight + 10, phonewidth - distance*2, cardHeight)


//parse key object










