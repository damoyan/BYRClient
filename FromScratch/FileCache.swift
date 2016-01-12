//
//  FileCache.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/12/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import Foundation

class FileCache {

    static func load(name: String) -> AnyObject? {
        let path = getCachedFilePath(name)
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path)
    }

    static func save(data: NSCoding, name: String) throws -> Bool {
        let path = getCachedFilePath(name)
        try ensureFileAccessable(path, isDirectory: false)
        return NSKeyedArchiver.archiveRootObject(data, toFile: path)
    }

    static func getCachedFilePath(name: String, subDirectory dir: String? = nil) -> String {
        var fileDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        if let dir = dir {
            fileDir = (fileDir as NSString).stringByAppendingPathComponent(dir)
        }
        return (fileDir as NSString).stringByAppendingPathComponent(name)
    }

    static func ensureFileAccessable(path: String, isDirectory: Bool) throws {
        let url = NSURL(fileURLWithPath: path, isDirectory: isDirectory)
        guard url.fileURL else { throw BYRFileHandleError.NotFilePath(path) }
        guard let fpath = url.path else { throw BYRFileHandleError.NotFilePath(path) }
        let isFolderP = UnsafeMutablePointer<ObjCBool>.alloc(1)
        let manager = NSFileManager.defaultManager()
        print(manager.currentDirectoryPath)
        if !manager.fileExistsAtPath(fpath, isDirectory: isFolderP) {
            if isDirectory {
                try manager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            } else {
                if !manager.createFileAtPath(fpath, contents: nil, attributes: nil) {
                    try ensureFileAccessable((fpath as NSString).stringByDeletingLastPathComponent, isDirectory: true)
                    if !manager.createFileAtPath(fpath, contents: nil, attributes: nil) {
                        throw BYRFileHandleError.CreateFileFail(fpath)
                    }
                }
            }
        } else {
            if !isFolderP.memory && isDirectory { // need to be dir but not dir
                // delete file and create folder
                try manager.removeItemAtPath(fpath)
                try manager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            } else if isFolderP.memory && !isDirectory { // need to be file but is dir
                // delete dir and create file
                try manager.removeItemAtPath(fpath)
                if !manager.createFileAtPath(fpath, contents: nil, attributes: nil) {
                    throw BYRFileHandleError.CreateFileFail(fpath)
                }
            }
        }
    }
}