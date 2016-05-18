//
//  Constants.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/27/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import Foundation

let appKey = "7f7bcb6eb5c510ce85bdca2473de844b"
let appSecret = "44c3edb39e6c18af91296ae617e97846"
let bundleID = NSBundle.mainBundle().bundleIdentifier ?? "cn.ypy.byrclient"

let state = "\(Int64(NSDate.timeIntervalSinceReferenceDate()))"

let baseURLString = "http://bbs.byr.cn/open"
let baseURL = NSURL(string: baseURLString)!
let oauth2URLString = "http://bbs.byr.cn/oauth2/authorize"
let oauthResponseType = "token"
let oauthRedirectUri = "http://bbs.byr.cn/oauth2/callback"
let oauthTokenRefreshURL = NSURL(string: "http://bbs.byr.cn/oauth2/token")!

struct Notifications {
    static let UserLogin = "cn.ypy.byr.notifications.UserLogin"
    static let UserLogout = "cn.ypy.byr.notifications.UserLogout"
    static let UserRenewal = "cn.ypy.byr.notifications.UserRenewal"
    static let InvalidToken = "cn.ypy.byr.notifications.InvalidToken"
    static let NewFavoriteAdded = "cn.ypy.byr.notifications.NewFavoriteAdded"
}

struct Keys {
    static let FavoriteLevel = "cn.ypy.byr.keys.FavoriteLevel"
    static let FavoriteInfo = "cn.ypy.byr.keys.FavoriteInfo"
}