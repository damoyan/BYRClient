//
//  ImageInfo.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/11/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit

class ImagePlayer {
    private var currentIndex = 0
    private let decoder: ImageDecoder
    private var link = CADisplayLink()
    private var curImage: UIImage?
    private var buffer = [Int: UIImage]()
    private var block: ((UIImage?) -> ())?
    private var time: NSTimeInterval = 0
    private var miss = false
    private var queue = NSOperationQueue()
    private var lock = OS_SPINLOCK_INIT
    
    init(decoder: ImageDecoder, block: (UIImage?) -> ()) {
        self.decoder = decoder
        self.block = block
        self.link = CADisplayLink(target: WeakReferenceProxy(target: self), selector: "step:")
        link.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        if let image = decoder.firstFrame {
            block(image)
        }
    }
    
    @objc private func step(link: CADisplayLink) {
        let nextIndex = (currentIndex + 1) % decoder.frameCount
        
        if !miss {
            time += link.duration
            var delay = decoder.imageDurationAtIndex(currentIndex)
            if time < delay { return }
            time -= delay
            delay = decoder.imageDurationAtIndex(nextIndex)
            if time > delay { time = delay }
        }
        
        OSSpinLockLock(&lock)
        let image = buffer[nextIndex]
        OSSpinLockUnlock(&lock)
        
        if let image = image {
            curImage = image
            currentIndex = nextIndex
            miss = false
        } else {
            miss = true
        }
        
        if !miss {
            block?(image)
        }
        
        if queue.operationCount > 0 { return }
        queue.addOperationWithBlock { [weak self] () -> Void in
            guard let this = self else { return }
            for i in 0...(nextIndex + 1) {
                OSSpinLockLock(&this.lock)
                let cached = this.buffer[i]
                OSSpinLockUnlock(&this.lock)
                if cached != nil { continue }
                if let image = this.decoder.imageAtIndex(i) {
                    OSSpinLockLock(&this.lock)
                    this.buffer[i] = image
                    OSSpinLockUnlock(&this.lock)
                }
            }
        }
    }
    
    func stop() {
//        po("stop")
        block = nil
        link.invalidate()
    }
    
    deinit {
        link.invalidate()
//        po("deinit ImagePlayer")
    }
}