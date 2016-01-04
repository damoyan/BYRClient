//
//  BYRUBBParser.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/31/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

public protocol UBBParserDelegate: class {
    func parser(parser: BYRUBBParser, didStartParsingString string: String)
    func parser(parser: BYRUBBParser, foundCharacter char: String)
    func parser(parser: BYRUBBParser, didStartParsingTag tag: String, withAttributes attributes: [String: AnyObject]?)
    func parser(parser: BYRUBBParser, didFinishParsingTag tag: String)
    func parser(parser: BYRUBBParser, didFinishParsingString string: String)
}

let defaultArticleFontSize: CGFloat = 12

struct Tag {
    var tagName: String
    var attributes: [String: AnyObject]?
}

private let NormalTagKey = "normal"
private let NoContentTagKey = "noContent"
private let NoContentButAttribute = "noContentButAttribute"
private let NoEndTagKey = "noEnd"

public class BYRUBBParser {
    
    private var tags: [String: [String]] = {
        var ret = [String: [String]]()
        ret[NormalTagKey] = ["b", "i", "u", "face", "size", "color", "code", "email", "url"]
        ret[NoContentTagKey] = ["img", "swf", "mp3", "map", "upload"]
        ret[NoEndTagKey] = []
        return ret
    }()
    private let startTag = "["
    private let endTag = "]"
    private let closingTag = "/"
    private let emotionPrefix = "em"
    private let emotions = ["": (1, 73), "a": (0, 41), "b": (0, 24), "c": (0, 58)]
    
    public weak var delegate: UBBParserDelegate?
    
    private var defaultAttributes = [String: AnyObject]()
    private var currentTags = [Tag]()
    public private(set) var result = NSMutableAttributedString()
    
    public init(font: UIFont = UIFont.systemFontOfSize(defaultArticleFontSize), color: UIColor = UIColor.darkTextColor()) {
        self.defaultAttributes[NSFontAttributeName] = font
        self.defaultAttributes[NSForegroundColorAttributeName] = color
    }
    
    /// the string will be cast to NSString
    /// and then use the NSString to do parsing work
    public func parse(string: String) {
        delegate?.parser(self, didStartParsingString: string)
        
        let code = string as NSString
        var readingTag = false
        var currentTag: String?
        var emotion = false
        var isNoContent = false
        for var i = 0; i < code.length; i++ {
            let char = code.substringWithRange(NSMakeRange(i, 1))
            if char == startTag {
                let s = code.substringFromIndex(i).lowercaseString
                if stringStartWithNormalTag(s) {
                    readingTag = true
                    currentTag = ""
                    emotion = false
                } else if stringStartWithNoContentTag(s) {
                    readingTag = true
                    currentTag = ""
                    emotion = false
                    isNoContent = true
                } else if isEmotion(s) {
                    readingTag = true
                    currentTag = ""
                    emotion = true
                } else {
                    foundCharacter(char)
                }
            }
            else if char == endTag && currentTag != nil {
                if currentTag!.hasPrefix(closingTag) {
                    parseEndForTag(currentTag!.substringFromIndex(currentTag!.startIndex.successor()), isNoContent: isNoContent)
                    isNoContent = false
                } else if emotion {
                    parseEmotionTag(currentTag!)
                } else {
                    parseStartForTag(currentTag!)
                }
                currentTag = nil
                readingTag = false
                emotion = false
            }
            else {
                if readingTag {
                    currentTag! += char
                } else {
                    foundCharacter(char)
                }
            }
        }
        parseQuote()
        result.fixAttributesInRange(NSMakeRange(0, result.length))
        delegate?.parser(self, didFinishParsingString: string)
    }
    
    private func stringStartWithNormalTag(string: String) -> Bool {
        guard let tags = tags[NormalTagKey] else { return false }
        for tag in tags {
            let validBegining1 = startTag + tag + endTag                // "[bold]"
            let validBegining2 = startTag + closingTag + tag + endTag   // "[/bold]"
            let validBegining3 = startTag + tag + " "                   // "[bold "
            let validBegining4 = startTag + tag + "="                   // "[bold="
            if string.hasPrefix(validBegining1) || (string.hasPrefix(validBegining2) && currentTags.count > 0) || string.hasPrefix(validBegining3) || string.hasPrefix(validBegining4) {
                return true
            }
        }
        return false
    }
    
    private func stringStartWithNoContentTag(string: String) -> Bool {
        guard let tags = tags[NoContentTagKey] else { return false }
        for tag in tags {
            let validBegining2 = startTag + closingTag + tag + endTag   // "[/img]"
            if string.hasPrefix(validBegining2) && currentTags.count > 0 { return true }
            let regexString = "^\\[\(tag)[^\\[\\]]+?\\]\\["
            let regex = try? NSRegularExpression(pattern: regexString, options: [])
            if let matches = regex?.matchesInString(string, options: [], range: NSMakeRange(0, string.utf16.count)) where matches.count > 0 {
                return true
            }
        }
        return false
    }
    
    private func isEmotion(string: String) -> Bool {
        for (k, v) in emotions {
            for var i = v.0; i < v.1; i++ {
                let emo = startTag + emotionPrefix + k + "\(i)" + endTag
                if string.hasPrefix(emo) {
                    return true
                }
            }
        }
        return false
    }
    
    private func foundCharacter(string: String) {
        result.appendAttributedString(NSAttributedString(string: string, attributes: tagsToStringAttributes()))
        delegate?.parser(self, foundCharacter: string)
    }
    
    private func parseEmotionTag(tag: String) {
        // TODO:
        let attachment = BYRAttachment()
        attachment.text = tag
        attachment.type = .AnimatedImage
        attachment.image = UIImage(named: "default_avatar")
        attachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        result.appendAttributedString(NSAttributedString(attachment: attachment))
    }
    
    private func parseStartForTag(tagString: String) {
        let tag = getStartTagInfo(tagString)
        currentTags.append(tag)
        delegate?.parser(self, didStartParsingTag: tag.tagName, withAttributes: tag.attributes)
    }
    
    private func parseEndForTag(tagName: String, isNoContent: Bool = false) {
        let tag = currentTags.removeLast()
        assert(tag.tagName == tagName)
        if isNoContent {
            let attachment = BYRAttachment()
            attachment.text = tag.tagName
            result.appendAttributedString(NSAttributedString(attachment: attachment))
            // TODO: add attachment
        }
        delegate?.parser(self, didFinishParsingTag: tagName)
    }
    
    private func parseQuote() {
        let regex = try? NSRegularExpression(pattern: "\n: [^\n]*+", options: [])
        regex?.enumerateMatchesInString(result.string, options: [], range: NSMakeRange(0, result.length), usingBlock: { (match, _, _) -> Void in
            guard let match = match where match.range.length > 1 else { return }
            self.result.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgb: 0x00b4af), range: NSMakeRange(match.range.location + 1, match.range.length - 1))
        })
    }
    
    private func getStartTagInfo(tag: String) -> Tag {
        let components = tag.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        var name = components[0]
        let nameComponents = name.componentsSeparatedByString("=")
        name = nameComponents[0]
        
        if let kvs = getKeyValuePair(components) {
            return Tag(tagName: name, attributes: kvs)
        } else {
            return Tag(tagName: name, attributes: nil)
        }
    }
    
    private func getKeyValuePair(components: [String]) -> [String: String]? {
        var ret = [String: String]()
        components.forEach { component in
            if let range = component.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "=")) {
                let key = component.substringToIndex(range.startIndex)
                let value = component.substringFromIndex(range.endIndex)
                ret[key] = value
            }
        }
        return ret.count > 0 ? ret : nil
    }
    
    private func tagsToStringAttributes() -> [String: AnyObject]? {
        guard currentTags.count > 0 else { return defaultAttributes }
        var ret = [String: AnyObject]()
        ret[NSFontAttributeName] = (defaultAttributes[NSFontAttributeName] as? UIFont) ?? UIFont.systemFontOfSize(defaultArticleFontSize)
        ret[NSForegroundColorAttributeName] = (defaultAttributes[NSForegroundColorAttributeName] as? UIColor) ?? UIColor.darkTextColor()
        currentTags.forEach { tag in
            switch tag.tagName {
            case "face":
                let font = ret[NSFontAttributeName] as! UIFont
                let symbolicTraints = font.fontDescriptor().symbolicTraits
                var st: UIFontDescriptorSymbolicTraits = []
                if symbolicTraints.contains(.TraitBold) {
                    st.insert(.TraitBold)
                }
                if symbolicTraints.contains(.TraitItalic) {
                    st.insert(.TraitItalic)
                }
                if let newFont = UIFont(name: ((tag.attributes?["face"] as? String) ?? ""), size: font.pointSize) {
                    let des = newFont.fontDescriptor()
                    let d = des.fontDescriptorWithSymbolicTraits(st)
                    let f = UIFont(descriptor: d, size: newFont.pointSize)
                    ret[NSFontAttributeName] = f
                } else {
                    ret[NSFontAttributeName] = font
                }
            case "b":
                let font = ret[NSFontAttributeName] as! UIFont
                var descriptor = font.fontDescriptor()
                descriptor = descriptor.fontDescriptorWithSymbolicTraits([descriptor.symbolicTraits, .TraitBold])
                ret[NSFontAttributeName] = UIFont(descriptor: descriptor, size: font.pointSize)
            case "i":
                let font = ret[NSFontAttributeName] as! UIFont
                var descriptor = font.fontDescriptor()
                descriptor = descriptor.fontDescriptorWithSymbolicTraits([descriptor.symbolicTraits, .TraitItalic])
                ret[NSFontAttributeName] = UIFont(descriptor: descriptor, size: font.pointSize)
            case "u":
                ret[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
            case "size":
                if let size = tag.attributes?["size"] as? NSString {
                    var font = ret[NSFontAttributeName] as! UIFont
                    font = font.fontWithSize(CGFloat(size.floatValue) + defaultArticleFontSize)
                    ret[NSFontAttributeName] = font
                }
            case "color":
                if let color = tag.attributes?["color"] as? String {
                    ret[NSForegroundColorAttributeName] = UIColor(rgbString: color)
                }
            case "url":
                ret[NSLinkAttributeName] = tag.attributes?["url"]
            case "email":
                ret[NSLinkAttributeName] = tag.attributes?["email"]
            default:
                break
            }
        }
        return ret.count > 0 ? ret : nil
    }
}
