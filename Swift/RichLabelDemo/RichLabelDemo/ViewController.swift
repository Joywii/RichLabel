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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var emojiString:NSString = "http://www.hao123.com[不服][给跪][不服]an example 15701669932哈哈哈哈哈哈哈 http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights/18746930#18746930[不服][给跪][不服][不服][给跪][不服][不服][给跪][不服][不服][给跪][不服][不服][给跪][不服]"
        
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
        
        kzLabel.linkColor = UIColor.blueColor()
        kzLabel.linkHightlightColor = UIColor.orangeColor()
        
        self.view.addSubview(kzLabel)
        
        kzLabel.linkTapHandler = { (linkType:KZLinkType, string:String, range:NSRange) -> () in
            
            if (linkType == KZLinkType.URL) {
                
            } else if (linkType == KZLinkType.PhoneNumber) {
                
            }
            NSLog("Link Tap Handler")
        }
        kzLabel.linkLongPressHandle = { (linkType:KZLinkType, string:String, range:NSRange) -> () in
            NSLog("Link Tap Handler")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

