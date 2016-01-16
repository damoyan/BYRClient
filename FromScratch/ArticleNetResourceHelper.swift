//
//  ImageHelper.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/5/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit
import Alamofire
import ImageIO

typealias BYRResourceDownloadCompletionHandler = (String, NSData?, NSError?) -> ()

private var lock = OS_SPINLOCK_INIT
class ArticleNetResourceHelper {
    
    static let defaultHelper: ArticleNetResourceHelper = {
       return ArticleNetResourceHelper()
    }()
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: DataDelegate(), delegateQueue: nil)
    var imageDownloadCompletionHandler: BYRResourceDownloadCompletionHandler?

    /// `handler` is called on background thread after task is completed.
    func getResourceWithURLString(queue: dispatch_queue_t? = dispatch_get_main_queue(), urlString: String, completionHandler handler: BYRResourceDownloadCompletionHandler) {
        let s = urlString + "?oauth_token=\(AppSharedInfo.sharedInstance.userToken!)"
//        request(.GET, s).response(queue: queue) { (_, _, d, e) -> Void in
//            handler(urlString, d, e)
//        }
        
        guard let url = NSURL(string: s) else { return }
        let task = session.dataTaskWithURL(url)
        if let delegate = session.delegate as? DataDelegate {
            if urlString.containsString("middle") {
                po("add handler for ", urlString)
            }
            OSSpinLockLock(&lock)
            delegate.imageDownloadCompletionHandlers[task] = (urlString, handler)
            OSSpinLockUnlock(&lock)
        }
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
        var imageDownloadCompletionHandlers: [NSURLSessionTask: (String, BYRResourceDownloadCompletionHandler)] = [:]
        
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
            if task.currentRequest!.URLString.containsString("middle")  { po("task finish") }
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
            OSSpinLockLock(&lock)
            if let handler = imageDownloadCompletionHandlers[task] {
                handler.1(handler.0, data, error)
            }
            datas.removeValueForKey(task)
            imageDownloadCompletionHandlers.removeValueForKey(task)
            OSSpinLockUnlock(&lock)
        }
    }
}

class ImageHelper {
    
    typealias Handler = (String?, ImageDecoder?, NSError?) -> ()
    static let _queue = NSOperationQueue()
    
    class func getImageWithURLString(urlString: String, completionHandler handler: Handler) {
        _queue.addOperationWithBlock {
            ArticleNetResourceHelper.defaultHelper.getResourceWithURLString(_queue.underlyingQueue, urlString: urlString) { (urlString, data, error) -> () in
                if urlString.containsString("middle") { po("finish", urlString) }
                guard let data = data else {
                    runHandlerOnMain(handler, urlString: urlString, decoder: nil, error: error)
                    return
                }
                let decoder = BYRImageDecoder(data: data)
                runHandlerOnMain(handler, urlString: urlString, decoder: decoder, error: nil)
            }
        }
    }
    
    class func getImageWithData(data: NSData, completionHandler handler: Handler) {
        _queue.addOperationWithBlock { () -> Void in
            let decoder = BYRImageDecoder(data: data)
            runHandlerOnMain(handler, urlString: nil, decoder: decoder, error: nil)
        }
    }
    
    class func runHandlerOnMain(handler: Handler, urlString: String?, decoder: ImageDecoder?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            handler(urlString, decoder, error)
        })
    }
}


