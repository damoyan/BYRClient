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
//    
    let byr_subject = PublishSubject<String>()
    var byr_disposeBag = DisposeBag()
    private var player: ImagePlayer?
    
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
    
    
    func byr_setImageDecoder(decoder: ImageDecoder) {
        byr_reset()
        guard decoder.frameCount > 0 else { return }
        if decoder.frameCount == 1 {
            image = decoder.firstFrame
        } else {
            player = ImagePlayer(decoder: decoder) { [weak self] image in
                self?.image = image
            }
        }
    }
    
    private func setup() {
        byr_subject
            .map { urlString -> Observable<(ImageDecoder?, NSError?)> in
                return Observable.create { observer in
                    ImageHelper.getImageWithURLString(urlString, completionHandler: { (urlString, decoder, error) -> () in
                        observer.onNext((decoder, error))
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
                guard let decoder = res.0 else { return }
                self?.byr_setImageDecoder(decoder)
            }
            .addDisposableTo(byr_disposeBag)
    }
    
    func byr_setImageWithURLString(urlString: String) {
        byr_subject.onNext(urlString)
    }
    
    func byr_reset() {
        player?.stop()
        player = nil
        image = nil
    }
    
    deinit {
        byr_reset()
        print("deinit BYRImageView")
    }
}
