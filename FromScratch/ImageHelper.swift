//
//  ImageHelper.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/5/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit
import ImageIO

public class ImageHelper {
    
    public static let defaultHelper: ImageHelper = {
       return ImageHelper()
    }()
    
    public typealias BYRImageDownloadCompletionHandler = ([UIImage]) -> ()
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: DataDelegate(), delegateQueue: nil)
    var imageDownloadCompletionHandler: BYRImageDownloadCompletionHandler?

    public func getImageWithURLString(urlString: String, completionHandler handler: BYRImageDownloadCompletionHandler) {
        guard let url = NSURL(string: urlString) else { return }
        let task = session.dataTaskWithURL(url)
        (session.delegate as? DataDelegate)?.imageDownloadCompletionHandler = handler
        task.resume()
    }
    
    class DataDelegate: NSObject, NSURLSessionDataDelegate {
        
        private var expectedContentLength: Int64 = -1
        private var downloadedContentLength: Int64 = 0
        var progress: Double = 0
        private(set) var data: NSMutableData = NSMutableData()
        
        var imageDownloadCompletionHandler: BYRImageDownloadCompletionHandler?
        
        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
            expectedContentLength = response.expectedContentLength
            downloadedContentLength = 0
            progress = 0
            completionHandler(NSURLSessionResponseDisposition.Allow)
        }
        
        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            downloadedContentLength += data.length
            progress = Double(downloadedContentLength) / Double(expectedContentLength)
            self.data.appendData(data)
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            print(NSThread.currentThread().isMainThread)
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let source = CGImageSourceCreateWithData(data, nil) else {
                print("cannot create image source")
                return
            }
            let frameCount = CGImageSourceGetCount(source)
            let type = CGImageSourceGetType(source)
            print("image type: ", type)
            print("data length", data.length)
            print("frameCount", frameCount)
            var images = [UIImage]()
            for var i = 0; i < frameCount; i++ {
                if let cgimage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(CGImage: cgimage))
                }
            }
            if let handler = imageDownloadCompletionHandler {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    handler(images)
                })
            }
        }
    }
}
    

