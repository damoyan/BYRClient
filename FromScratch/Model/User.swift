//
//  User.swift
//  FromScratch
//
//  Created by Yu Pengyang on 11/2/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: NSObject {
    let id: String?
    let userName: String?
    let faceURL: String?
    let faceWidth: Int?
    let faceHeight: Int?
    let gender: String?
    let astro: String?
    let life: Int?
    let qq: String?
    let msn: String?
    let homePage: String?
    let level: String?
    let isOnline: Bool?
    let postCount: Int?
    let lastLoginTime: NSDate?
    let lastLoginIP: String?
    let isHide: Bool?
    let isRegister: Bool?
    let firstLoginTime: NSDate?
    let loginCount: Int?
    let isAdmin: Bool?
    let stayCount: Int?
    
    init(data: JSON) {
        id              = data[_keys.id].string
        userName        = data[_keys.userName].string
        faceURL         = data[_keys.faceURL].string
        faceWidth       = data[_keys.faceWidth].int
        faceHeight      = data[_keys.faceHeight].int
        gender          = data[_keys.gender].string
        astro           = data[_keys.astro].string
        life            = data[_keys.life].int
        qq              = data[_keys.qq].string
        msn             = data[_keys.msn].string
        homePage        = data[_keys.homePage].string
        level           = data[_keys.level].string
        isOnline        = data[_keys.isOnline].bool
        postCount       = data[_keys.postCount].int
        lastLoginTime   = Utils.dateFromUnixTimestamp(data[_keys.lastLoginTime].int)
        lastLoginIP     = data[_keys.lastLoginIP].string
        isHide          = data[_keys.isHide].bool
        isRegister      = data[_keys.isRegister].bool
        firstLoginTime  = Utils.dateFromUnixTimestamp(data[_keys.firstLoginTime].int)
        loginCount      = data[_keys.loginCount].int
        isAdmin         = data[_keys.isAdmin].bool
        stayCount       = data[_keys.stayCount].int
    }
    
    struct _keys {
        static let id = "id", userName = "user_name", faceURL = "face_url", faceWidth = "face_width", faceHeight = "face_height", gender = "gender", astro = "astro", life = "life", qq = "qq", msn = "msn", homePage = "home_page", level = "level", isOnline = "is_online", postCount = "post_count", lastLoginTime = "last_login_time", lastLoginIP = "last_login_ip", isHide = "is_hide", isRegister = "is_register", firstLoginTime = "first_login_time", loginCount = "login_count", isAdmin = "is_admin", stayCount = "stay_count"
    }
}