//
//  RefreshView.swift
//  FromScratch
//
//  Created by Yu Pengyang on 1/20/16.
//  Copyright © 2016 Yu Pengyang. All rights reserved.
//

import UIKit

protocol Refresh {
    var isRefreshing: Bool { get }
    func beginRefreshing()
    func endRefreshing()
}

class RefreshView: UIView {
    enum Status {
        case Idle
        case ReadyRefresh // 这里也没用到这个状态. 因为决定只要拉过contentHeight就直接刷新了. 没有加阈值
        case Refreshing
        // 应该不会用这个. 对于帖子来说, 上拉加载更多是获取最新的帖子, 所以任何时候都可以上拉. 哪怕拉回来没有数据.
        // 但是版面不一样, 版面上拉是获取以前的, 这个是有可能到最后没有数据的. 但是这种情况用LoadingCell就可以解决,
        // 不会用这个控件. 所以这个字段应该不会用, 所以这里不会处理相关逻辑.
        case NoMore
    }
    typealias RefreshingBlock = () -> ()
    let contentSizeKey = "contentSize"
    let contentOffsetKey = "contentOffset"
    let stateKey = "state"
    
    private var status: Status = .Idle {
        didSet {
            if status != oldValue {
                stateChanged()
            }
        }
    }
    
    private var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var label = UILabel()
    private var block: RefreshingBlock = {}
    
    weak var scrollView: UIScrollView?
    private var insetBottomChanged: Bool = false
    var pan: UIPanGestureRecognizer?
    var panEnd = false
    
    init(size: CGSize, block: RefreshingBlock) {
        self.block = block
        super.init(frame: CGRect(origin: CGPointZero, size: size))
        label.font = UIFont.systemFontOfSize(defaultArticleFontSize)
        label.textColor = UIColor.darkTextColor()
//        backgroundColor = UIColor.whiteColor()
        addSubview(label)
        addSubview(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        unregisterObserver()
        clearBottom()
        if let new = newSuperview as? UIScrollView where new !== scrollView {
            scrollView = new
            pan = new.panGestureRecognizer
            py_y = new.py_contentHeight
            updateBottom()
            registerObserver()
        }
    }
    
    private func updateBottom() {
        if !insetBottomChanged, let s = scrollView /*where s.py_top + s.py_contentHeight >= s.py_height*/ {
            s.py_bottom += py_height
            insetBottomChanged = true
        }
    }
    
    private func clearBottom() {
        if insetBottomChanged, let s = scrollView {
            s.py_bottom -= py_height
            insetBottomChanged = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        let center = CGPoint(x: py_width / 2, y: py_height / 2)
        label.center = center
        indicator.center = CGPoint(x: center.x - 80, y: center.y)
    }
    
    deinit {
        unregisterObserver()
        po("deinit")
    }
    
}

extension RefreshView {
    private func stateChanged() {
        switch status {
        case .Idle:
            indicator.stopAnimating()
            label.text = nil
            label.sizeToFit()
        case .ReadyRefresh:
            label.text = "松手立即刷新"
            label.sizeToFit()
        case .Refreshing:
            label.text = "正在刷新..."
            label.sizeToFit()
            indicator.startAnimating()
            executeRefreshingBlock()
        case .NoMore:
            label.text = "没有更多了"
            label.sizeToFit()
            indicator.stopAnimating()
        }
    }
    
    private func executeRefreshingBlock() {
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            self?.block()
        }
    }
}

// KVO
extension RefreshView {
    private func registerObserver() {
        scrollView?.addObserver(self, forKeyPath: contentSizeKey, options: [.New, .Old], context: nil)
        scrollView?.addObserver(self, forKeyPath: contentOffsetKey, options: [.New, .Old], context: nil)
        pan?.addObserver(self, forKeyPath: stateKey, options: [.New], context: nil)
    }
    
    private func unregisterObserver() {
        // remove的时候需要用superview而不能用scrollView, 因为scrollView可能已经是nil了.
        superview?.removeObserver(self, forKeyPath: contentSizeKey, context: nil)
        superview?.removeObserver(self, forKeyPath: contentOffsetKey, context: nil)
        pan?.removeObserver(self, forKeyPath: stateKey, context: nil)
        pan = nil
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == stateKey {
            panStateChanged(change)
            return
        }
        guard let scrollView = object as? UIScrollView where scrollView === self.scrollView else { return }
        if keyPath == contentSizeKey {
            contentSizeChanged(change)
        } else if keyPath == contentOffsetKey {
            contentOffsetChanged(change)
        }
    }
    
    private func panStateChanged(change: [String: AnyObject]?) {
        guard !isRefreshing else { return }
        if let scrollView = self.scrollView where scrollView.panGestureRecognizer.state == .Ended {
            panEnd = true
            if scrollView.py_top + scrollView.py_contentHeight < scrollView.py_height {
                if scrollView.py_offsetY > -scrollView.py_top {
                    beginRefreshing()
                }
            } else {
                if scrollView.py_offsetY > scrollView.py_contentHeight - scrollView.py_height {
                    beginRefreshing()
                }
            }
        } else {
            panEnd = false
        }
    }
    
    private func contentSizeChanged(change: [String: AnyObject]?) {
        guard let scrollView = self.scrollView else { return }
        py_y = scrollView.py_contentHeight
        updateBottom()
    }
    
    private func contentOffsetChanged(change: [String: AnyObject]?) {
        guard !isRefreshing && panEnd, let scrollView = self.scrollView else { return }
        // 注，在 didEndDragging 之后，如果有减速过程，scroll view 的 dragging 并不会立即置为 NO，而是要等到减速结束之后，所以这个 dragging 属性的实际语义更接近 scrolling。
        if scrollView.dragging { // 关于dragging何时为true, 参见: http://tech.glowing.com/cn/practice-in-uiscrollview/
            let old = (change?[NSKeyValueChangeOldKey] as? NSValue)?.CGPointValue(), new = (change?[NSKeyValueChangeNewKey] as? NSValue)?.CGPointValue()
            if old?.y >= new?.y {
                return
            }
            if scrollView.py_top + scrollView.py_contentHeight < scrollView.py_height {
                if scrollView.py_offsetY > -scrollView.py_top {
                    beginRefreshing()
                }
            } else {
                if scrollView.py_offsetY > scrollView.py_contentHeight - scrollView.py_height {
                    beginRefreshing()
                }
            }
        }
    }
}

extension RefreshView: Refresh {
    var isRefreshing: Bool {
        return status == .Refreshing
    }
    
    func beginRefreshing() {
        status = .Refreshing
    }
    
    func endRefreshing() {
        status = .Idle
        
    }
}