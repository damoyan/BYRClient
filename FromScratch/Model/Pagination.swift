//
//  Pagination.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/22/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Pagination: NSObject {
    
    let pageCount: Int?
    let currentPage: Int?
    let perPage: Int?
    let allItemCount: Int?
    
    init(data: JSON) {
        pageCount = data[_keys.pageCount].int
        currentPage = data[_keys.currentPage].int
        perPage = data[_keys.perPage].int
        allItemCount = data[_keys.allItemCount].int
    }
    
    struct _keys {
        static let pageCount = "page_all_count", currentPage = "page_current_count", perPage = "item_page_count", allItemCount = "item_all_count"
    }
}
