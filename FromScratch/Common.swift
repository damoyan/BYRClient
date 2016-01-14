//
//  Common.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/27/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import Foundation

enum BYRError: ErrorType {
    case CreateImageSourceFailed
}

enum BYRFileHandleError: ErrorType {
    case NotFilePath(String), CreateFileFail(String)
}

// supported image type
let imageExtensions = ["tiff", "ico", "gif", "jpg", "jpeg", "png", "bmp", "jfif", "iptc"]
