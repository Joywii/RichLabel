//
//  ViewController.swift
//  RichLabelDemo
//
//  Created by joywii on 14/12/10.
//  Copyright (c) 2014年 joywii. All rights reserved.
//

import UIKit

let kScreenHeight = UIScreen.mainScreen().bounds.size.height
let kScreenWidth = UIScreen.mainScreen().bounds.size.width

class ViewController: UIViewController ,UIActionSheetDelegate {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var selectedLinkDic:Dictionary<String,AnyObject>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var emojiString:NSString = "http://www.hao123.com[不服][给跪][不服]an example 15701669932哈哈哈哈哈哈哈 http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights/18746930#18746930[不服][给跪][不服][不服][给跪][不服][不服][给跪][不服][不服][给跪][不服][不服][给跪][不服]" //
        
        var font:UIFont = UIFont.systemFontOfSize(16)
        var attributes:NSDictionary = [NSFontAttributeName: font]
        var attributedString:NSAttributedString = NSAttributedString.emotionAttributedStringFrom(emojiString, attrs: attributes)
        var attributeRect:CGRect = attributedString.boundsWithSize(CGSizeMake((kScreenWidth - 30), CGFloat.max))
        
        var kzLabel:KZLinkLabel = KZLinkLabel(frame: CGRectMake(15, 40, kScreenWidth - 30, attributeRect.size.height))
        kzLabel.automaticLinkDetectionEnabled = true
        kzLabel.font = UIFont.systemFontOfSize(17)
        kzLabel.backgroundColor = UIColor.clearColor()
        kzLabel.textColor = UIColor.blackColor()
        kzLabel.numberOfLines = 0
        kzLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        kzLabel.attributedText = attributedString
        
        kzLabel.sizeToFit()
        kzLabel.linkColor = UIColor.blueColor()
        kzLabel.linkHightlightColor = UIColor.orangeColor()
        
        self.view.addSubview(kzLabel)
        
        kzLabel.linkTapHandler = { (linkType:KZLinkType, string:String, range:NSRange) -> () in
            
            if (linkType == KZLinkType.URL) {
                self.openURL(NSURL(string:string)!)
            } else if (linkType == KZLinkType.PhoneNumber) {
                self.openTel(string)
            } else {
                NSLog("Other Link")
            }
        }
        kzLabel.linkLongPressHandle = { (linkType:KZLinkType, string:String, range:NSRange) -> () in
            var linkDictionary:Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            linkDictionary.updateValue(NSNumber(unsignedLong:linkType.rawValue), forKey: "linkType")
            linkDictionary.updateValue(string, forKey: "link")
            linkDictionary.updateValue(NSValue(range : range), forKey: "range")
            self.selectedLinkDic = linkDictionary
            
            var openTypeString:String = ""
            if (linkType == KZLinkType.URL) {
                openTypeString = "在Safari中打开"
            } else if(linkType == KZLinkType.PhoneNumber) {
                openTypeString = "直接拨打"
            }
            var sheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拷贝", openTypeString)
            sheet.showInView(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func openURL(url:NSURL) -> Bool
    {
        var safariCompatible:Bool = url.scheme == "https" ||  url.scheme == "http"
        if (safariCompatible && UIApplication.sharedApplication().canOpenURL(url)) {
            UIApplication.sharedApplication().openURL(url)
            return true
        } else {
            return false
        }
    }
    func openTel(tel:String) -> Bool
    {
        var telString:String = "tel://\(tel)"
        return UIApplication.sharedApplication().openURL(NSURL(string: telString)!)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (self.selectedLinkDic == nil) {
            return
        }
        switch buttonIndex {
        case 0:
            UIPasteboard.generalPasteboard().string = (self.selectedLinkDic!["link"] as String)
        case 1:
            var linkTypeValue:NSNumber = self.selectedLinkDic!["linkType"] as NSNumber
            var linkType:KZLinkType = KZLinkType(rawValue: linkTypeValue.unsignedLongValue)!
            var linkString:String = self.selectedLinkDic!["link"] as String
            if (linkType == KZLinkType.URL) {
                var url:NSURL = NSURL(string: linkString)!
                self.openURL(url)
            } else if (linkType == KZLinkType.PhoneNumber) {
                self.openTel(linkString)
            }
        default:
            break
        }
    }
}

