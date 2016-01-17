//
//  APIManager.swift
//  FromScratch
//
//  Created by Yu Pengyang on 10/26/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// Known BYR Errors
//let needParameter = (code: "1701", msg: "请求参数错误或丢失")
// code: 1702, msg: "非法的 oauth_token"

let BYRErrorDomain = "BYRErrorDomain"
let ErrorInvalidToken = 1702 //msg: "非法的 oauth_token"
let ErrorTokenExpired = 1703

enum API: URLRequestConvertible {
    
    case Sections
    case Section(name: String)
    case Favorite(level: Int)
    
    case Board(name: String, mode: BoardMode?, perPage: Int?, page: Int?)
    
    case TopTen
    
    case Thread(name: String, id: Int, uid: String?, perPage: Int?, page: Int?)
    
    case Compose(name: String, title: String, content: String, replyID: Int?)
    
    var URLRequest: NSMutableURLRequest {
        var v = generateURLComponents()
        if v.params == nil {
            v.params = [String: AnyObject]()
        }
        v.params!["oauth_token"] = "\(AppSharedInfo.sharedInstance.userToken!)"
        let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent(v.path))
        request.HTTPMethod = v.method.rawValue
        return Alamofire.ParameterEncoding.URL.encode(request, parameters: v.params!).0
    }
    
    func handleResponse(callback: (NSURLRequest?, NSHTTPURLResponse?, JSON?, NSError?) -> ()) -> Request {
        return request(URLRequest).responseJSON { (res) -> Void in
            guard let json = res.result.value else {
                callback(res.request, res.response, nil, res.result.error)
                return
            }
            let sj = JSON(json)
            
            // if the request is Successful, there will be no 'code' & 'msg' key in returned JSON.
            // when we access 'code' or 'msg' key, there should be an error,
            // so sj["code"].error & sj["msg"].error are not `nil`
            guard sj["code"].error != nil && sj["msg"].error != nil else {
                if sj["code"].intValue == ErrorInvalidToken || sj["code"].intValue == ErrorTokenExpired {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.InvalidToken, object: nil)
                } else {
                    callback(res.request, res.response, nil, NSError(domain: BYRErrorDomain, code: sj["code"].intValue, userInfo: [NSLocalizedDescriptionKey: sj["msg"].stringValue]))
                }
                return
            }
            callback(res.request, res.response, sj, nil)
        }
    }
    
    private func generateURLComponents() -> (method: Alamofire.Method, path: String, params: [String: AnyObject]?) {
        switch self {
        case Sections:
            return (.GET, "/section.json", nil)
        case Section(let name):
            return (.GET, "/section/\(name).json", nil)
        case .Favorite(let level):
            return (.GET, "/favorite/\(level).json", nil)
        case .TopTen:
            return (.GET, "/widget/topten.json", nil)
        case .Board(let name, let mode, let perPage, let page):
            return (.GET, "/board/\(name).json", API.filterParams(["mode": mode?.rawValue, "count": perPage, "page": page]))
        case .Thread(let name, let id, let uid, let perPage, let page):
            return (.GET, "/threads/\(name)/\(id).json", API.filterParams(["au": uid, "count": perPage, "page": page]))
        case .Compose(let name, let title, let content, let replyID):
            return (.POST, "/article/\(name)/post.json", API.filterParams(["content": content, "title": title, "reid": replyID]))
        }
    }
    
    static func filterParams(input: [String: AnyObject?]) -> [String: AnyObject] {
        return input.flatMap { $0.1 == nil ? nil : ($0.0, $0.1!)}.reduce([String: AnyObject]()) {
            var ret = $0
            ret[$1.0] = $1.1
            return ret
        }
    }
}