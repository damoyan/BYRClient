//
//  Utils.swift
//  FromScratch
//
//  Created by Yu Pengyang on 11/7/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import ImageIO

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
    
    static func getImagesFromData(data: NSData) throws -> [UIImage] {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            throw BYRError.CreateImageSourceFailed
        }
        var images = [UIImage]()
        autoreleasepool {
            let frameCount = CGImageSourceGetCount(source)
            for var i = 0; i < frameCount; i++ {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    let alphaInfo = CGImageGetAlphaInfo(image).rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
                    let hasAlpha: Bool
                    if (alphaInfo == CGImageAlphaInfo.PremultipliedLast.rawValue ||
                        alphaInfo == CGImageAlphaInfo.PremultipliedFirst.rawValue ||
                        alphaInfo == CGImageAlphaInfo.Last.rawValue ||
                        alphaInfo == CGImageAlphaInfo.First.rawValue) {
                            hasAlpha = true
                    } else {
                        hasAlpha = false
                    }
                    //            // BGRA8888 (premultiplied) or BGRX8888
                    //            // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
                    
                    
                    var bitmapInfo = CGBitmapInfo.ByteOrderDefault.rawValue // kCGBitmapByteOrder32Host;
                    bitmapInfo |= hasAlpha ? CGImageAlphaInfo.PremultipliedLast.rawValue : CGImageAlphaInfo.NoneSkipFirst.rawValue;
                    let context = CGBitmapContextCreate(nil, CGImageGetWidth(image), CGImageGetHeight(image), 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo)
                    CGContextDrawImage(context, CGRect(x: 0, y: 0, width: CGImageGetWidth(image), height: CGImageGetHeight(image)), image) // decode
                    let newImage = CGBitmapContextCreateImage(context)!
                    images.append(UIImage(CGImage: newImage))
                }
            }
        }
        return images
    }
    
    static func getEmotionData(name: String) -> NSData? {
        var imageName: String, imageFolder: String
        let folderPrefix = "emotions/"
        if name.hasPrefix("emc") {
            imageFolder = folderPrefix + "emc"
            imageName = (name as NSString).substringFromIndex(3)
        } else if name.hasPrefix("emb") {
            imageFolder = folderPrefix + "emb"
            imageName = (name as NSString).substringFromIndex(3)
        } else if name.hasPrefix("ema") {
            imageFolder = folderPrefix + "ema"
            imageName = (name as NSString).substringFromIndex(3)
        } else {
            imageFolder = folderPrefix + "em"
            imageName = (name as NSString).substringFromIndex(2)
        }
        let path = NSBundle.mainBundle().pathForResource(imageName, ofType: "gif", inDirectory: imageFolder)
        if let path = path, data = NSData(contentsOfFile: path) {
            return data
        }
        return nil
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
    
    func presentCompose(article: Article?, boardName: String? = nil, callback: (Bool, Article?, NSError?) -> Void) {
        let vc = Utils.main.instantiateViewControllerWithIdentifier("vcCompose") as! ComposeViewController
        vc.article = article
        vc.boardName = boardName
        vc.callback = callback
        let navi = UINavigationController(rootViewController: vc)
        presentViewController(navi, animated: true, completion: nil)
    }
}

extension NSDate {
    func friendly() -> String {
        let elapsed = NSDate().timeIntervalSinceDate(self)
        if elapsed < 60 {
            return "刚刚"
        } else if elapsed < 3600 {
            return "\(Int(elapsed / 60))分钟前"
        } else if elapsed < 86400 {
            return "\(Int(elapsed / 3600))小时前"
        } else if elapsed < 2592000 {
            return "\(Int(elapsed / 86400))天前"
        } else if elapsed < 31536000 {
            return "\(Int(elapsed / 2592000))个月前"
        } else {
            return "\(Int(elapsed / 31536000))年前"
        }
    }
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
    
    convenience init(rgbString: String) {
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        
        let str = rgbString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        var start = -1
        if str.hasPrefix("#") && str.characters.count == 7 {
            start = 1
        } else if str.hasPrefix("0X") && str.characters.count == 9 {
            start = 2
        }
        
        if (start >= 0) {
            let rStr = str[start..<start+2]
            let gStr = str[start+2..<start+4]
            let bStr = str[start+4..<start+6]
            NSScanner(string: rStr).scanHexInt(&r)
            NSScanner(string: gStr).scanHexInt(&g)
            NSScanner(string: bStr).scanHexInt(&b)
        }
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var integerValue: Int {
        return (self as NSString).integerValue
    }
    
    var sha1: String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}