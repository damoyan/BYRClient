//
//  ArticleCell.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

struct ArticleConfig {
    static let font = UIFont.systemFontOfSize(12)
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    
    class func calculateHeight(article: Article, boundingWidth width: CGFloat) -> CGFloat {
        guard let content = article.content else {
            return 0
        }
        let rect = (content as NSString).boundingRectWithSize(CGSize(width: width - 24, height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: ArticleConfig.font], context: nil)
        return ceil(rect.size.height) + 9
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.config()
        label.textContainerInset = UIEdgeInsetsZero
        label.textContainer.lineFragmentPadding = 0
        label.scrollsToTop = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
}

extension UITextView {
    func config() {
        font = ArticleConfig.font
    }
}
