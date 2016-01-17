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
    var hasAttachment = false
    weak var delegate: ArticleCellDataDelegate?
    
    init(article: Article) {
        self.article = article
        self.displayContent = self.getDisplayContent()
    }
    
    func getDisplayContent() -> NSAttributedString? {
        guard let content = article.content else { return nil }
        let parser = Parser(uploadCount: article.attachment?.file?.count ?? 0)
        let result = NSMutableAttributedString(attributedString: parser.parse(content))
        // 找出所有图片类型的附件
        var attachments = parser.attachments.filter { att in
            if case .Upload(let no) = att.type {
                guard let files = self.article.attachment?.file else { return false }
                guard no > 0 && files.count > 0 && no <= files.count else { return false }
                let file = files[no - 1]
                if file.isImage {
                    if file.isGif {
                        att.imageUrl = file.url ?? file.middle ?? file.small
                    } else {
                        att.imageUrl = file.middle ?? file.url ?? file.small
                    }
                    return true
                }
//                po("not image")
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
            return (!parser.uploadTagNo.contains(i + 1)) && f.isImage // TODO: - 只处理image类型
        }.map { (i, f) -> NSAttributedString in
            let attachment = BYRAttachment()
            attachment.type = .Img(f.middle ?? f.small ?? f.url ?? "")
            attachments.append(attachment)
            return NSAttributedString(attachment: attachment)
        }.forEach {
            result.appendAttributedString($0)
        }
        hasAttachment = attachments.count > 0 ? true : false
        if !hasAttachment { return result }

        // get images
        attachments.forEach { a in
            loadAttachmentImage(a, articleData: self)
        }
        return result
    }
    
    deinit {
//        po("deinit cell data", article.position)
    }
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    var views = [String: UIView]()
    weak var articleData: ArticleCellData?
    
    class func calculateHeight(article: ArticleCellData, boundingWidth width: CGFloat) -> CGFloat {
        
        guard article.contentHeight == nil else { return article.contentHeight! }
        guard let content = article.displayContent else { return 0 }
        // 不用boundingRect的原因是, 这个方法会导致string里的attachment不会被释放, 具体原因未知
//        let rect = content.boundingRectWithSize(CGSize(width: width - 24, height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let height = getHeight(content, boundingWidth: width - 24)
        article.contentHeight = height + 9
//        article.contentHeight = ceil(rect.height) + 9
        return article.contentHeight!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.attributedText = nil
        label.textContainerInset = UIEdgeInsetsZero
        label.textContainer.lineFragmentPadding = 0
        label.scrollsToTop = false
        label.layoutManager.delegate = self
        label.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanViews()
        label.attributedText = nil
        articleData = nil
    }
    
    func update(article: ArticleCellData) {
        articleData = article
        label.attributedText = article.displayContent
    }
    
    private func cleanViews() {
        views.forEach {
            if let view = $0.1 as? UIImageView {
                view.stopAnimating()
                view.animationImages = nil
                view.image = nil
            }
            $0.1.removeFromSuperview()
        }
        views.removeAll()
    }
    
    deinit {
        label.layoutManager.delegate = nil
        label.attributedText = nil
        cleanViews()
//        po("cell deinit")
    }
}

extension ArticleCell: UITextViewDelegate {
    // fix crash for iOS9 issue: https://forums.developer.apple.com/thread/19480
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        if let a = textAttachment as? BYRAttachment, articleData = self.articleData where a.loadingFail {
            loadAttachmentImage(a, articleData: articleData)
        }
        return false
    }
}

extension ArticleCell: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        guard let d = articleData where d.hasAttachment else { return }
        if let attriString = layoutManager.textStorage {
            attriString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attriString.length), options: [], usingBlock: { (v, range, _) -> Void in
                // 只处理指定类型的attachment
                guard let attachment = v as? BYRAttachment else { return }
                // attachment的image不为空或者images数量不够的时候, 直接展示image, 不添加imageView
                guard let decoder = attachment.decoder where decoder.frameCount > 1 else {
                    if let v = self.views["\(unsafeAddressOf(attachment))"] {
                        v.removeFromSuperview()
                        self.views.removeValueForKey("\(unsafeAddressOf(attachment))")
                    }
                    return
                }
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
                } else if let decoder = attachment.decoder {
                    let v = BYRImageView(frame: rect)
                    v.byr_setImageDecoder(decoder)
                    self.views["\(unsafeAddressOf(attachment))"] = v
                    self.label.addSubview(v)
                }
            })
        }
    }
}

func loadAttachmentImage(a: BYRAttachment, articleData: ArticleCellData) {
    let handler: ImageHelper.Handler = { [weak data = articleData, weak a = a] (urlString, info, error) -> () in
        guard let this = data else { return }
        this.contentHeight = nil
        a?.decoder = info
        this.delegate?.dataDidChanged(this)
    }
    if case .Upload = a.type, let url = a.imageUrl {
        ImageHelper.getImageWithURLString(url, completionHandler: handler)
    } else if case .Emotion(let name) = a.type {
        if let data = Utils.getEmotionData(name) {
            ImageHelper.getImageWithData(data, completionHandler: handler)
        } else {
            handler(nil, nil, nil)
        }
    } else if case .Img(let url) = a.type {
        ImageHelper.getImageWithURLString(url, completionHandler: handler)
    }
}

func getHeight(attriString: NSAttributedString, boundingWidth width: CGFloat) -> CGFloat {
    let textStorage: NSTextStorage = NSTextStorage(attributedString: attriString)
    let layoutManager: NSLayoutManager = NSLayoutManager()
    let textContainer: NSTextContainer = NSTextContainer(size: CGSize(width: width, height: CGFloat.max))
    textContainer.lineFragmentPadding = 0
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    layoutManager.ensureLayoutForTextContainer(textContainer)
    let rect = layoutManager.usedRectForTextContainer(textContainer)
    return ceil(rect.height)
}