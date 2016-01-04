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
    
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let image = self.image {
            var size = image.size
            if size.width > lineFrag.width {
                size.height *= (lineFrag.width / size.width)
                size.width = lineFrag.width
            }
            return CGRect(origin: CGPoint(x: 0, y: ArticleConfig.font.descender), size: size)
        } else {
            return bounds
        }
    }
}
