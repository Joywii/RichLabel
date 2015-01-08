//
//  ViewController.m
//  KZRickLabelDemo
//
//  Created by joywii on 14/12/9.
//
//

#import "ViewController.h"
#import "KZLinkLabel.h"

#define kScreenHeight         [UIScreen mainScreen].bounds.size.height
#define kScreenWidth          [UIScreen mainScreen].bounds.size.width

@interface ViewController () <UIActionSheetDelegate>

@property (nonatomic,strong) NSDictionary *selectedLinkDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSString *emojiString = @"http://www.hao123.com[不服][给跪][不服]an example 15701669932哈哈哈哈哈哈哈 http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights/18746930#18746930[不服][给跪][不服][不服][给跪][不服][不服][给跪][不服][不服][给跪][不服][不服][给跪][不服]";
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    NSAttributedString *attributedString = [NSAttributedString emotionAttributedStringFrom:emojiString attributes:attributes];
    
    CGRect attributeRect = [attributedString boundsWithSize:CGSizeMake(kScreenWidth - 30,CGFLOAT_MAX)];
    
    KZLinkLabel *kzLabel = [[KZLinkLabel alloc] initWithFrame:CGRectMake(15, 40, kScreenWidth - 30, attributeRect.size.height)];
    kzLabel.automaticLinkDetectionEnabled = YES;
    kzLabel.font = [UIFont systemFontOfSize:16];
    kzLabel.backgroundColor = [UIColor clearColor];
    kzLabel.textColor = [UIColor blackColor];
    kzLabel.numberOfLines = 0;
    kzLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    kzLabel.attributedText = attributedString;
    
    [kzLabel sizeToFit];
    kzLabel.linkColor = [UIColor blueColor];
    kzLabel.linkHighlightColor = [UIColor orangeColor];
    
    [self.view addSubview:kzLabel];
    
    kzLabel.linkTapHandler = ^(KZLinkType linkType, NSString *string, NSRange range){
        if (linkType == KZLinkTypeURL) {
            [self openURL:[NSURL URLWithString:string]];
        } else if (linkType == KZLinkTypePhoneNumber) {
            [self openTel:string];
        } else {
            NSLog(@"Other Link");
        }
    };
    kzLabel.linkLongPressHandler = ^(KZLinkType linkType, NSString *string, NSRange range){
        NSMutableDictionary *linkDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        [linkDictionary setObject:@(linkType) forKey:@"linkType"];
        [linkDictionary setObject:string forKey:@"link"];
        [linkDictionary setObject:[NSValue valueWithRange:range] forKey:@"range"];
        self.selectedLinkDic = linkDictionary;
        
        NSString *openTypeString;
        if (linkType == KZLinkTypeURL) {
            openTypeString = @"在Safari中打开";
        } else if (linkType == KZLinkTypePhoneNumber) {
            openTypeString = @"直接拨打";
        }
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"拷贝",openTypeString, nil];
        [sheet showInView:self.view];
    };
}
- (BOOL)openURL:(NSURL *)url
{
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    } else {
        return NO;
    }
}
- (BOOL)openTel:(NSString *)tel
{
    NSString *telString = [NSString stringWithFormat:@"tel://%@",tel];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telString]];
}
#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.selectedLinkDic) {
        return;
    }
    switch (buttonIndex)
    {
        case 0:
        {
            [UIPasteboard generalPasteboard].string = self.selectedLinkDic[@"link"];
            break;
        }
        case 1:
        {
            KZLinkType linkType = [self.selectedLinkDic[@"linkType"] integerValue];
            if (linkType == KZLinkTypeURL) {
                NSURL *url = [NSURL URLWithString:self.selectedLinkDic[@"link"]];
                [self openURL:url];
            } else if (linkType == KZLinkTypePhoneNumber) {
                [self openTel:self.selectedLinkDic[@"link"]];
            }
            break;
        }
    }
}

@end
