//
//  ArticleCell.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

struct ArticleConfig {
    var font = UIFont.systemFontOfSize(defaultArticleFontSize)
    var color = UIColor.darkTextColor()
}

class ArticleCellData {
    let article: Article
    let displayContent: NSAttributedString?
    var contentHeight: CGFloat?
    
    init(article: Article) {
        self.article = article
        self.displayContent = ArticleCellData.getDisplayContent(article.content)
    }
    
    static func getDisplayContent(content: String?) -> NSAttributedString? {
        guard let content = content else { return nil }
        let parser = BYRUBBParser(font: ArticleCell.articleConfig.font, color: ArticleCell.articleConfig.color)
        parser.parse(content)
        return parser.result
    }
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    
    static var articleConfig = { ArticleConfig() }()
    
    class func calculateHeight(article: ArticleCellData, boundingWidth width: CGFloat) -> CGFloat {
        guard article.contentHeight == nil else { return article.contentHeight! }
        guard let content = article.displayContent else { return 0 }
        let rect = content.boundingRectWithSize(CGSize(width: width - 24, height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        article.contentHeight = ceil(rect.size.height) + 9
        return article.contentHeight!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.textContainerInset = UIEdgeInsetsZero
        label.textContainer.lineFragmentPadding = 0
        label.scrollsToTop = false
        label.layoutManager.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    deinit {
        label.layoutManager.delegate = nil
    }
    
    func update(article: ArticleCellData) {
        label.attributedText = article.displayContent
    }
}

extension ArticleCell: NSLayoutManagerDelegate {
    
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if let attriString = layoutManager.textStorage {
            attriString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attriString.length), options: [], usingBlock: { (v, range, _) -> Void in
                
            })
        }
    }
}

extension UITextView {
    func config(config: ArticleConfig) {
        font = config.font
    }
}
