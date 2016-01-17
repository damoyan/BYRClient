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
    @IBOutlet weak var positionLabel: UILabel!
    
    var articleData: ArticleCellData?
    weak var threadVC: ThreadViewController?
    
    @IBAction func onReply(sender: UIButton) {
//        po("reply")
        threadVC?.presentCompose(articleData?.article) { [weak vc = threadVC] isCancel, article, error in
            guard let vc = vc else { return }
            vc.dismissViewControllerAnimated(true, completion: nil)
            if let _ = article {
                vc.loadData()
            } else {
                po("no data return")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.byr_reset()
        idLabel.text = nil
        nameLabel.text = nil
    }
    
    func update(article: ArticleCellData) {
        articleData = article
        if let url = article.article.user?.faceURL {
            avatar.byr_setImageWithURLString(url)
        } else {
            avatar.image = UIImage(named: "default_avatar")
        }
        idLabel.text = article.article.user?.id
        nameLabel.text = article.article.user?.userName
        if let position = article.article.position {
            positionLabel.text = {
                switch position {
                case 0:
                    return "楼主"
                case 1:
                    return "沙发"
                case 2:
                    return "板凳"
                default:
                    return "\(position)楼"
                }
            }()
        } else {
            positionLabel.text = nil
        }
    }
    
    deinit {
        avatar.stopAnimating()
        avatar.animationImages = nil
        avatar.image = nil
//        po("deinit header")
    }
}
