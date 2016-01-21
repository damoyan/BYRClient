//
//  UIViewExtension.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return layer.borderColor == nil ? nil : UIColor(CGColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

extension UIView {
    var viewController: UIViewController? {
        var responder: UIResponder = self
        while let res = responder.nextResponder() {
            if let vc = res as? UIViewController {
                return vc
            } else {
                responder = res
            }
        }
        return nil
    }
}

extension UIView {
    var py_x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            let f = CGRect(x: newValue, y: py_y, width: py_width, height: py_height)
            frame = f
        }
    }
    
    var py_y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            let f = CGRect(x: py_x, y: newValue, width: py_width, height: py_height)
            frame = f
        }
    }
    
    var py_width: CGFloat {
        get {
            return frame.width
        }
        set {
            let f = CGRect(x: py_x, y: py_y, width: newValue, height: py_height)
            frame = f
        }
    }
    
    var py_height: CGFloat {
        get {
            return frame.height
        }
        set {
            let f = CGRect(x: py_x, y: py_y, width: py_width, height: newValue)
            frame = f
        }
    }
}

extension UIScrollView {
    var py_contentHeight: CGFloat {
        return contentSize.height
    }
    
    var py_top: CGFloat {
        get {
            return contentInset.top
        }
        set {
            contentInset.top = newValue
        }
    }
    
    var py_bottom: CGFloat {
        get {
            return contentInset.bottom
        }
        set {
            contentInset.bottom = newValue
        }
    }
    
    var py_offsetY: CGFloat {
        get {
            return contentOffset.y
        }
    }
}