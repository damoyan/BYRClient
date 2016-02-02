//: Playground - noun: a place where people can play

import UIKit

enum TaskError: ErrorType {
    case Cancelled
}

enum Result<T>: ErrorType {
    case Success(T)
    case Fail(ErrorType)
}

// download Task factory
//protocol Downloader {
//}
//
//protocol Decoder {
//    
//}

// This is a abstract class, can not be used directly, please subclass it on your need
// you should implement all the decleared methods
//class Task<Input, Output> {
//    typealias ProcessMonitor = (Task, Input, NSProgress) -> Void
//    typealias CompletionHandler = (Task, Input, Result<Output>) -> Void
//    
//    let input: Input
//    let processMonitor: ProcessMonitor?
//    let completionHandler: CompletionHandler?
//    
//    init(input: Input, processMonitor: ProcessMonitor?, completionHandler: CompletionHandler?) {
//        self.input = input
//        self.processMonitor = processMonitor
//        self.completionHandler = completionHandler
//    }
//    
//    class func createA(input: Input, processMonitor: ProcessMonitor?, completionHandler: CompletionHandler?) -> Task {
//        return Task(input: input, processMonitor: processMonitor, completionHandler: completionHandler)
//    }
//    
//    func resume() {}
//    func cancel() {}
//    func isCancelled() -> Bool { return false }
//}
//
//class TaskContainer<Input, Output>: Task<Input, Output> {
//    private var tasks: Array<Task<Input, Output>> = []
//    var currentTaskIndex: Int = -1
//    
//    func addTask(input: Input, pm: ProcessMonitor?, ch: CompletionHandler?) -> Task<Input, Output> {
//        return Task(input: input, processMonitor: encapsulateProcessMonitor(pm), completionHandler: ch)
//    }
//    
//    func encapsulateProcessMonitor(pm: ProcessMonitor?) -> ProcessMonitor? {
//        guard let pm = pm else { return nil }
//        return { task, input, progress in
//            guard !self.isCancelled() else {
//                self.completionHandler?(task, input, Result.Fail(TaskError.Cancelled))
//                return
//            }
//            pm(task, input, progress)
//        }
//    }
//    
//    func encapsulateCompletionHandler(ch: CompletionHandler?) -> CompletionHandler? {
//        guard let ch = ch else { return nil }
//        return { task, input, result in
//            assert((0..<self.tasks.count).contains(self.currentTaskIndex), "index is out of range")
//            assert(self.tasks[self.currentTaskIndex] === task, "current task is not matched with the index")
//            guard !self.isCancelled() else {
//                self.completionHandler?(task, input, Result.Fail(TaskError.Cancelled))
//                return
//            }
//            ch(task, input, result)
//        }
//    }
//}

//typealias ProcessMonitor = (NSProgress?, ErrorType?) -> Void
//
//// task just download data, no needs to decode data
//protocol DownloadTask {
//    typealias DownloadedObject
//    typealias ResponseHandler = (NSURL, Result<DownloadedObject>) -> Void
//    static func createTask(url: NSURL, processMonitor: ProcessMonitor?, responseHandler: ResponseHandler) -> Self
//}
//
//protocol DataTask: DownloadTask {
//    
//    typealias DecodedObject
//    typealias DecodeAction = (Result<DownloadedObject>) -> Result<DecodedObject>
//    typealias CompletionHandler = (Result<DecodedObject>) -> Void
//    
//    static func createTask(url: NSURL, processMonitor: ProcessMonitor?, decoder: DecodeAction?, completionHandler: CompletionHandler?) -> Self
//}
//
//
//class DataDownloader: Downloader {
//    static let session: NSURLSession = {
//        let delegate = DataDownloaderDelegate()
//        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: delegate, delegateQueue: nil)
//    }()
//    
////    static func createTask(url: NSURL, processMonitor: ProcessMonitor?, responseHandler: () -> ()) -> Task {
////        return
////    }
//}
//
//// all in one
//class DataDownloaderDelegate: NSObject, NSURLSessionDataDelegate {
//    
//}

protocol Task {
    func resume()
    func cancel()
}

typealias ProcessMonitor = (NSURL, NSProgress) -> Void
typealias CompletionHandler = (NSURL, Result<NSData>) -> Void

class Downloader: NSObject, Task {
    
    static let queue = NSOperationQueue()
    static let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: DownloaderDelegate(), delegateQueue: queue)
    
    var task: NSURLSessionTask?
    
    static func createDownloader(url: NSURL, startImmediately: Bool = true, processMonitor: ProcessMonitor?, completionHandler: CompletionHandler?) -> Downloader {
        let d = Downloader()
        let task = Downloader.session.dataTaskWithURL(url)
        (Downloader.session.delegate as! DownloaderDelegate).tasks[task] = (processMonitor, completionHandler)
        d.task = task
        if startImmediately {
            task.resume()
        }
        return d
    }
    
    
    func resume() {
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}

class DownloaderDelegate: NSObject, NSURLSessionDataDelegate {
    var tasks = [NSURLSessionTask: (ProcessMonitor?, CompletionHandler?)]()
}
