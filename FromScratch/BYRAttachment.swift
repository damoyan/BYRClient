//
//  BYRAttachment.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/31/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class BYRAttachment: NSTextAttachment {
    
    enum AttachmentType {
        case AnimatedImage, NormalImage, Audio, Video, OtherFile
    }
    
    var text: String?
    var type: AttachmentType = .NormalImage
}
