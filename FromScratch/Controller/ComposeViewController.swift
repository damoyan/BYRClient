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

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup(article)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup(article: Article?) {
        if let a = article {
            titleField.text = (a.isSubject == true) ? "Re: " + (a.title ?? "") : a.title
            if let id = a.user?.id, content = article?.content {
                var quote = "\n【在 \(id) 的大作中提到：】\n: "
                let components = content.componentsSeparatedByString("\n").enumerate().filter { $0.index < 3 }.map { $0.element }
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
        if let presenting = self.presentingViewController {
            print("find presenting")
            presenting.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @objc @IBAction private func actionSend(sender: AnyObject) {
        po("action send")
        view.endEditing(true)
        if let presenting = self.presentingViewController {
            print("find presenting")
            presenting.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
