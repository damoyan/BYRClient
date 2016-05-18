//
//  ViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/26/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import UIKit

// Login OAuth
class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AppSharedInfo.sharedInstance.userToken == nil {
            // userToken 不存在有两种情况:
            // 1. 用户没登录或已注销
            // 2. 用户token在本地判断过期
            if AppSharedInfo.sharedInstance.isRenewing {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userChanged), name: Notifications.UserRenewal, object: nil)
            } else {
                let urlComponents = NSURLComponents(string: oauth2URLString)!
                urlComponents.queryItems = [NSURLQueryItem(name: "client_id", value: appKey), NSURLQueryItem(name: "state", value: "\(state)"), NSURLQueryItem(name: "redirect_uri", value: oauthRedirectUri), NSURLQueryItem(name: "response_type", value: oauthResponseType), NSURLQueryItem(name: "appleid", value: appSecret), NSURLQueryItem(name: "bundleid", value: bundleID)]
                webView.loadRequest(NSURLRequest(URL: urlComponents.URL!))
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 1. present vc in viewWillAppear: will lead to warning: Presenting view controllers on detached view controllers is discourage
        // 2. when you try and display a new viewcontroller before the current view controller is finished displaying(such as viewWillAppear), you will got the Warning: "The unbalanced calls to begin/end appearance transitions"
        if AppSharedInfo.sharedInstance.userToken != nil {
            presentHome()
        }
    }
    
    deinit {
        
    }
    
    private func presentHome() {
        let tab = Utils.main.instantiateViewControllerWithIdentifier("vcTabHome")
        navigationController?.presentViewController(tab, animated: true, completion: nil)
    }
    
    @objc private func userChanged() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
// MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL, index = url.absoluteString.rangeOfString("?")?.startIndex where url.absoluteString.substringToIndex(index) == oauthRedirectUri {
            if let res = parseRedirectURL(url) where res.state == state  {
                po("授权成功", res)
                AppSharedInfo.sharedInstance.userToken = res.token
                AppSharedInfo.sharedInstance.expires = res.expires
                AppSharedInfo.sharedInstance.refreshToken = res.refreshToken
                presentHome()
                return false
            } else {
                po("授权失败")
            }
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        moveToCenter(webView.scrollView.contentSize)
    }
    
    private func moveToCenter(contentSize: CGSize) {
        let width = webView.frame.width
        if contentSize.width > width {
            let offsetX = (contentSize.width - width) / 2.0
            webView.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
        }
    }
    
    private func parseRedirectURL(url: NSURL) -> (token: String, expires: String, refreshToken: String, state: String)? {
        if let component = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
            var token: String?, expires: String?, refreshToken: String?, state: String?
            if let fragment = component.fragment {
                let res = fragment.componentsSeparatedByString("&").map {
                    $0.componentsSeparatedByString("=")
                }
                res.forEach { kvp in
                    if kvp.count == 2 {
                        switch kvp[0] {
                        case "access_token":
                            token = kvp[1]
                        case "expires_in":
                            expires = kvp[1]
                        case "refresh_token":
                            refreshToken = kvp[1]
                        default:
                            break
                        }
                    }
                }
            }
            if let queryItems = component.queryItems {
                for item in queryItems {
                    if item.name  == "state" {
                        state = item.value
                        break
                    }
                }
            }
            if let token = token, expires = expires, refreshToken = refreshToken, state = state {
                return (token, expires, refreshToken, state)
            }
        }
        return nil
    }
}
