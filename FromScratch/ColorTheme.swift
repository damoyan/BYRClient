//
//  ColorTheme.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

protocol ColorTheme {
    var BoardNaviCellTitleColor: UIColor { get }
    var BoardNaviCellSubtitleColor: UIColor { get }
}

class Light: ColorTheme {
    var BoardNaviCellTitleColor = UIColor.blackColor()
    var BoardNaviCellSubtitleColor = UIColor.grayColor()
}