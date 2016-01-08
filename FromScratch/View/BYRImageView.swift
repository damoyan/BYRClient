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
    let subject = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
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
            .subscribeNext { res in
                guard let images = res.0 else { return }
                self.byr_setImages(images)
            }
            .addDisposableTo(disposeBag)
        
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
        subject.onNext(urlString)
    }
}
