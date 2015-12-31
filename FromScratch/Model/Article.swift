//
//  Article.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/22/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Article: NSObject {
    let id: Int?
    let groupID: Int?
    let replyID: Int?
    let flag: String?
    let position: Int?
    let isTop: Bool?
    let isSubject: Bool?
    let hasAttachment: Bool?
    let isAdmin: Bool?
    let title: String?
    let user: User?
    let postTime: NSDate?
    let boardName: String?
    let content: String?
    // FIXME: - 
    let attachment: Int? = nil
    let previousID: Int?
    let nextID: Int?
    let previousIDInThread: Int?
    let nextIDInThread: Int?
    let replyCount: Int?
    let lastReplyUserID: String?
    let lastReplyTime: NSDate?
    let idCount: Int?
    let isLiked: Bool?
    let collect: Bool?
    let likeSum: String?
    let likedReplys: [Article]?
    let replys: [Article]?
    let pagination: Pagination?
    
    init(data: JSON) {
        id                  = data[_keys.id].int
        groupID             = data[_keys.groupID].int
        replyID             = data[_keys.replyID].int
        flag                = data[_keys.flag].string
        position            = data[_keys.position].int
        isTop               = data[_keys.isTop].bool
        isSubject           = data[_keys.isSubject].bool
        hasAttachment       = data[_keys.hasAttachment].bool
        isAdmin             = data[_keys.isAdmin].bool
        title               = data[_keys.title].string
        user                = data[_keys.user] == nil ? nil : User(data: data[_keys.user])
        postTime            = Utils.dateFromUnixTimestamp(data[_keys.postTime].int)
        boardName           = data[_keys.boardName].string
        content             = Article.removeANSICode(data[_keys.content].string)
        //
//        attachment          = data[_keys.attachment].int
        previousID          = data[_keys.previousID].int
        nextID              = data[_keys.nextID].int
        previousIDInThread  = data[_keys.previousIDInThread].int
        nextIDInThread      = data[_keys.nextIDInThread].int
        replyCount          = data[_keys.replyCount].int
        lastReplyUserID     = data[_keys.lastReplyUserID].string
        lastReplyTime       = Utils.dateFromUnixTimestamp(data[_keys.lastReplyTime].int)
        idCount             = data[_keys.idCount].int
        isLiked             = data[_keys.isLiked].bool
        collect             = data[_keys.collect].bool
        likeSum             = data[_keys.likeSum].string
        if let articles = data[_keys.likedReplys].array {
            self.likedReplys = articles.map (Article.init)
        } else { likedReplys = nil }
        if let articles = data[_keys.replys].array {
            self.replys = articles.map (Article.init)
        } else { replys = nil }
        if let _ = data[_keys.pagination].error {
            pagination = nil
        } else {
            pagination = Pagination(data: data[_keys.pagination])
        }
    }
    
    struct _keys {
        static let id = "id", groupID = "group_id", replyID = "reply_id", flag = "flag", position = "position", isTop = "is_top", isSubject = "is_subject", hasAttachment = "has_attachment", isAdmin = "is_admin", title = "title", user = "user", postTime = "post_time", boardName = "board_name", content = "content", attachment = "attachment", previousID = "previous_id", nextID = "next_id", previousIDInThread = "threads_previous_id", nextIDInThread = "threads_next_id", replyCount = "reply_count", lastReplyUserID = "last_reply_user_id", lastReplyTime = "last_reply_time", idCount = "id_count", isLiked = "is_liked", collect = "collect", likeSum = "like_sum", likedReplys = "like_articles", replys = "article", pagination = "pagination"
    }
    
    
    class func removeANSICode(string: String?) -> String? {
        guard let content = string else { return nil }
        let regex = try? NSRegularExpression(pattern: "\\u001b\\[[^m]*?[mABCDsuHJK]", options: [])
        if let ret = regex?.stringByReplacingMatchesInString(content, options: [], range: NSMakeRange(0, content.utf16.count), withTemplate: "") {
            return ret
        }
        return nil
    }
}
