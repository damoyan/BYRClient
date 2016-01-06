//
//  Attachment.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/1/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Attachment: NSObject {
    let file: [File]?
    let remainSpace: String?
    let remainCount: String?
    
    init(data: JSON) {
        if let fs = data[_keys.file].array {
            file = fs.map(File.init)
        } else {
            file = nil
        }
        remainSpace = data[_keys.remainSpace].string
        remainCount = data[_keys.remainCount].string
    }
    
    class File {
        let name: String?
        let url: String?
        let size: String?
        let small: String?
        let middle: String?
        var isImage: Bool {
            guard let name = self.name else { return false }
            if imageExtensions.contains((name as NSString).pathExtension) {
                return true
            }
            return false
        }
        
        init(data: JSON) {
            name = data[_keys.name].string
            url = data[_keys.url].string
            size = data[_keys.size].string
            small = data[_keys.small].string
            middle = data[_keys.middle].string
        }
        
        struct _keys {
            static let name = "name", url = "url", size = "size", small = "thumbnail_small", middle = "thumbnail_middle"
        }
    }
    
    struct _keys {
        static let file = "file", remainSpace = "remain_space", remainCount = "remain_count"
    }
}
