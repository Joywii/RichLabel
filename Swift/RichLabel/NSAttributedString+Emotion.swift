//
//  NSAttributedString+Emotion.swift
//  RichLabelDemo
//
//  Created by joywii on 14/12/25.
//  Copyright (c) 2014年 joywii. All rights reserved.
//

import Foundation

class KZTextAttachment : NSTextAttachment {
    var range:NSRange = NSMakeRange(0, 0)
    
    override init(data contentData: NSData?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRectMake(0, -5, 19, 20)
    }
}


extension NSAttributedString
{
    //-----------------------------------------------------实例方法-----------------------------------------------------
    /*
    * 返回绘制NSAttributedString所需要的区域
    */
    func boundsWithSize(size:CGSize) -> CGRect
    {
        // TODO:
        //NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading
        
        var contentRect:CGRect = self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin , context: nil)
        return contentRect
    }
    
    //-----------------------------------------------------静态方法-----------------------------------------------------
    /*
    * 返回表情数组
    */
    class func emojiStringArray() -> NSArray
    {
        var array:NSArray = ["[不服]","[亲亲]","[偷笑]","[加油]","[卖萌]","[吐了]","[大哭]","[大笑]","[好色]","[害羞]","[屌爆了]","[帅气]","[微笑]","[快哭了]","[惊恐]","[惊讶]","[愤怒]","[打死你]","[抓狂]","[抱抱]","[挖鼻孔]","[摸头]","[晕]","[求你了]","[求包养]","[流汗]","[淘气]","[猥琐]","[生气]","[白眼]","[给跪]","[鄙视]","[闭嘴]","[阴险]","[难过]"]
        return array
    }
    /*
    * 返回绘制文本需要的区域
    */
    class func boundsForString(string:NSString ,size:CGSize , attrs:NSDictionary) -> CGRect?
    {
        var attributedString:NSAttributedString = NSAttributedString.emotionAttributedStringFrom(string, attrs: attrs)
        
        // TODO:
        //NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading
        
        var contentRect:CGRect = attributedString.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return contentRect
    }
    /*
    * 返回Emotion替换过的 NSAttributedString
    */
    class func emotionAttributedStringFrom(string:NSString ,attrs:NSDictionary) -> NSAttributedString
    {
        var attributedEmotionString:NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: attrs)
        var attachmentArray:NSArray = NSAttributedString.attachmentsForAttributedString(attributedEmotionString)
        for attachment in attachmentArray {
            var emotionAttachmentString:NSAttributedString = NSAttributedString(attachment: attachment as NSTextAttachment)
            attributedEmotionString.replaceCharactersInRange(attachment.range, withAttributedString: emotionAttachmentString)
        }
        return attributedEmotionString
    }
    
    class private func attachmentsForAttributedString(attributedString:NSMutableAttributedString) -> NSArray
    {
        var markL:NSString = "["
        var markR:NSString = "]"
        var string:NSString = attributedString.string
        var array:NSMutableArray = NSMutableArray()
        var stack:NSMutableArray = NSMutableArray()
        
        for var i = 0; i < string.length; ++i {
            var s:NSString = string.substringWithRange(NSMakeRange(i, 1))
            if (s.isEqualToString(markL) || (stack.count > 0 && stack[0].isEqualToString(markL))) {
                if (s.isEqualToString(markL) && (stack.count > 0 && stack[0].isEqualToString(markL))) {
                    stack.removeAllObjects()
                }
                stack.addObject(s)
                if (s.isEqualToString(markR) || (i == string.length - 1)) {
                    var emojiStr:NSMutableString = NSMutableString()
                    for c in stack {
                        emojiStr.appendString(c as NSString)
                    }
                    if (NSAttributedString.emojiStringArray().containsObject(emojiStr)) {
                        var range:NSRange = NSMakeRange(i + 1 - emojiStr.length, emojiStr.length)
                        attributedString.replaceCharactersInRange(range, withString: " ")
                        var attachment:KZTextAttachment = KZTextAttachment(data: nil, ofType: nil)
                        attachment.range = NSMakeRange(i + 1 - emojiStr.length, 1)
                        attachment.image = UIImage(named: "\(emojiStr).png")
                        
                        i -= (stack.count - 1)
                        array.addObject(attachment)
                    }
                    stack.removeAllObjects()
                }
            }
            string = attributedString.string
        }
        return array
    }
}