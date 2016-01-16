//
//  WeakProxy.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/11/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import Foundation

// just used as `CADisplayLink` target
class WeakReferenceProxy: NSObject {
    weak var target: AnyObject?
    
    init(target: AnyObject) {
        self.target = target
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return self.target
    }
    
    deinit {
        po("deinit WeakProxy")
    }
}