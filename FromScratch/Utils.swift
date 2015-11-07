//
//  Utils.swift
//  FromScratch
//
//  Created by Yu Pengyang on 11/7/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class Utils: NSObject {

}


extension UIImage {
    class func imageWithColor(color: UIColor, side: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: side, height: side)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor {
    convenience init(rgb: UInt, alpha: CGFloat = 1) {
        self.init(red: CGFloat((rgb & 0xff0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00ff00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000ff) / 255.0,
            alpha: CGFloat(alpha))
    }
}