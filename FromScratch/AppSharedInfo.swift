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
    var expires: String?
    var refreshToken: String? {
        didSet {
            persistRefreshToken()
        }
    }
    
    let service = "FromScratch"
    let account = (token: "token", refreshToken: "refreshToken")
    
    override init() {
        userToken = try? SSKeychain.passwordForService(service, account: account.token, error: ())
        refreshToken = try? SSKeychain.passwordForService(service, account: account.refreshToken, error: ())
        if userToken != nil {
            // update user info
        } else {
            // show login
        }
    }
    
    private func persistToken() {
        if userToken != nil {
            SSKeychain.setPassword(userToken, forService: service, account: account.token)
        } else {
            SSKeychain.deletePasswordForService(service, account: account.token)
        }
    }
    
    private func persistRefreshToken() {
        if refreshToken != nil {
            SSKeychain.setPassword(refreshToken, forService: service, account: account.refreshToken)
        } else {
            SSKeychain.deletePasswordForService(service, account: account.refreshToken)
        }
    }
}
