//
//  UserProfileViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/25/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: BYRImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var astroLabel: UILabel!
    @IBOutlet weak var qqLabel: UILabel!
    @IBOutlet weak var msnLabel: UILabel!
    @IBOutlet weak var mainPageLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var lastLoginTimeLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!
    
    var userId: String! // must not be nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetContent()
        loadData()
    }
    
    private func resetContent() {
        avatarImageView.image = UIImage(named: "default_avatar")
        idLabel.text = nil
        nickLabel.text = nil
        genderLabel.text = nil
        astroLabel.text = nil
        qqLabel.text = nil
        msnLabel.text = nil
        mainPageLabel.text = nil
        levelLabel.text = nil
        postCountLabel.text = nil
        scoreLabel.text = nil
        lifeLabel.text = nil
        lastLoginTimeLabel.text = nil
        currentStatusLabel.text = nil
    }
    
    var isLoading = false
    private func loadData() {
        guard !isLoading else { return }
        isLoading = true
        scrollView.hidden = true
        indicator.startAnimating()
        API.UserInfo(id: userId).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let this = self else { return }
            guard let data = d else {
                po(e)
                this.indicator.stopAnimating()
                return
            }
            let user = User(data: data)
            this.display(user)
            this.indicator.stopAnimating()
            this.scrollView.hidden = false
        }
    }
    
    private func display(user: User) {
        if let url = user.faceURL {
            avatarImageView.byr_setImageWithURLString(url)
        }
        idLabel.text = user.id
        nickLabel.text = user.userName
        genderLabel.text = user.gender == "m" ? "男生" : "女生"
        astroLabel.text = user.astro
        qqLabel.text = user.qq
        msnLabel.text = user.msn
        mainPageLabel.text = user.homePage
        levelLabel.text = user.role ?? user.level
        postCountLabel.text = "\(user.postCount ?? 0)"
        scoreLabel.text = "\(user.score ?? 0)"
        lifeLabel.text = "\(user.life ?? 365)"
        if let date = user.lastLoginTime {
            lastLoginTimeLabel.text = Utils.mediumStyleDateFormatter.stringFromDate(date)
        }
        currentStatusLabel.text = user.isOnline == true ? "在线" : "离线"
    }
    
    deinit {
        po("deinit userprofile vc")
    }
}
