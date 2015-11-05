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

enum Router: URLRequestConvertible {
    case Sections
    var URLRequest: NSMutableURLRequest {
        var v: (method: Alamofire.Method, path: String, params: [String: AnyObject]?) = {
            switch self {
            case Sections:
                return (.GET, "/section", nil)
            }
        }()
        if v.params == nil {
            v.params = [String: AnyObject]()
        }
        v.params!["oauth_token"] = AppSharedInfo.sharedInstance.userToken
        let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent("/section.json"))
        request.HTTPMethod = Alamofire.Method.GET.rawValue
        return Alamofire.ParameterEncoding.URL.encode(request, parameters: v.params!).0
    }
}

typealias RequestCallback = (Response<AnyObject, NSError>) -> ()

class API {
    class func sections(callback: RequestCallback) -> Request {
        return request(.GET, baseURLString + "/section.json").response { (request, Response, data, error) in
            
        }
    }
}