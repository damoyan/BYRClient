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
let bundleID = NSBundle.mainBundle().bundleIdentifier ?? "com.caishuo.FromScratch"

let state = "\(Int64(NSDate.timeIntervalSinceReferenceDate()))"

let baseURLString = "http://bbs.byr.cn/open"
let baseURL = NSURL(string: baseURLString)!
let oauth2URLString = "http://bbs.byr.cn/oauth2/authorize"
let oauthResponseType = "token"
let oauthRedirectUri = "http://bbs.byr.cn/oauth2/callback"

struct Notifications {
    static let InvalidToken = "cn.ypy.byr.notifications.InvalidToken"
    static let NewFavoriteAdded = "cn.ypy.byr.notifications.NewFavoriteAdded"
}

struct Keys {
    static let FavoriteLevel = "cn.ypy.byr.keys.FavoriteLevel"
    static let FavoriteInfo = "cn.ypy.byr.keys.FavoriteInfo"
}