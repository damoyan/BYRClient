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
    
    var currentTheme = Light()
    
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
                return false
            }
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
            print("token is good", userToken, expiresDateString)
        } else {
            print("token is expired.")
            if refreshToken != nil {
                // FIXME: refresh token
                print("need refresh: ", refreshToken)
            }
            // if refresh fail, show login
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onInvalidToken:", name: Notifications.InvalidToken, object: nil)
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
    
    @objc private func onInvalidToken(noti: NSNotification) {
        // FIXME: clear token info
        if userToken != nil {
            userToken = nil
        }
        navigateToLogin()
    }
    
    private func navigateToLogin() {
        if let root = UIApplication.sharedApplication().keyWindow?.rootViewController {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                root.navigateToLogin()
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
