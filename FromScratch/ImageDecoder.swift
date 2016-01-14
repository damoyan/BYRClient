//
//  ImageDecoder.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/13/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit
import ImageIO

protocol ImageDecoder {
    var firstFrame: UIImage? { get }
    var frameCount: Int { get }
    var totalTime: NSTimeInterval { get }
    func imageAtIndex(index: Int) -> UIImage?
    func imageDurationAtIndex(index: Int) -> NSTimeInterval
}

class BYRImageDecoder: ImageDecoder {
    
    private let scale: CGFloat
    private let data: NSData
    private var source: CGImageSource?
    private var durations = [NSTimeInterval]()
    
    var firstFrame: UIImage? = nil
    var frameCount: Int = 0
    var totalTime: NSTimeInterval = 0
    
    init(data: NSData, scale: CGFloat = UIScreen.mainScreen().scale) {
        self.data = data
        self.scale = scale
        source = CGImageSourceCreateWithData(data, nil)
        generateImageInfo()
    }
    
    // MARK: - ImageDecoder
    func imageAtIndex(index: Int) -> UIImage? {
        guard let source = self.source else { return nil }
        if let cgimage = CGImageSourceCreateImageAtIndex(source, index, nil) {
            return decodeCGImage(cgimage, withScale: scale)
        }
        return nil
    }
    
    func imageDurationAtIndex(index: Int) -> NSTimeInterval {
        guard index < durations.count else { return 0 }
        /*
        http://opensource.apple.com/source/WebCore/WebCore-7600.1.25/platform/graphics/cg/ImageSourceCG.cpp
        Many annoying ads specify a 0 duration to make an image flash as quickly as
        possible. We follow Safari and Firefox's behavior and use a duration of 100 ms
        for any frames that specify a duration of <= 10 ms.
        See <rdar://problem/7689300> and <http://webkit.org/b/36082> for more information.
        
        See also: http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser.
        */
        let duration = durations[index]
        return duration < 0.011 ? 0.1 : duration
    }
    
    // MARK: - Private
    private func generateImageInfo() {
        guard let source = self.source else { return }
        frameCount = CGImageSourceGetCount(source)
        durations = [NSTimeInterval](count: frameCount, repeatedValue: 0)
        for index in 0..<frameCount {
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) else {
                continue
            }
            if index == 0, let cgimage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                firstFrame = decodeCGImage(cgimage, withScale: scale)
            }
            
            if let gifDict = getValue(properties, key: kCGImagePropertyGIFDictionary, type: CFDictionary.self) {
                if let unclampedDelay = getValue(gifDict, key: kCGImagePropertyGIFUnclampedDelayTime, type: NSNumber.self) {
                    durations[index] = unclampedDelay.doubleValue
                } else if let delay = getValue(gifDict, key: kCGImagePropertyGIFDelayTime, type: NSNumber.self) {
                    durations[index] = delay.doubleValue
                }
            }
        }
    }
    
    // swift version of SDWebImage decoder (just copy code)
    private func decodeCGImage(image: CGImage, withScale scale: CGFloat) -> UIImage? {
        let imageSize = CGSize(width: CGImageGetWidth(image), height: CGImageGetHeight(image))
        let imageRect = CGRect(origin: CGPointZero, size: imageSize)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGImageGetBitmapInfo(image).rawValue
        
        let infoMask = bitmapInfo & CGBitmapInfo.AlphaInfoMask.rawValue
        let anyNonAlpha = (infoMask == CGImageAlphaInfo.None.rawValue ||
            infoMask == CGImageAlphaInfo.NoneSkipFirst.rawValue ||
            infoMask == CGImageAlphaInfo.NoneSkipLast.rawValue)
        
        if infoMask == CGImageAlphaInfo.None.rawValue && CGColorSpaceGetNumberOfComponents(colorSpace) > 1 {
            bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask.rawValue
            bitmapInfo |= CGImageAlphaInfo.NoneSkipFirst.rawValue
        } else if !anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3 {
            bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask.rawValue
            bitmapInfo |= CGImageAlphaInfo.PremultipliedFirst.rawValue
        }
        
        guard let context = CGBitmapContextCreate(nil, Int(imageSize.width), Int(imageSize.height), CGImageGetBitsPerComponent(image), 0, colorSpace, bitmapInfo) else { return nil }
        CGContextDrawImage(context, imageRect, image)
        guard let newImage = CGBitmapContextCreateImage(context) else { return nil }
        return UIImage(CGImage: newImage, scale: scale, orientation: .Up)
    }
    
    private func getValue<T>(dict: CFDictionary, key: CFString, type: T.Type) -> T? {
        let nkey = unsafeBitCast(key, UnsafePointer<Void>.self)
        let v = CFDictionaryGetValue(dict, nkey)
        if v == nil {
            return nil
        }
        return unsafeBitCast(v, type)
    }
}