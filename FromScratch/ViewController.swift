//
//  ViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/26/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlComponents = NSURLComponents(string: oauth2URLString)!
        urlComponents.queryItems = [NSURLQueryItem(name: "client_id", value: appKey), NSURLQueryItem(name: "state", value: "\(state)"), NSURLQueryItem(name: "redirect_uri", value: oauthRedirectUri), NSURLQueryItem(name: "response_type", value: oauthResponseType), NSURLQueryItem(name: "appleid", value: appSecret), NSURLQueryItem(name: "bundleid", value: bundleID)]
        webView.loadRequest(NSURLRequest(URL: urlComponents.URL!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL, index = url.absoluteString.rangeOfString("?")?.startIndex where url.absoluteString.substringToIndex(index) == oauthRedirectUri {
            if let res = parseRedirectURL(url)  {
                print(res)
                AppSharedInfo.sharedInstance.userToken = res.token
            } else {
                // TODO: show error
            }
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print(webView.scrollView.contentSize)
    }
    
    
    let image = UIImagePickerController()
    
    @objc @IBAction private func click(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            image.allowsEditing = true
            image.delegate = self
            presentViewController(image, animated: true, completion: nil)
        }
    }
    
    private func parseRedirectURL(url: NSURL) -> (token: String, expires: String, refreshToken: String, state: String)? {
        if let component = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
            var token: String?, expires: String?, refreshToken: String?, state: String?
            if let fragment = component.fragment {
                let res = fragment.componentsSeparatedByString("&").map {
                    $0.componentsSeparatedByString("=")
                }
                for kvp in res {
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

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
