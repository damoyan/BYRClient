//
//  AppSharedInfo.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/28/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import Foundation

class AppSharedInfo: NSObject {
    static let sharedInstance = AppSharedInfo()
    var userToken: String? {
        didSet {
            print(userToken)
        }
    }
}
