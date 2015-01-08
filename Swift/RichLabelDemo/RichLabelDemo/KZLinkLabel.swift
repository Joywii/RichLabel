//
//  KZLinkLabel.swift
//  RichLabelDemo
//
//  Created by joywii on 14/12/22.
//  Copyright (c) 2014年 joywii. All rights reserved.
//

import UIKit

enum KZLinkType : UInt
{
    case UserHandle  = 1   //用户昵称  eg: @kingzwt
    case HashTag = 2        //内容标签  eg: #hello
    case URL = 3           //链接地址  eg: http://www.baidu.com
    case PhoneNumber = 4    //电话号码  eg: 13888888888
}

enum KZLinkDetectionTypes : UInt8
{
    case UserHandle = 1
    case HashTag = 2
    case URL = 3
    case PhoneNumber = 4
    case None = 0
    case All = 255
}
struct KZLinkDetectionType : RawOptionSetType {
    typealias RawValue = UInt
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    static var allZeros: KZLinkDetectionType { return self(0) }
    static func fromMask(raw: UInt) -> KZLinkDetectionType { return self(raw) }
    var rawValue: UInt { return self.value }
    
    static var None: KZLinkDetectionType { return self(0) }
    static var UserHandle: KZLinkDetectionType   { return self(1 << 0) }
    static var HashTag: KZLinkDetectionType  { return self(1 << 1) }
    static var URL: KZLinkDetectionType   { return self(1 << 2) }
    static var PhoneNumber: KZLinkDetectionType   { return self(1 << 2) }
    static var All: KZLinkDetectionType   { return self(UInt.max) }
}

typealias KZLinkHandler = (linkType:KZLinkType, string:String, range:NSRange) -> ()

class KZLinkLabel: UILabel , NSLayoutManagerDelegate
{
    var linkTapHandler:KZLinkHandler?
    var linkLongPressHandle:KZLinkHandler?
    
    var layoutManager:NSLayoutManager!
    var textContainer:NSTextContainer!
    var textStorage:NSTextStorage!
    var linkRanges:NSArray!
    var isTouchMoved:Bool?
    
    var automaticLinkDetectionEnabled:Bool? {
        didSet {
            self.updateTextStoreWithText()
        }
    }
    var linkDetectionType:KZLinkDetectionType? {
        didSet {
           self.updateTextStoreWithText()
        }
    }
    var linkColor:UIColor? {
        didSet {
            self.updateTextStoreWithText()
        }
    }
    var linkHightlightColor:UIColor? {
        didSet {
            self.updateTextStoreWithText()
        }
    }
    var linkBackgroundColor:UIColor? {
        didSet {
            self.updateTextStoreWithText()
        }
    }
    var selectedRange:NSRange? {
        willSet {
            if (self.selectedRange?.length > 0 && !NSEqualRanges(self.selectedRange!,newValue!)) {
                self.textStorage.removeAttribute(NSBackgroundColorAttributeName, range: self.selectedRange!)
                self.textStorage.addAttribute(NSForegroundColorAttributeName, value: self.linkColor!, range: self.selectedRange!)
            }
            if (newValue?.length > 0) {
                self.textStorage.addAttribute(NSBackgroundColorAttributeName, value: self.linkBackgroundColor!, range: newValue!)
                self.textStorage.addAttribute(NSForegroundColorAttributeName, value: self.linkHightlightColor!, range: newValue!)
            }
        }
        didSet {
            self.setNeedsDisplay()
        }
    }
    //属性
    override var frame: CGRect {
        didSet {
            //self.textContainer.size = self.bounds.size
        }
    }
    override var bounds: CGRect {
        didSet {
            self.textContainer.size = self.bounds.size
        }
    }
    override var numberOfLines:Int {
        get {
            return super.numberOfLines
        }
        set {
            super.numberOfLines = newValue
            self.textContainer.maximumNumberOfLines = numberOfLines
        }
    }
    override var text:String? {
        get {
            return super.text
        }
        set {
            super.text = newValue
            var attributedText:NSAttributedString = NSAttributedString(string: newValue!, attributes:self.attributesFromProperties())
            self.updateTextStoreWithAttributedString(attributedText)
        }
    }
    override var attributedText:NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            super.attributedText = newValue
            var mutableAttributeString:NSMutableAttributedString = NSMutableAttributedString(attributedString: newValue!)
            mutableAttributeString.addAttributes(self.attributesFromProperties(), range: NSMakeRange(0, mutableAttributeString.length))
            self.updateTextStoreWithAttributedString(mutableAttributeString)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textContainer.size = self.bounds.size
    }
    
    //初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupTextSystem()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setupTextSystem()
    {
        self.textContainer = NSTextContainer()
        self.textContainer.lineFragmentPadding = 0
        self.textContainer.maximumNumberOfLines = 0//self.numberOfLines
        self.textContainer.lineBreakMode = .ByTruncatingTail//self.lineBreakMode
        self.textContainer.size = self.frame.size
        
        self.layoutManager = NSLayoutManager()
        self.layoutManager.delegate = self
        self.layoutManager.addTextContainer(self.textContainer)
        
        self.textContainer.layoutManager = self.layoutManager
        
        self.userInteractionEnabled = true
        
        self.automaticLinkDetectionEnabled = true
        
        self.linkDetectionType = KZLinkDetectionType.All
        
        self.linkBackgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.linkColor = UIColor.blueColor()
        self.linkHightlightColor = UIColor.redColor()
        
        self.updateTextStoreWithText()
        
        var longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressLabel:")
        self.addGestureRecognizer(longPressGesture)
        
        //默认回调
        self.linkTapHandler = { (linkType:KZLinkType, string:String, range:NSRange) -> () in
            NSLog("Link Tap Handler")
        }
        self.linkLongPressHandle = { (linkType:KZLinkType, string:String, range:NSRange) -> () in
            NSLog("Link Long Press Handler");
        }
    }
    /*
    * linkType : 链接类型
    * range    : 链接区域
    * link     : 链接文本
    */
    func getLinkAtLocation(var location:CGPoint) -> Dictionary<String, AnyObject>?
    {
        if (self.textStorage.string.isEmpty) {
            return nil
        }
        var textOffset:CGPoint
        var glyphRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
        textOffset = self.calcTextOffsetForGlyphRange(glyphRange)
        
        location.x -= textOffset.x
        location.y -= textOffset.y
        
        var touchedChar:Int = self.layoutManager.glyphIndexForPoint(location, inTextContainer: self.textContainer)
        
        var lineRange:NSRange = NSMakeRange(0, 0)
        var lineRect:CGRect = self.layoutManager .lineFragmentRectForGlyphAtIndex(touchedChar, effectiveRange: &lineRange)
        if (!CGRectContainsPoint(lineRect, location)) {
            return nil
        }
        
        for dictionary in linkRanges as [Dictionary<String, AnyObject>] {
            var rangeValue:NSValue = dictionary["range"] as NSValue
            var range:NSRange = rangeValue.rangeValue
            if (touchedChar >= range.location && touchedChar < (range.location + range.length)) {
                return dictionary
            }
        }
        return nil
    }
    func updateTextStoreWithText()
    {
        if (self.attributedText != nil) {
            var mutableAttributeString:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
            mutableAttributeString.addAttributes(self.attributesFromProperties(), range: NSMakeRange(0, mutableAttributeString.length))
            self.updateTextStoreWithAttributedString(mutableAttributeString)
        } else if (self.text != nil) {
            var attributeText:NSAttributedString = NSAttributedString(string: self.text!, attributes: self.attributesFromProperties())
            self.updateTextStoreWithAttributedString(attributeText)
        } else {
            var attributeText:NSAttributedString = NSAttributedString(string: "", attributes: self.attributesFromProperties())
            self.updateTextStoreWithAttributedString(attributeText)
        }
        self.setNeedsDisplay()
    }
    func updateTextStoreWithAttributedString(var attributedString:NSAttributedString)
    {
        var myAttributedString:NSAttributedString = attributedString
        if(attributedString.length != 0) {
            attributedString = KZLinkLabel.sanitizeAttributedString(attributedString)
        }
        if (self.automaticLinkDetectionEnabled! && (attributedString.length != 0)) {
            self.linkRanges = self.getRangesForLinks(attributedString)
            attributedString = self.addLinkAttributesToAttributedString(attributedString, linkRanges: self.linkRanges)
        } else {
            self.linkRanges = nil;
        }
        
        if (self.textStorage != nil) {
            self.textStorage.setAttributedString(attributedString)
        } else {
            self.textStorage = NSTextStorage(attributedString: attributedString)
            self.textStorage.addLayoutManager(self.layoutManager)
            self.layoutManager.textStorage = self.textStorage
        }
    }
    /*
    * 链接文本属性
    */
    func addLinkAttributesToAttributedString(string:NSAttributedString, linkRanges:NSArray) -> NSAttributedString
    {
        var attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: string)
        
        var attributeDic:Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        attributeDic.updateValue(self.linkColor!, forKey: NSForegroundColorAttributeName)
        
        for dictionary in linkRanges as [Dictionary<String, AnyObject>] {
            var rangeValue:NSValue = dictionary["range"] as NSValue
            var range:NSRange = rangeValue.rangeValue
            attributedString.addAttributes(attributeDic, range: range)
        }
        return attributedString
    }
    /*
     * 普通文本属性
     */
    func attributesFromProperties() -> NSDictionary
    {
        //阴影属性
        var shadow:NSShadow = NSShadow();
        if((self.shadowColor) != nil){
            shadow.shadowColor = self.shadowColor
            shadow.shadowOffset = self.shadowOffset
        } else {
            shadow.shadowOffset = CGSizeMake(0, -1)
            shadow.shadowColor = nil
        }
        //颜色属性
        var color:UIColor = self.textColor
        if(!self.enabled) {
            color = UIColor.lightGrayColor()
        } else {
            //color = self.highlightedTextColor
        }
        
        //段落属性
        var paragraph:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.alignment = self.textAlignment
        
        //属性字典
        var attributes:Dictionary<String,AnyObject> = [
                                                          NSFontAttributeName : self.font,
                                                          NSForegroundColorAttributeName : color,
                                                          NSShadowAttributeName : shadow,
                                                          NSParagraphStyleAttributeName : paragraph
                                                      ]
        
        return attributes
    }
    /*
    * 修正换行模式
    */
    class func sanitizeAttributedString(attributedString:NSAttributedString) -> NSAttributedString
    {
        var range:NSRange = NSMakeRange(0, 0)
        var paragraphStyle:NSParagraphStyle? = attributedString.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange:&range) as? NSParagraphStyle
        
        if(paragraphStyle == nil) {
            return attributedString
        }
        
        var mutableParagraphStyle:NSMutableParagraphStyle = paragraphStyle?.mutableCopy() as NSMutableParagraphStyle
        mutableParagraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        var restyled:NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        restyled.addAttribute(NSParagraphStyleAttributeName, value: mutableParagraphStyle, range: NSMakeRange(0, restyled.length))
        
        return restyled
    }
    /*
    * 可扩展部分,不同的Link类型
    */
    func getRangesForLinks(text:NSAttributedString) -> NSArray
    {
        var rangesForLinks:NSMutableArray = NSMutableArray()
        //用户昵称
        if (self.linkDetectionType! & .UserHandle != nil) {
            rangesForLinks.addObjectsFromArray(self.getRangesForUserHandles(text.string))
        }
        //内容标签
        if (self.linkDetectionType! & .HashTag != nil) {
            rangesForLinks.addObjectsFromArray(self.getRangesForHashTags(text.string))
        }
        //链接地址
        if (self.linkDetectionType! & .URL != nil) {
            rangesForLinks.addObjectsFromArray(self.getRangesForURLs(text))
        }
        //电话号码
        if (self.linkDetectionType! & .PhoneNumber != nil) {
            rangesForLinks.addObjectsFromArray(self.getRangesForPhoneNumbers(text.string))
        }
        //......
        return rangesForLinks
    }
    /*
    * 所有用户昵称
    */
    func getRangesForUserHandles(text:NSString) -> NSArray
    {
        var rangesForUserHandles:NSMutableArray = NSMutableArray()
        var regex:NSRegularExpression = NSRegularExpression(pattern : "(?<!\\w)@([\\w\\_]+)?", options: nil, error: nil)!
        var matches:NSArray = regex.matchesInString(text, options: nil, range: NSMakeRange(0, text.length))
        for match in matches {
            var matchRange = match.range
            var matchString:NSString = text.substringWithRange(matchRange)
            
            var dictionary:Dictionary<String, AnyObject> = [
                "linkType" : NSNumber(unsignedLong: KZLinkType.UserHandle.rawValue),
                "range"    : NSValue(range : matchRange),
                "link"     : matchString
            ];
            rangesForUserHandles.addObject(dictionary)
        }
        return rangesForUserHandles
    }
    /*
    * 所有内容标签
    */
    func getRangesForHashTags(text:NSString) -> NSArray
    {
        var rangesForHashTags:NSMutableArray = NSMutableArray()
        var regex:NSRegularExpression = NSRegularExpression(pattern : "(?<!\\w)#([\\w\\_]+)?", options: nil, error: nil)!
        var matches:NSArray = regex.matchesInString(text, options: nil, range: NSMakeRange(0, text.length))
        for match in matches {
            var matchRange = match.range
            var matchString:NSString = text.substringWithRange(matchRange)
            
            var dictionary:Dictionary<String, AnyObject> = [
                "linkType" : NSNumber(unsignedLong: KZLinkType.HashTag.rawValue),
                "range"    : NSValue(range: matchRange),
                "link"     : matchString
            ];
            rangesForHashTags.addObject(dictionary)
        }
        return rangesForHashTags
    }
    /*
    * 所有链接地址
    */
    func getRangesForURLs(text:NSAttributedString) -> NSArray
    {
        var rangesForURLs:NSMutableArray = NSMutableArray()
        var detector:NSDataDetector? = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: nil)
        
        var plainText:NSString = text.string
        var matchs:NSArray = detector!.matchesInString(plainText, options: nil, range: NSMakeRange(0, text.length))
        
        for match in matchs {
            var matchRange:NSRange = match.range
            var realURL:NSString? = text.attribute(NSLinkAttributeName, atIndex: 0, effectiveRange: nil) as NSString?
            if realURL == nil {
                realURL = plainText.substringWithRange(matchRange)
            }
            if (match.resultType == NSTextCheckingType.Link) {
                
                var dictionary:Dictionary<String, AnyObject> = [
                    "linkType" : NSNumber(unsignedLong: KZLinkType.URL.rawValue),
                    "range"    : NSValue(range : matchRange),
                    "link"     : realURL!
                ];
                rangesForURLs.addObject(dictionary)
            }
        }
        return rangesForURLs
    }
    /*
    * 所有电话号码
    */
    func getRangesForPhoneNumbers(text:NSString) -> NSArray
    {
        var rangesForPhoneNumbers:NSMutableArray = NSMutableArray()
        var detector:NSDataDetector? = NSDataDetector(types: NSTextCheckingType.PhoneNumber.rawValue, error: nil)
        
        var matchs:NSArray = detector!.matchesInString(text, options: nil, range: NSMakeRange(0, text.length))
        
        for match in matchs {
            var matchRange:NSRange = match.range
            var matchString:NSString = text.substringWithRange(matchRange)
            
            var dictionary:Dictionary<String, AnyObject> = [
                "linkType" : NSNumber(unsignedLong: KZLinkType.PhoneNumber.rawValue),
                "range"    : NSValue(range : matchRange),
                "link"     : matchString
            ];
            rangesForPhoneNumbers.addObject(dictionary)
        }
        return rangesForPhoneNumbers
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*
    * 绘制文本相关方法
    */
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var savedTextContainerSize:CGSize = self.textContainer.size
        var savedTextContainerNumberOfLines:Int = self.textContainer.maximumNumberOfLines
        
        self.textContainer.size = bounds.size
        self.textContainer.maximumNumberOfLines = numberOfLines
        
        var textBounds:CGRect = CGRectZero
        SwiftTryCatch.try({ () -> Void in
            var glyphRange:NSRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
            textBounds = self.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: self.textContainer)
            textBounds.origin = bounds.origin
            textBounds.size.width = CGFloat(ceilf(Float(textBounds.size.width)))
            textBounds.size.height = CGFloat(ceilf(Float(textBounds.size.height)))
            }, catch: { (error) -> Void in
            //handle error
            }, finally: { () -> Void in
            //close resources
            self.textContainer.size = savedTextContainerSize
            self.textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines
        })
        return textBounds
    }
    override func drawTextInRect(rect: CGRect) {
        var textOffset:CGPoint
        var glyphRange:NSRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
        textOffset = self.calcTextOffsetForGlyphRange(glyphRange)
        
        self.layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: textOffset)
        self.layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: textOffset)
    }
    func calcTextOffsetForGlyphRange(glyphRange:NSRange) -> CGPoint
    {
        var textOffset:CGPoint = CGPointZero
        var textBounds:CGRect = self.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: self.textContainer)
        var paddingHeight:CGFloat = (self.bounds.size.height - textBounds.size.height) / 2.0
        if (paddingHeight > 0) {
            textOffset.y = paddingHeight
        }
        return textOffset
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func layoutManager(layoutManager: NSLayoutManager, shouldBreakLineByWordBeforeCharacterAtIndex charIndex: Int) -> Bool
    {
        for dictionary in linkRanges as [Dictionary<String, AnyObject>] {
            var rangeValue:NSValue = dictionary["range"] as NSValue
            var range:NSRange = rangeValue.rangeValue
            var linkTypeNum:NSNumber = dictionary["linkType"] as NSNumber
            //有可能初始化不了
            var linkType:KZLinkType = KZLinkType(rawValue: linkTypeNum.unsignedLongValue)!
            if (linkType == .URL) {
                if ((charIndex > range.location) && charIndex <= (range.location + range.length)) {
                    return false
                }
            }
        }
        return true
    }
    func longPressLabel(recognizer:UILongPressGestureRecognizer)
    {
        if (recognizer.view != self || (recognizer.state != UIGestureRecognizerState.Began)) {
            return
        }
        var location:CGPoint = recognizer.locationInView(self)
        var touchedLink:Dictionary<String, AnyObject>? = self.getLinkAtLocation(location)
        
        if (touchedLink != nil) {
            //range
            var rangeValue:NSValue = touchedLink!["range"] as NSValue
            var range:NSRange = rangeValue.rangeValue
            //link string
            var touchedSubstring:NSString = touchedLink!["link"] as NSString
            //link type
            var linkTypeNum:NSNumber = touchedLink!["linkType"] as NSNumber
            var linkType:KZLinkType = KZLinkType(rawValue: linkTypeNum.unsignedLongValue)!
            self.linkLongPressHandle!(linkType: linkType,string:touchedSubstring,range:range)
        } else {
            return
        }
    }
    
    /*
    * 触摸事件
    */
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.isTouchMoved = false
        var touchLocation:CGPoint = touches.anyObject()!.locationInView(self)
        var touchedLink:Dictionary<String, AnyObject>? = self.getLinkAtLocation(touchLocation)
        if (touchedLink != nil) {
            var rangeValue:NSValue = touchedLink!["range"] as NSValue
            var range:NSRange = rangeValue.rangeValue
            self.selectedRange = range
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        self.isTouchMoved = true
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if (self.isTouchMoved!) {
            self.selectedRange = NSMakeRange(0, 0)
            return
        }
        var touchLocation:CGPoint = touches.anyObject()!.locationInView(self)
        var touchedLink:Dictionary<String, AnyObject>? = self.getLinkAtLocation(touchLocation)
        
        if (touchedLink != nil) {
            //range
            var rangeValue:NSValue = touchedLink!["range"] as NSValue
            var range:NSRange = rangeValue.rangeValue
            //link string
            var touchedSubstring:NSString = touchedLink!["link"] as NSString
            //link type
            var linkTypeNum:NSNumber = touchedLink!["linkType"] as NSNumber
            var linkType:KZLinkType = KZLinkType(rawValue: linkTypeNum.unsignedLongValue)!
            self.linkTapHandler!(linkType: linkType,string:touchedSubstring,range:range)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
        self.selectedRange = NSMakeRange(0, 0)
    }
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        self.selectedRange = NSMakeRange(0, 0)
    }
}
