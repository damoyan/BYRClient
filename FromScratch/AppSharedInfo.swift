//
//  AppSharedInfo.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/28/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import SSKeychain
import Alamofire

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
            if let e = expiresDateString, date = Utils.longStyleDateFormatter.dateFromString(e) {
                return String(UInt(date.timeIntervalSinceNow))
            }
            return nil
        }
        set {
            if let e = newValue, interval = NSTimeInterval(e) {
                let date = NSDate(timeIntervalSinceNow: interval)
                expiresDateString = Utils.longStyleDateFormatter.stringFromDate(date)
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
        if let e = expiresDateString, date = Utils.longStyleDateFormatter.dateFromString(e) {
            if date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                return false
            }
        }
        return true
    }
    
    var isRenewing: Bool = false
    
    let service = "FromScratch"
    let account = (token: "token", refreshToken: "refreshToken", expires: "expires")
    
    override init() {
        userToken = SSKeychain.passwordForService(service, account: account.token)
        expiresDateString = SSKeychain.passwordForService(service, account: account.expires)
        refreshToken = SSKeychain.passwordForService(service, account: account.refreshToken)
        super.init()
        if userToken != nil && !tokenExpired {
            // update user info
            po("token is good", userToken, expiresDateString, refreshToken)
        } else {
            userToken = nil
            po("token is expired.")
            if refreshToken != nil {
                // FIXME: refresh token
                po("refreshing with refresh token: ", refreshToken)
                renewToken()
            }
            // if refresh fail, show login
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppSharedInfo.onInvalidToken(_:)), name: Notifications.InvalidToken, object: nil)
    }
    
    private func renewToken() {
        isRenewing = true
        request(TokenRefresh(refreshToken: refreshToken)).responseJSON { [weak self] (res) in
            if let json = res.result.value {
                po(json)
                // TODO: - update token
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserRenewal, object: nil)
            }
            self?.isRenewing = false
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
