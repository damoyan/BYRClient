//
//  ArticleHeader.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class ArticleHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var avatar: BYRImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func onReply(sender: UIButton) {
        print("reply")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.byr_reset()
        idLabel.text = nil
        nameLabel.text = nil
    }
    
    func update(article: ArticleCellData) {
        if let url = article.article.user?.faceURL {
            avatar.byr_setImageWithURLString(url)
        } else {
            avatar.image = UIImage(named: "default_avatar")
        }
        idLabel.text = article.article.user?.id
        nameLabel.text = article.article.user?.userName
    }
    
    deinit {
        avatar.stopAnimating()
        avatar.animationImages = nil
        avatar.image = nil
        print("deinit header")
    }
}
