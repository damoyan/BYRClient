//
//  Utils.swift
//  FromScratch
//
//  Created by Yu Pengyang on 11/7/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static var defaultDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .LongStyle
        return formatter
    }()
    
    static var main: UIStoryboard = {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }()
    
    static func dateFromUnixTimestamp(ts: Int?) -> NSDate? {
        guard let ts = ts else {
            return nil
        }
        return NSDate(timeIntervalSince1970: NSTimeInterval(ts))
    }
}

extension UIViewController {
    
    func navigateToLogin() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func navigateToSectionDetail(section: Section) {
        let vc = Utils.main.instantiateViewControllerWithIdentifier("vcSection") as! SectionViewController
        vc.section = section
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToFavorite(level: Int) {
        let vc = Utils.main.instantiateViewControllerWithIdentifier("vcFavorite") as! FavoriteViewController
        vc.level = level
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToBoard(name: String) {
        let vc = Utils.main.instantiateViewControllerWithIdentifier("vcBoard") as! BoardViewController
        vc.boardName = name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToThread(article: Article) {
        let vc = Utils.main.instantiateViewControllerWithIdentifier("vcThread") as! ThreadViewController
        vc.topic = article
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NSDate {
    
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