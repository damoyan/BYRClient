//
//  BYRAttachment.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/31/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

// if type == .Emotion, tag is nil
public class BYRAttachment: NSTextAttachment {
    
    enum AttachmentType {
        case Audio, Video, OtherFile
        case Img(String), Emotion(String)
        case Upload(Int)
    }
    
    var tag: Tag? {
        didSet {
            guard let tag = self.tag else { return }
            switch tag.tagName.lowercaseString {
            case "upload":
                if let att = tag.attributes, no = (att["upload"] as? String)?.integerValue {
                    type = .Upload(no)
                }
            case "img":
                if let att = tag.attributes, url = att["img"] as? String {
                    type = .Img(url)
                }
                // TODO: - add more type
            default:
                break
            }
        }
    }
    var type: AttachmentType = .OtherFile
    var imageUrl: String?
    var images: [UIImage]? {
        didSet {
            if images?.count == 1 {
                self.image = images?[0]
            }
        }
    }
    
    static let emotionSizes = [
        "em": CGSize(width: 10, height: 10),
        "ema": CGSize(width: 25, height: 25),
        "emb": CGSize(width: 25, height: 25),
        "emc": CGSize(width: 25, height: 25)
    ]
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if case .Emotion(let name) = type {
            if name.hasPrefix("emc") {
                return CGRect(origin: CGPoint(x: 0, y: ArticleConfig.font.descender), size: BYRAttachment.emotionSizes["emc"]!)
            } else if name.hasPrefix("emb") {
                return CGRect(origin: CGPoint(x: 0, y: ArticleConfig.font.descender), size: BYRAttachment.emotionSizes["emb"]!)
            } else if name.hasPrefix("ema") {
                return CGRect(origin: CGPoint(x: 0, y: ArticleConfig.font.descender), size: BYRAttachment.emotionSizes["ema"]!)
            } else if name.hasPrefix("em") {
                return CGRect(origin: CGPoint(x: 0, y: ArticleConfig.font.descender), size: BYRAttachment.emotionSizes["em"]!)
            }
        }
        var size: CGSize
        if let image = self.image {
            size = image.size
        } else {
            size = bounds.size
        }
        if size.width > lineFrag.width {
            size.height *= (lineFrag.width / size.width)
            size.width = lineFrag.width
        }
        return CGRect(origin: CGPoint(x: 0, y: ArticleConfig.font.descender), size: size)
    }
    
    deinit {
        print("deinit attachment")
    }
}
