//
//  NewArticleViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/16/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    var article: Article?
    var boardName: String?
    var callback: ((Bool, Article?, NSError?) -> Void)?

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup(article)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notifyKeyboardShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notifyKeyboardHide:", name: UIKeyboardDidHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup(article: Article?) {
        if let a = article {
            titleField.text = /*(a.isSubject == true) ? "Re: " + (a.title ?? "") : */a.title
            if let id = a.user?.id, content = article?.content {
                var quote = "\n【在 \(id) 的大作中提到：】\n: "
                let components = content.componentsSeparatedByString("\n").enumerate().filter { $0.index < 3 && $0.element.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).utf16.count > 0 }.map { $0.element }
                quote.appendContentsOf(components.joinWithSeparator("\n: "))
                contentTextView.text = quote
            }
            contentTextView.becomeFirstResponder()
            contentTextView.selectedRange = NSMakeRange(0, 0)
        } else {
            titleField.text = nil
            contentTextView.text = nil
            titleField.becomeFirstResponder()
        }
    }
    
    @objc @IBAction private func actionCancel(sender: AnyObject) {
        po("action cancel")
        view.endEditing(true)
        callback?(true, nil, nil)
    }
    
    @objc @IBAction private func actionSend(sender: AnyObject) {
        po("action send")
        view.endEditing(true)
        if let name = article?.boardName ?? boardName, title = titleField.text, content = contentTextView.text {
            API.Compose(name: name, title: title, content: content, replyID: article?.groupID ?? article?.replyID ?? article?.id).handleResponse({ [weak self] (_, _, d, error) -> () in
                guard let this = self else { return }
                guard let data = d else {
                    print(error)
                    // TODO: - handle error
                    return
                }
                let a = Article(data: data)
                // TODO: notify parent about a
                this.callback?(false, a, nil)
            })
        }
        
    }
    
    @objc private func notifyKeyboardShow(notifi: NSNotification) {
        
    }
    
    @objc private func notifyKeyboardHide(notifi: NSNotification) {
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
