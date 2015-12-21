//
//  Favorite.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Favorite: NSObject {
    let level: Int?
    let desc: String?
    let position: Int?
//    let subFavorites: [Favorite]?
//    let sections: [Section]?
//    let boards: [Board]?
    
    init(data: JSON) {
        level = data[_keys.level].int
        desc = data[_keys.desc].string
        position = data[_keys.position].int
    }
    
    struct _keys {
        static let level = "level", desc = "description", position = "position", subFavorites = "sub_favorite", sections = "section", boards = "board"
    }
}

