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

enum API: URLRequestConvertible {
    
    case Sections
    
    var URLRequest: NSMutableURLRequest {
        var v = generateURLComponents()
        if v.params == nil {
            v.params = [String: AnyObject]()
        }
        v.params!["oauth_token"] = "s\(AppSharedInfo.sharedInstance.userToken)"
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
                callback(res.request, res.response, nil, NSError(domain: BYRErrorDomain, code: sj["code"].intValue, userInfo: [NSLocalizedDescriptionKey: sj["msg"].stringValue]))
                return
            }
            callback(res.request, res.response, sj, nil)
        }
    }
    
    private func generateURLComponents() -> (method: Alamofire.Method, path: String, params: [String: AnyObject]?) {
        switch self {
        case Sections:
            return (.GET, "/section.json", nil)
        }
    }
}