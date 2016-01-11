//
//  BYRImageView.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/8/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit
import RxSwift

class BYRImageView: UIImageView {
    
    private var displayLink: CADisplayLink?
    private var byr_images: [UIImage] = []
    private var currentIndex: Int = 0
    
    override var animationImages: [UIImage]? {
        get {
            return byr_images
        }
        set {
            byr_setImages(newValue)
        }
    }
    
    private func resetStatus() {
        displayLink?.invalidate()
        displayLink = nil
        currentIndex = 0
    }
    
    private func clearContent() {
        resetStatus()
        byr_images = []
    }
    
    /// 这个子类实际上不需要调用这两个方法.
    override func startAnimating() {
        displayLink = CADisplayLink(target: WeakReferenceProxy(target: self), selector: "handle:")
        displayLink?.frameInterval = 2
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    override func stopAnimating() {
        resetStatus()
    }
    
    override func byr_setImages(images: [UIImage]?) {
        clearContent()
        guard let images = images where images.count > 0 else { return }
        if images.count == 1 {
            image = images[0]
        } else {
            byr_images = images
            startAnimating()
        }
    }
    
    @objc private func handle(dl: CADisplayLink) {
        image = byr_images[currentIndex]
        currentIndex = (currentIndex + 1) % byr_images.count
    }
    
    deinit {
        clearContent()
        print("deinit imageview")
    }
}
