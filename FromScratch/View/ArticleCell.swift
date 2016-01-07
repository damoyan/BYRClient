//
//  ArticleCell.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import RxSwift

struct ArticleConfig {
    static var font = UIFont.systemFontOfSize(defaultArticleFontSize)
    static var color = UIColor.darkTextColor()
}

protocol ArticleCellDataDelegate: class {
    func dataDidChanged(data: ArticleCellData)
}

class ArticleCellData {
    let article: Article
    var displayContent: NSAttributedString?
    var contentHeight: CGFloat?
    weak var delegate: ArticleCellDataDelegate?
    var disposeBag = DisposeBag()
    
    init(article: Article) {
        self.article = article
        self.displayContent = self.getDisplayContent()
    }
    
    func getDisplayContent() -> NSAttributedString? {
        guard let content = article.content else { return nil }
        let parser = BYRUBBParser(font: ArticleConfig.font, color: ArticleConfig.color)
        parser.parse(content)
        let result = NSMutableAttributedString(attributedString: parser.resultAttributedString)
        // 找出所有图片类型的附件
        var attachments = parser.attachments.filter { att in
            if case .Upload(let no) = att.type {
                guard let files = self.article.attachment?.file else { return false }
                guard no > 0 && files.count > 0 && no <= files.count else { return false }
                let file = files[no - 1]
                if file.isImage {
                    att.imageUrl = file.url ?? file.middle ?? file.small
                    return true
                }
                return false
            } else if case .Emotion = att.type {
                return true
            } else if case .Img = att.type {
                return true
            } else {
                return false
            }
        }
        article.attachment?.file?.enumerate().filter { (i, f) in
            return !parser.uploadTagNo.contains(i + 1)
        }.map { (i, f) -> NSAttributedString in
            let attachment = BYRAttachment()
            if f.isImage {
                attachment.tag = Tag(tagName: "img", attributes: ["img": f.url ?? f.middle ?? f.small ?? ""])
            } else {
                attachment.type = .OtherFile
            }
            attachments.append(attachment)
            return NSAttributedString(attachment: attachment)
        }.forEach {
            result.appendAttributedString($0)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] () -> Void in
            // get images
            attachments.map { (a) -> Observable<([UIImage]?, BYRAttachment)> in
                Observable.create { (observer) -> Disposable in
                    let handler: ImageHelper.Handler = { (images, error) -> () in
                        guard let images = images where images.count > 0 else {
                            observer.onNext((nil, a))
                            observer.onCompleted()
                            return
                        }
                        a.bounds = CGRect(origin: CGPointZero, size: images[0].size)
                        a.images = images
                        observer.onNext((images, a))
                        observer.onCompleted()
                    }
                    if case .Upload = a.type, let url = a.imageUrl {
                        ImageHelper.getImageWithURLString(url, completionHandler: handler)
                    } else if case .Emotion(let name) = a.type {
                        var imageName: String, imageFolder: String
                        let folderPrefix = "emotions/"
                        if name.hasPrefix("emc") {
                            imageFolder = folderPrefix + "emc"
                            imageName = (name as NSString).substringFromIndex(3)
                        } else if name.hasPrefix("emb") {
                            imageFolder = folderPrefix + "emb"
                            imageName = (name as NSString).substringFromIndex(3)
                        } else if name.hasPrefix("ema") {
                            imageFolder = folderPrefix + "ema"
                            imageName = (name as NSString).substringFromIndex(3)
                        } else {
                            imageFolder = folderPrefix + "em"
                            imageName = (name as NSString).substringFromIndex(2)
                        }
                        let path = NSBundle.mainBundle().pathForResource(imageName, ofType: "gif", inDirectory: imageFolder)
                        print(imageName, imageFolder, "emotion path: ", path)
                        if let path = path, data = NSData(contentsOfFile: path) {
                            let images = try? Utils.getImagesFromData(data)
                            handler(images, nil)
                        } else {
                            handler(nil, nil)
                        }
                    } else if case .Img(let url) = a.type {
                        ImageHelper.getImageWithURLString(url, completionHandler: handler)
                    } else {
                        observer.onNext((nil, a))
                        observer.onCompleted()
                    }
                    return AnonymousDisposable {
                        print("disposable")
                    }
                }
            }.zip { (x) -> [([UIImage]?, BYRAttachment)] in
                return x
            }.subscribeOn(MainScheduler.instance)
            .subscribeNext { (res) -> Void in
                guard res.count > 0 else { return }
                for r in res {
                    if let images = r.0 where images.count > 0 {
                        self.delegate?.dataDidChanged(self)
                        return
                    }
                }
            }.addDisposableTo(self.disposeBag)
        }
        return result
    }
    
    deinit {
        print("deinit cell data")
    }
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var label: UITextView!
    var views = [String: UIView]()
    weak var articleData: ArticleCellData?
    
    class func calculateHeight(article: ArticleCellData, boundingWidth width: CGFloat) -> CGFloat {
        
        guard article.contentHeight == nil else { return article.contentHeight! }
        guard let content = article.displayContent else { return 0 }
        // 不用boundingRect的原因是, 这个方法会导致string里的attachment不会被释放, 具体原因未知
//        let rect = content.boundingRectWithSize(CGSize(width: width - 24, height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let height = getHeight(content, boundingWidth: width - 24)
        article.contentHeight = height + 9
//        article.contentHeight = ceil(rect.height) + 9
        return article.contentHeight!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.attributedText = nil
        label.textContainerInset = UIEdgeInsetsZero
        label.textContainer.lineFragmentPadding = 0
        label.scrollsToTop = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanViews()
        label.attributedText = nil
        articleData = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutManager = label.layoutManager
        if let attriString = layoutManager.textStorage {
            attriString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, attriString.length), options: [], usingBlock: { (v, range, _) -> Void in
                print("v: ", v)
                // 只处理指定类型的attachment
                guard let attachment = v as? BYRAttachment else { return }
                // attachment的image不为空或者images数量不够的时候, 直接展示image, 不添加imageView
                guard let images = attachment.images where attachment.image == nil && images.count > 1 else {
                    if let v = self.views["\(unsafeAddressOf(attachment))"] {
                        v.removeFromSuperview()
                        self.views.removeValueForKey("\(unsafeAddressOf(attachment))")
                    }
                    return
                }
                print("attachment", attachment)
                print("imageurl:", attachment.imageUrl)
                print("images: ", attachment.images)
                print("type: ", attachment.type)
                print("=======================================================================================")
                let glyphRange = layoutManager.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
                let size = layoutManager.attachmentSizeForGlyphAtIndex(glyphRange.location)
                let lineFrag = layoutManager.lineFragmentRectForGlyphAtIndex(glyphRange.location, effectiveRange: nil)
                let location = layoutManager.locationForGlyphAtIndex(glyphRange.location)
                var rect = CGRectZero
                rect.origin.x = lineFrag.origin.x + location.x
                rect.origin.y = lineFrag.origin.y + location.y - size.height
                rect.size = size
                // TODO
                if let v = self.views["\(unsafeAddressOf(attachment))"] {
                    v.frame = rect
                } else if let images = attachment.images {
                    let v = UIImageView(frame: rect)
                    v.byr_setImages(images)
                    self.views["\(unsafeAddressOf(attachment))"] = v
                    self.label.addSubview(v)
                }
            })
        }
    }
    
    func update(article: ArticleCellData) {
        articleData = article
        label.attributedText = article.displayContent
    }
    
    private func cleanViews() {
        views.forEach {
            if let view = $0.1 as? UIImageView {
                view.stopAnimating()
                view.animationImages = nil
            }
            $0.1.removeFromSuperview()
        }
        views.removeAll()
    }
    
    deinit {
        label.attributedText = nil
        cleanViews()
        print("cell deinit")
    }
}

func getHeight(attriString: NSAttributedString, boundingWidth width: CGFloat) -> CGFloat {
    let textStorage: NSTextStorage = NSTextStorage(attributedString: attriString)
    let layoutManager: NSLayoutManager = NSLayoutManager()
    let textContainer: NSTextContainer = NSTextContainer(size: CGSize(width: width, height: CGFloat.max))
    textContainer.lineFragmentPadding = 0
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    layoutManager.ensureLayoutForTextContainer(textContainer)
    let rect = layoutManager.usedRectForTextContainer(textContainer)
    return ceil(rect.height)
}