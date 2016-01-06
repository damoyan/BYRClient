//
//  ArticleCell.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import RxSwift

struct ArticleConfig {
    static var font = UIFont.systemFontOfSize(defaultArticleFontSize)
    static var color = UIColor.darkTextColor()
}

protocol ArticleCellDataDelegate: class {
    func dataDidChanged(data: ArticleCellData)
}

class ArticleCellData {
    let article: Article
    var displayContent: NSAttributedString?
    var contentHeight: CGFloat?
    weak var delegate: ArticleCellDataDelegate?
    var disposeBag = DisposeBag()
    
    init(article: Article) {
        self.article = article
        self.displayContent = self.getDisplayContent()
    }
    
    func getDisplayContent() -> NSAttributedString? {
        guard let content = article.content else { return nil }
        let parser = BYRUBBParser(font: ArticleConfig.font, color: ArticleConfig.color)
        parser.parse(content)
        let result = NSMutableAttributedString(attributedString: parser.resultAttributedString)
        // 找出所有图片类型的附件
        var attachments = parser.attachments.filter { att in
            if case .Upload(let no) = att.type {
                guard let files = self.article.attachment?.file else { return false }
                guard no > 0 && files.count > 0 && no <= files.count else { return false }
                let file = files[no - 1]
                if file.isImage {
                    att.imageUrl = file.middle ?? file.small ?? file.url
                    return true
                }
                return false
            } else if case .Emotion = att.type {
                return true
            } else if case .Img = att.type {
                return true
            } else {
                return false
            }
        }
        article.attachment?.file?.enumerate().filter { (i, f) in
            return !parser.uploadTagNo.contains(i + 1)
        }.map { (i, f) -> NSAttributedString in
            let attachment = BYRAttachment()
            if f.isImage {
                attachment.tag = Tag(tagName: "img", attributes: ["img": f.middle ?? f.small ?? f.url ?? ""])
            } else {
                attachment.type = .OtherFile
            }
            attachments.append(attachment)
            return NSAttributedString(attachment: attachment)
        }.forEach {
            result.appendAttributedString($0)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            // get images
            attachments.map { (a) -> Observable<([UIImage]?, BYRAttachment)> in
                Observable.create { (observer) -> Disposable in
                    let handler: ImageHelper.Handler = { (images, error) -> () in
                        guard let images = images where images.count > 0 else {
                            observer.onNext((nil, a))
                            observer.onCompleted()
                            return
                        }
                        a.bounds = CGRect(origin: CGPointZero, size: images[0].size)
                        a.images = images
                        observer.onNext((images, a))
                        observer.onCompleted()
                    }
                    if case .Upload = a.type, let url = a.imageUrl {
                        ImageHelper.getImageWithURLString(url, completionHandler: handler)
                    } else if case .Emotion(let name) = a.type {
                        var imagePath: String
                        if name.hasPrefix("emc") {
                            imagePath = "emc" + (name as NSString).substringFromIndex(3)
                        } else if name.hasPrefix("emb") {
                            imagePath = "emb" + (name as NSString).substringFromIndex(3)
                        } else if name.hasPrefix("ema") {
                            imagePath = "ema" + (name as NSString).substringFromIndex(3)
                        } else {
                            imagePath = "em" + (name as NSString).substringFromIndex(2)
                        }
                        if let path = NSBundle.mainBundle().pathForResource(imagePath, ofType: "gif"), data = NSData(contentsOfFile: path) {
                            let images = try? Utils.getImagesFromData(data)
                            handler(images, nil)
                        }
                    } else if case .Img(let url) = a.type {
                        ImageHelper.getImageWithURLString(url, completionHandler: handler)
                    } else {
                        observer.onNext((nil, a))
                        observer.onCompleted()
                    }
                    return AnonymousDisposable {}
                }
            }.zip { (x) -> [([UIImage]?, BYRAttachment)] in
                return x
            }.subscribeNext { (res) -> Void in
                guard res.count > 0 else { return }
                for r in res {
                    if let images = r.0 where images.count > 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.dataDidChanged(self)
                        })
                        return
                    }
                }
            }.addDisposableTo(self.disposeBag)
        }
        return result
    }
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    var views = [String: UIView]()
    var articleData: ArticleCellData?
    
    class func calculateHeight(article: ArticleCellData, boundingWidth width: CGFloat) -> CGFloat {
        guard article.contentHeight == nil else { return article.contentHeight! }
        guard let content = article.displayContent else { return 0 }
        let rect = content.boundingRectWithSize(CGSize(width: width - 24, height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        article.contentHeight = ceil(rect.size.height) + 9
        return article.contentHeight!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.attributedText = nil
        label.textContainerInset = UIEdgeInsetsZero
        label.textContainer.lineFragmentPadding = 0
        label.scrollsToTop = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        views.forEach { $0.1.removeFromSuperview() }
        views = [:]
        label.attributedText = nil
        articleData = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutManager = label.layoutManager
        if let attriString = layoutManager.textStorage {
            attriString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attriString.length), options: [], usingBlock: { (v, range, _) -> Void in
                guard let attachment = v as? BYRAttachment else { return }
                let glyphRange = layoutManager.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
                let size = layoutManager.attachmentSizeForGlyphAtIndex(glyphRange.location)
                let lineFrag = layoutManager.lineFragmentRectForGlyphAtIndex(glyphRange.location, effectiveRange: nil)
                let location = layoutManager.locationForGlyphAtIndex(glyphRange.location)
                var rect = CGRectZero
                rect.origin.x = lineFrag.origin.x + location.x
                rect.origin.y = lineFrag.origin.y + location.y - size.height
                rect.size = size
                // TODO
                if let v = self.views["\(unsafeAddressOf(attachment))"] {
                    v.frame = rect
                } else if let images = attachment.images {
                    let v = UIImageView(frame: rect)
                    v.byr_setImages(images)
                    self.views["\(unsafeAddressOf(attachment))"] = v
                    self.label.addSubview(v)
                }
            })
        }
    }
    
    func update(article: ArticleCellData) {
        articleData = article
        label.attributedText = article.displayContent
    }
    
    deinit {
        views.forEach { $0.1.removeFromSuperview() }
        views = [:]
    }
}
