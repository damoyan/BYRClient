//
//  BYRUBBParser.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/31/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

let defaultArticleFontSize: CGFloat = 14

class Parser {
    
    let uploadCount: Int
    init(uploadCount: Int) {
        self.uploadCount = uploadCount
    }
    
    let ignoreTagStringArray: [(regexString: String, replaceTemplate: String)] = [
        // ignore all matches
        ("\\[ATT=([^\\[\\]]*?) SIZE=([^\\[\\]]*?)\\](?:\\s*?)\\[/ATT\\]", ""),
        ("\\[swf=((?:http|https)[^\\[\\]\"\\']*?)\\](?:\\s*?)\\[/swf\\]", ""),
        ("\\[mp3=((?:http|https)[^\\[\\]\"\\']*?) auto=([01])\\](?:\\s*?)\\[/mp3\\]", ""),
        ("\\[map=([0-9,.{}]*?) mark=([0-9,.{}]*?)\\](?:\\s*?)\\[/map\\]", ""),
        // ignore tag part of matches
        ("\\[move\\](.*?)\\[/move\\]", "$1"),
        ("\\[fly\\](.*?)\\[/fly\\]", "$1"),
        ("\\[glow=(?:[^,]*?),([^,]*?),([^,]*?)\\](.*?)\\[/glow\\]", "$3"),
        ("\\[shadow=(?:[^,]*?),([^,]*?),([^,]*?)\\](.*?)\\[/shadow\\]", "$3"),
        ("\\[code=(\\w*?)\\]([\\s\\S]*?)\\[/code\\]", "$2")
    ]
    let replaceStringArray = [
        ("\\[(em[abc]?)0?(\\d+)\\]", emotion),
        ("\\[img=((?:http|https)[^\\[\\]\"\\']*?)\\](?:\\s*?)\\[/img\\]", img),
        ("\\[upload=(\\d+)\\](?:\\s*?)\\[/upload\\]", upload)
    ]
    let regexStringArray = [
        ("\\[b\\](.*?)\\[/b\\]", bold),
        ("\\[i\\](.*?)\\[/i\\]", italic),
        ("\\[u\\](.*?)\\[/u\\]", underline),
        ("\\[color=(#\\w*?)\\](.*?)\\[/color\\]", color),
        ("\\[size=(\\d*?)\\](.*?)\\[/size\\]", size),
        ("\\[face=([^\\[\\]<>\"]{1,16})\\](.*?)\\[/face\\]", face),
        ("\\[url=((?:http|https|ftp|rtsp|mms)[^\\[\\]\"\\']*?)\\](.*?)\\[/url\\]", url),
        ("\\[email=((?:[a-zA-Z0-9]+[_|\\-|\\.]?)*[a-zA-Z0-9]+@(?:[a-zA-Z0-9)]+[_|\\-|\\.]?)*[a-zA-Z0-9]+\\.[a-zA-Z]{2,3})\\](.*?)\\[/email\\]", url),
        ("(?<!>|=|\")(?:http|https|ftp|rtsp|mms):(?://|\\\\\\)(&(?=amp;)|[A-Za-z0-9\\./=\\?%\\-#_~`@\\[\\]\\':;+!])+", urlNoTag)
    ]

    /// `r1` should contains `r2`
    func rangesIn(r1: NSRange, notIn r2: NSRange) -> [NSRange] {
        guard r1.location <= r2.location && r1.length >= r2.length else { return [] }
        var ret = [NSRange]()
        if r2.location - r1.location > 0 {
            ret.append(NSMakeRange(r1.location, r2.location - r1.location))
        }
        let diff = NSMaxRange(r1) - NSMaxRange(r2)
        if diff > 0 {
            ret.append(NSMakeRange(NSMaxRange(r2), diff))
        }
        return ret
    }

    // 2. ---------------------------------------------------
    // TODO: - update logic
    func emotion(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [(NSRange, NSAttributedString)] {
        guard let match = match where match.numberOfRanges > 2 else { return [] }
        let range = match.range
        let e1r = match.rangeAtIndex(1) // range contains characterRange
        let e2r = match.rangeAtIndex(2)
        let emotionName = (res.string as NSString).substringWithRange(e1r) + (res.string as NSString).substringWithRange(e2r)
        let attachment = BYRAttachment()
        attachment.type = .Emotion(emotionName)
        attachments.append(attachment)
        return [(range, NSAttributedString(attachment: attachment))]
    }

    func img(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [(NSRange, NSAttributedString)] {
        guard let match = match where match.numberOfRanges > 1 else { return [] }
        let range = match.range
        let imgURLr = match.rangeAtIndex(1) // range contains characterRange
        let imgURL = (res.string as NSString).substringWithRange(imgURLr)
        let attachment = BYRAttachment()
        attachment.type = .Img(imgURL)
        attachments.append(attachment)
        return [(range, NSAttributedString(attachment: attachment))]
    }

    func upload(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [(NSRange, NSAttributedString)] {
        guard let match = match where match.numberOfRanges > 1 && uploadCount > 0 else { return [] }
        let range = match.range
        let nor = match.rangeAtIndex(1) // range contains characterRange
        let no = (res.string as NSString).substringWithRange(nor).integerValue
        if no > uploadCount || uploadTagNo.contains(no) { return [] }
        let attachment = BYRAttachment()
        attachment.type = .Upload(no)
        attachments.append(attachment)
        uploadTagNo.append(no)
        return [(range, NSAttributedString(attachment: attachment))]
    }

    // 3. -----------------------------------------------
    func bold(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 1 else { return [] }
        let range = match.range
        let characterRange = match.rangeAtIndex(1) // range contains characterRange
        for i in 0 ..< characterRange.length {
            let index = characterRange.location + i
            if let font = res.attribute(NSFontAttributeName, atIndex: index, effectiveRange: nil) as? UIFont {
                var fontDes = font.fontDescriptor()
                fontDes = fontDes.fontDescriptorWithSymbolicTraits([fontDes.symbolicTraits, .TraitBold])
                res.addAttribute(NSFontAttributeName, value: UIFont(descriptor: fontDes, size: font.pointSize), range: NSMakeRange(index, 1))
            } else {
                res.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(defaultArticleFontSize), range: NSMakeRange(index, 1))
            }
        }
        return rangesIn(range, notIn: characterRange)
    }

    func italic(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 1 else { return [] }
        let range = match.range
        let characterRange = match.rangeAtIndex(1) // range contains characterRange
        for i in 0 ..< characterRange.length {
            let index = characterRange.location + i
            if let font = res.attribute(NSFontAttributeName, atIndex: index, effectiveRange: nil) as? UIFont {
                var fontDes = font.fontDescriptor()
                fontDes = fontDes.fontDescriptorWithSymbolicTraits([fontDes.symbolicTraits, .TraitItalic])
                res.addAttribute(NSFontAttributeName, value: UIFont(descriptor: fontDes, size: font.pointSize), range: NSMakeRange(index, 1))
            } else {
                res.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFontOfSize(defaultArticleFontSize), range: NSMakeRange(index, 1))
            }
        }
        return rangesIn(range, notIn: characterRange)
    }

    func underline(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 1 else { return [] }
        let range = match.range
        let characterRange = match.rangeAtIndex(1) // range contains characterRange
        res.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: characterRange)
        return rangesIn(range, notIn: characterRange)
    }

    func color(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 2 else { return [] }
        let range = match.range
        let colorRange = match.rangeAtIndex(1)
        let colorString = (res.string as NSString).substringWithRange(colorRange)
        let characterRange = match.rangeAtIndex(2) // range contains characterRange
        res.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgbString: colorString), range: characterRange)
        return rangesIn(range, notIn: characterRange)
    }

    func size(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 1 else { return [] }
        let range = match.range
        let sizeRange = match.rangeAtIndex(1)
        let size = (res.string as NSString).substringWithRange(sizeRange).floatValue
        let characterRange = match.rangeAtIndex(2) // range contains characterRange
        for i in 0 ..< characterRange.length {
            let index = characterRange.location + i
            if let font = res.attribute(NSFontAttributeName, atIndex: index, effectiveRange: nil) as? UIFont {
                let newFont = font.fontWithSize(font.pointSize + CGFloat(size))
                res.addAttribute(NSFontAttributeName, value: newFont, range: NSMakeRange(index, 1))
            } else {
                res.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(defaultArticleFontSize + CGFloat(size)), range: NSMakeRange(index, 1))
            }
        }
        return rangesIn(range, notIn: characterRange)
    }
    
    func face(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 1 else { return [] }
        let range = match.range
        let facer = match.rangeAtIndex(1)
        let face = (res.string as NSString).substringWithRange(facer)
        let characterRange = match.rangeAtIndex(2) // range contains characterRange
        for i in 0 ..< characterRange.length {
            let index = characterRange.location + i
            if let font = res.attribute(NSFontAttributeName, atIndex: index, effectiveRange: nil) as? UIFont {
                let symbolicTraints = font.fontDescriptor().symbolicTraits
                var st: UIFontDescriptorSymbolicTraits = []
                if symbolicTraints.contains(.TraitBold) {
                    st.insert(.TraitBold)
                }
                if symbolicTraints.contains(.TraitItalic) {
                    st.insert(.TraitItalic)
                }
                if let newFont = UIFont(name: face, size: font.pointSize) {
                    let des = newFont.fontDescriptor()
                    let d = des.fontDescriptorWithSymbolicTraits(st)
                    let f = UIFont(descriptor: d, size: newFont.pointSize)
                    res.addAttribute(NSFontAttributeName, value: f, range: NSMakeRange(index, 1))
                }
            } else {
                res.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(defaultArticleFontSize), range: NSMakeRange(index, 1))
            }
        }
        return rangesIn(range, notIn: characterRange)
    }

    func url(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 2 else { return [] }
        let range = match.range
        let urlRange = match.rangeAtIndex(1)
        let url = (res.string as NSString).substringWithRange(urlRange)
        let characterRange = match.rangeAtIndex(2) // range contains characterRange
        res.addAttribute(NSLinkAttributeName, value: url, range: characterRange)
        return rangesIn(range, notIn: characterRange)
    }

    func urlNoTag(res: NSMutableAttributedString, match: NSTextCheckingResult?, flags: NSMatchingFlags) -> [NSRange] {
        guard let match = match where match.numberOfRanges > 2 else { return [] }
        let range = match.range
        let url = (res.string as NSString).substringWithRange(range)
        res.addAttribute(NSLinkAttributeName, value: url, range: range)
        return []
    }

    var attachments = [BYRAttachment]()
    var uploadTagNo = [Int]()
    func parse(content: String) -> NSAttributedString {
        attachments.removeAll(keepCapacity: false)
        uploadTagNo.removeAll(keepCapacity: false)
        // 1. ingore
        let str = ignoreTagStringArray.reduce(content) { (str, t) in
            guard let regex = try? NSRegularExpression(pattern: t.regexString, options: [.DotMatchesLineSeparators, .CaseInsensitive]) else {
                return str
            }
            return regex.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.utf16.count), withTemplate: t.replaceTemplate)
        }
        
        // 2. replace
        let res = NSMutableAttributedString(string: str, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(defaultArticleFontSize)])
        var replaceRange = [(NSRange, NSAttributedString)]()
        replaceStringArray.forEach { regexString, block in
            guard let regex = try? NSRegularExpression(pattern: regexString, options: [.DotMatchesLineSeparators, .CaseInsensitive]) else { return }
            regex.enumerateMatchesInString(res.string, options: [], range: NSMakeRange(0, res.length), usingBlock: { (match, flags, _) -> Void in
                replaceRange += block(self)(res, match: match, flags: flags)
//                replaceRange += block(res, match: match, flags: flags)
            })
        }
        replaceRange.sort { $0.0.0.location > $0.1.0.location }.forEach { res.replaceCharactersInRange($0.0, withAttributedString: $0.1) }
        
        // 3. delete
        var rangesToDelete = [NSRange]()
        regexStringArray.forEach { regexString, block in
            guard let regex = try? NSRegularExpression(pattern: regexString, options: [.DotMatchesLineSeparators, .CaseInsensitive]) else { return }
            regex.enumerateMatchesInString(res.string, options: [], range: NSMakeRange(0, res.length), usingBlock: { (match, flags, _) -> Void in
                rangesToDelete += block(self)(res, match: match, flags: flags)
            })
        }
        rangesToDelete.sort { $0.0.location > $0.1.location }.forEach { res.deleteCharactersInRange($0) }
        parseQuote(res)
        res.fixAttributesInRange(NSMakeRange(0, res.length))
        return res.copy() as! NSAttributedString
    }
    
    private func parseQuote(result: NSMutableAttributedString) {
        let regex = try? NSRegularExpression(pattern: "\n: [^\n]*+", options: [])
        regex?.enumerateMatchesInString(result.string, options: [], range: NSMakeRange(0, result.length), usingBlock: { (match, _, _) -> Void in
            guard let match = match where match.range.length > 1 else { return }
            result.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgb: 0x00b4af), range: NSMakeRange(match.range.location + 1, match.range.length - 1))
        })
    }
}


















































/*


public protocol UBBParserDelegate: class {
    func parser(parser: BYRUBBParser, didStartParsingString string: String)
    func parser(parser: BYRUBBParser, foundCharacter char: String)
    func parser(parser: BYRUBBParser, didStartParsingTag tag: String, withAttributes attributes: [String: AnyObject]?)
    func parser(parser: BYRUBBParser, didFinishParsingTag tag: String)
    func parser(parser: BYRUBBParser, didFinishParsingString string: String)
}



struct Tag {
    var tagName: String
    var attributes: [String: AnyObject]?
}

private let NormalTagKey = "normal"
private let NoContentTagKey = "noContent"
private let NoContentButAttribute = "noContentButAttribute"
private let NoEndTagKey = "noEnd"

/// the parser is not common UBB parser. Just used for http://bbs.byr.cn
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
    
    public var resultAttributedString: NSAttributedString {
        get {
            return result.copy() as! NSAttributedString
        }
    }
    public var uploadTagNo = [Int]() // upload tag numerical order
    public var attachments = [BYRAttachment]()
    
    private var result = NSMutableAttributedString()
    
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
        attachment.type = .Emotion(tag)
        attachments.append(attachment)
        result.appendAttributedString(NSAttributedString(attachment: attachment))
    }
    
    private func parseStartForTag(tagString: String) {
        let tag = getStartTagInfo(tagString)
        currentTags.append(tag)
        delegate?.parser(self, didStartParsingTag: tag.tagName, withAttributes: tag.attributes)
    }
    
    private func parseEndForTag(tagName: String, isNoContent: Bool = false) {
        guard let tag = removeLatestTag(tagName) else { return }
        assert(tag.tagName == tagName)
        if isNoContent {
            let attachment = BYRAttachment()
//            attachment.image = UIImage(named: "big")
            attachment.tag = tag
            // 当内容中没有[upload]而实际文章包含附件的时候, 论坛会把附件放到文章最后, 这里记录文章中出现过的附件的序号
            if tag.tagName == "upload", let no = tag.attributes?[tagName] as? NSString {
                uploadTagNo.append(no.integerValue)
            }
            // TODO: add attachment
            attachments.append(attachment)
            result.appendAttributedString(NSAttributedString(attachment: attachment))
        }
        delegate?.parser(self, didFinishParsingTag: tagName)
    }
    
    private func removeLatestTag(tagName: String) -> Tag? {
        for var i = (currentTags.count - 1); i >= 0; i-- {
            if currentTags[i].tagName == tagName {
                return currentTags.removeAtIndex(i)
            }
        }
        return nil
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
    
    deinit {
        attachments.removeAll()
        result = NSMutableAttributedString()
        po("deinit parser")
    }
}
*/
