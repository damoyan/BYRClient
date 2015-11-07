//
//  Section.swift
//  FromScratch
//
//  Created by Yu Pengyang on 11/7/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import SwiftyJSON

class Section: NSObject {
    let id: String
    let name: String?
    let isRoot: Bool
    let parent: String?
    
    init(data: JSON) {
        id = data[_keys.id].stringValue
        name = data[_keys.name].string
        isRoot = data[_keys.isRoot].boolValue
        parent = data[_keys.parent].string
    }
    
    let _keys = (id: "name", name: "description", isRoot: "is_root", parent: "parent")
    
    class func generateArray(data: JSON) -> [Section] {
        guard let array = data.array else {
            return []
        }
        var res = [Section]()
        for j in array {
            res.append(Section(data: j))
        }
        return res
    }
}
