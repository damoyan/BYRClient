//
//  UIImageViewExtension.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/8/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit
import RxSwift

private struct _Keys {
    static let subjectKey = "UIImageView.associateObject.subject"
    static let disposeBagKey = "UIImageView.associateObject.disposeBag"
}

extension UIImageView {
    
    var byr_subject: PublishSubject<String> {
        if let subject = objc_getAssociatedObject(self, _Keys.subjectKey) as? PublishSubject<String> {
            return subject
        } else {
            return byr_createSubject()
        }
    }
    
    var byr_disposeBag: DisposeBag {
        if let dispose = objc_getAssociatedObject(self, _Keys.disposeBagKey) as? DisposeBag {
            return dispose
        } else {
            return byr_createDisposeBag()
        }
    }
    
    private func byr_createDisposeBag() -> DisposeBag {
        let disposeBag = DisposeBag()
        objc_setAssociatedObject(self, _Keys.disposeBagKey, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return disposeBag
    }
    
    private func byr_createSubject() -> PublishSubject<String> {
        let subject = PublishSubject<String>()
        subject
            .map { urlString -> Observable<([UIImage]?, NSError?)> in
                return Observable.create { observer in
                    ImageHelper.getImageWithURLString(urlString, completionHandler: { (images, error) -> () in
                        observer.onNext((images, error))
                        observer.onCompleted()
                    })
                    return AnonymousDisposable {
                        print("dispose")
                    }
                }
            }
            .switchLatest()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] res in
                guard let images = res.0 else { return }
                self?.byr_setImages(images)
            }
            .addDisposableTo(byr_disposeBag)
        objc_setAssociatedObject(self, _Keys.subjectKey, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return subject
    }
    
    func byr_setImages(images: [UIImage]) {
        guard images.count > 0 else { return }
        if images.count > 1 {
            self.animationImages = images
            self.startAnimating()
        } else {
            self.image = images[0]
        }
    }
    
    func byr_setImageWithURLString(urlString: String) {
        byr_subject.onNext(urlString)
        byr_subject.onCompleted()
    }
}
