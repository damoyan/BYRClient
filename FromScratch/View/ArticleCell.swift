//
//  ArticleCell.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

struct ArticleConfig {
    static var font = UIFont.systemFontOfSize(defaultArticleFontSize)
    static var color = UIColor.darkTextColor()
}

class ArticleCellData {
    let article: Article
    var displayContent: NSAttributedString?
    var contentHeight: CGFloat?
    
    init(article: Article) {
        self.article = article
        self.displayContent = getDisplayContent()
    }
    
    func getDisplayContent() -> NSAttributedString? {
        guard let content = article.content else { return nil }
        let parser = BYRUBBParser(font: ArticleConfig.font, color: ArticleConfig.color)
        parser.parse(content)
        let result = NSMutableAttributedString(attributedString: parser.resultAttributedString)
        article.attachment?.file?.enumerate().filter { (i, f) in
            return !parser.uploadTagNo.contains(i + 1)
        }.map { (i, f) -> NSAttributedString in
            let attachment = BYRAttachment()
            attachment.image = UIImage(named: "big")
            // TODO: - add attachment info
            return NSAttributedString(attachment: attachment)
        }.forEach {
            result.appendAttributedString($0)
        }
        return result
    }
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    var views = [String: UIView]()
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layout", unsafeAddressOf(self))
        print("views", views)
        let layoutManager = label.layoutManager
        if let attriString = layoutManager.textStorage {
            attriString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attriString.length), options: [], usingBlock: { (v, range, _) -> Void in
                guard let attachment = v as? BYRAttachment where attachment.type == .AnimatedImage else { return }
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
                } else {
                    let v = UIImageView(frame: rect)
                    v.image = attachment.image
                    self.views["\(unsafeAddressOf(attachment))"] = v
                    self.label.addSubview(v)
                }
            })
        }
    }
    
    func update(article: ArticleCellData) {
        label.attributedText = article.displayContent
    }
    
    deinit {
        views.forEach { $0.1.removeFromSuperview() }
        views = [:]
    }
}
