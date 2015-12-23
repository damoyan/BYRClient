//
//  ArticleHeader.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class ArticleHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func onReply(sender: UIButton) {
        print("reply")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        avatar.image = nil
        idLabel.text = nil
        nameLabel.text = nil
    }
    
    func update(article: Article) {
//        avatar.image = UIImage(named: article.user?.faceURL ?? "AppIcon")
        idLabel.text = article.user?.id
        nameLabel.text = article.user?.userName
    }
}