//
//  AppSharedInfo.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/28/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import SSKeychain

class AppSharedInfo: NSObject {
    static let sharedInstance = AppSharedInfo()
    var userToken: String? {
        didSet {
            persistToken()
        }
    }
    var expiresDateString: String? {
        didSet {
            persistTokenExpires()
        }
    }
    
    var expires: String? {
        get {
            if let e = expiresDateString, date = Utils.defaultDateFormatter.dateFromString(e) {
                return String(UInt(date.timeIntervalSinceNow))
            }
            return nil
        }
        set {
            if let e = newValue, interval = NSTimeInterval(e) {
                let date = NSDate(timeIntervalSinceNow: interval)
                expiresDateString = Utils.defaultDateFormatter.stringFromDate(date)
            }
        }
    }
    
    var refreshToken: String? {
        didSet {
            persistRefreshToken()
        }
    }
    
    // only calculate use native saved info,
    // won't check with server
    var tokenExpired: Bool {
        if let e = expiresDateString, date = Utils.defaultDateFormatter.dateFromString(e) {
            if date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                return true
            }
            return false
        }
        return true
    }
    
    let service = "FromScratch"
    let account = (token: "token", refreshToken: "refreshToken", expires: "expires")
    
    override init() {
        userToken = try? SSKeychain.passwordForService(service, account: account.token, error: ())
        expiresDateString = try? SSKeychain.passwordForService(service, account: account.expires, error: ())
        refreshToken = try? SSKeychain.passwordForService(service, account: account.refreshToken, error: ())
        super.init()
        if userToken != nil && !tokenExpired {
            // update user info
        } else {
            if refreshToken != nil {
                // refresh token
                
            }
            // if refresh fail, show login
        }
    }
    
    private func persistToken() {
        if userToken != nil {
            SSKeychain.setPassword(userToken!, forService: service, account: account.token)
        } else {
            SSKeychain.deletePasswordForService(service, account: account.token)
        }
    }
    
    private func persistTokenExpires() {
        if let e = expiresDateString {
            SSKeychain.setPassword(e, forService: service, account: account.expires)
        } else {
            SSKeychain.deletePasswordForService(service, account: account.expires)
        }
    }
    
    private func persistRefreshToken() {
        if refreshToken != nil {
            SSKeychain.setPassword(refreshToken!, forService: service, account: account.refreshToken)
        } else {
            SSKeychain.deletePasswordForService(service, account: account.refreshToken)
        }
    }
}
