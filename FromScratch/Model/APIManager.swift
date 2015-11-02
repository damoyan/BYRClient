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

enum RequestGenerator: URLRequestConvertible {
    case Default
    var URLRequest: NSMutableURLRequest {
        var params = [String: AnyObject]()
        params["oauth_token"] = AppSharedInfo.sharedInstance.userToken
        let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent("/section.json"))
        request.HTTPMethod = Alamofire.Method.GET.rawValue
        return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
    }
}