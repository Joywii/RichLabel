//
//  NSAttributedString+Emotion.h
//  LinkTest
//
//  Created by joywii on 14/12/9.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KZTextAttachment : NSTextAttachment
@property (nonatomic,assign) NSRange  range;
@end

@interface NSAttributedString (Emotion)

//-----------------------------------------------------实例方法-----------------------------------------------------
/*
 * 返回绘制NSAttributedString所需要的区域
 */
- (CGRect)boundsWithSize:(CGSize)size;

//-----------------------------------------------------静态方法-----------------------------------------------------
/*
 * 返回表情数组
 */
+ (NSArray *)emojiStringArray;

/*
 * 返回绘制文本需要的区域
 */
+ (CGRect)boundsForString:(NSString *)string size:(CGSize)size attributes:(NSDictionary *)attrs;

/*
 * 返回Emotion替换过的 NSAttributedString
 */
+ (NSAttributedString *)emotionAttributedStringFrom:(NSString *)string attributes:(NSDictionary *)attrs;

@end
