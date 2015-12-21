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
    let name: String?
    let desc: String?
    let isRoot: Bool?
    let parent: String?
    let subSections: [Section]?
    let boards: [Board]?
    
    init(data: JSON) {
        name = data[_keys.name].string
        desc = data[_keys.desc].string
        isRoot = data[_keys.isRoot].bool
        parent = data[_keys.parent].string
        if let subsectionNames = data[_keys.subSections].arrayObject as? [String] {
            subSections = subsectionNames.map { JSON(["name": $0]) }.map { Section(data: $0) }
        } else {
            subSections = nil
        }
        if let jsons = data[_keys.boards].array {
            boards = jsons.map { Board(data: $0) }
        } else {
            boards = nil
        }
    }
    
    struct _keys {
        static let name = "name", desc = "description", isRoot = "is_root", parent = "parent", subSections = "sub_section", boards = "board"
    }
    
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
