//
//  ImageHelper.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/5/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit
import ImageIO

typealias BYRResourceDownloadCompletionHandler = (NSData?, NSError?) -> ()

class ArticleNetResourceHelper {
    
    static let defaultHelper: ArticleNetResourceHelper = {
       return ArticleNetResourceHelper()
    }()
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: DataDelegate(), delegateQueue: nil)
    var imageDownloadCompletionHandler: BYRResourceDownloadCompletionHandler?

    /// `handler` is called on background thread after task is completed.
    func getResourceWithURLString(urlString: String, completionHandler handler: BYRResourceDownloadCompletionHandler) {
        guard let url = NSURL(string: urlString) else { return }
        let task = session.dataTaskWithURL(url)
        (session.delegate as? DataDelegate)?.imageDownloadCompletionHandlers[task] = handler
        task.resume()
    }
    
    class DataDelegate: NSObject, NSURLSessionDataDelegate {
        
        class TaskData {
            var data: NSMutableData = NSMutableData()
            var expectedContentLength: Int64 = -1
            private var downloadedContentLength: Int64 = 0
            var progress: Double = 0
        }
        var datas = [NSURLSessionTask: TaskData]()
        var imageDownloadCompletionHandlers: [NSURLSessionTask: BYRResourceDownloadCompletionHandler] = [:]
        
        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
            let data = TaskData()
            data.expectedContentLength = response.expectedContentLength
            data.downloadedContentLength = 0
            data.progress = 0
            datas[dataTask] = data
            completionHandler(NSURLSessionResponseDisposition.Allow)
        }
        
        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            guard let taskData = datas[dataTask] else { return }
            taskData.downloadedContentLength += data.length
            taskData.progress = Double(taskData.downloadedContentLength) / Double(taskData.expectedContentLength)
            taskData.data.appendData(data)
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            guard let taskData = datas[task] else {
                let error = NSError(domain: BYRErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No data return."])
                handleCallback(task, data: nil, error: error)
                return
            }
            guard error == nil else {
                handleCallback(task, data: nil, error: error)
                return
            }
            handleCallback(task, data: taskData.data, error: nil)
        }
        
        func handleCallback(task: NSURLSessionTask, data: NSData?, error: NSError?) {
            if let handler = imageDownloadCompletionHandlers[task] {
                handler(data, error)
            }
            datas.removeValueForKey(task)
            imageDownloadCompletionHandlers.removeValueForKey(task)
        }
    }
}

class ImageHelper {
    
    typealias Handler = ([UIImage]?, NSError?) -> ()
    
    class func getImageWithURLString(urlString: String, completionHandler handler: Handler) {
        ArticleNetResourceHelper.defaultHelper.getResourceWithURLString(urlString) { (data, error) -> () in
            guard let data = data else {
                runHandlerOnMain(handler, images: nil, error: error)
                return
            }
            do {
                let images = try Utils.getImagesFromData(data)
                runHandlerOnMain(handler, images: images, error: nil)
            } catch {
                let e = NSError(domain: BYRErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "returned data is not image convertable."])
                runHandlerOnMain(handler, images: nil, error: e)
            }
        }
    }
    
    class func runHandlerOnMain(handler: Handler, images: [UIImage]?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            handler(images, error)
        })
    }
}


