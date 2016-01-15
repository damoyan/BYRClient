//
//  BoardCell.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/15/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit

class BoardCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var attachmentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(article: Article) {
        titleLabel.text = article.title
        if article.isTop == true {
            titleLabel.textColor = AppSharedInfo.sharedInstance.currentTheme.TopArticleTitleColor
        } else {
            titleLabel.textColor = AppSharedInfo.sharedInstance.currentTheme.BoardNaviCellTitleColor
        }
        userLabel.text = article.user?.id
        if true == article.hasAttachment {
            attachmentLabel.hidden = false
        } else {
            attachmentLabel.hidden = true
        }
        if let reply = article.replyCount {
            replyCountLabel.text = "\(reply)💬"
        } else {
            replyCountLabel.text = "0💬"
        }
        timeLabel.text = article.postTime?.friendly()
    }
    
}
