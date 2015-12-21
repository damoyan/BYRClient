//
//  Board.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import SwiftyJSON

class Board: NSObject {
    let name: String?
    let manager: String?
    let desc: String?
    let clazz: String?
    let section: String?
    let todayThreadsCount: UInt?
    let todayPostsCount: UInt?
    let allThreadsCount: UInt?
    let allPostsCount: UInt?
    let onlineUsersCount: UInt?
    let isReadOnly: Bool?
    let isNoReply: Bool?
    let allowAttachment: Bool?
    let allowAnonymous: Bool?
    let allowOutgo: Bool?
    let allowPost: Bool?
    
    init(data: JSON) {
        name                = data[_keys.name].string
        manager             = data[_keys.manager].string
        desc                = data[_keys.desc].string
        clazz               = data[_keys.clazz].string
        section             = data[_keys.section].string
        todayThreadsCount   = data[_keys.todayThreadsCount].uInt
        todayPostsCount     = data[_keys.todayPostsCount].uInt
        allThreadsCount     = data[_keys.allThreadsCount].uInt
        allPostsCount       = data[_keys.allPostsCount].uInt
        onlineUsersCount    = data[_keys.onlineUsersCount].uInt
        isReadOnly          = data[_keys.isReadOnly].bool
        isNoReply           = data[_keys.isNoReply].bool
        allowAttachment     = data[_keys.allowAttachment].bool
        allowAnonymous      = data[_keys.allowAnonymous].bool
        allowOutgo          = data[_keys.allowOutgo].bool
        allowPost           = data[_keys.allowPost].bool
    }
    
    struct _keys {
        static let name = "name", manager = "manager", desc = "description", clazz = "class", section = "section", todayThreadsCount = "threads_today_count", todayPostsCount = "post_today_count", allThreadsCount = "post_threads_count", allPostsCount = "post_all_count", onlineUsersCount = "user_online_count", isReadOnly = "is_read_only", isNoReply = "is_no_reply", allowAttachment = "allow_attachment", allowAnonymous = "allow_anonymous", allowOutgo = "allow_outgo", allowPost = "allow_post"
    }
}
