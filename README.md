RickLabel
=========
<img align="center" src="https://github.com/Joywii/RickLabel/blob/master/Image/richlabel.png" alt="ScreenShot" width="300">

###说明
RickLabel是UILabel的子类。支持显示表情、识别URL、电话号码等（可扩展），URL和电话号码可以`点击`可以`长按`。表情部分使用TextKit框架实现。识别URL、电话号码主要参考[KILabel](https://github.com/Krelborn/KILabel)。

###使用条件

* ARC
* iOS 7.0+

###如何使用

1. 下载KZRichLabel，把KZRichLabel.h和KZRichLabel.m文件添加到工程中。
2. 在需要的地方 `#import "MZTimerLabel.h"`。`(具体参考Demo)`

###TODO

1. Swift版本。
2. 替换系统自带的URL识别和电话号码识别，改成精准的正则表达式。

###参考链接

1. [KILabel](https://github.com/Krelborn/KILabel)
2. [CCHLinkTextView](https://github.com/choefele/CCHLinkTextView)
3. [STTweetLabel](https://github.com/SebastienThiebaud/STTweetLabel)
4. [NimbusAttributedLabel](https://github.com/jverkoey/nimbus/)

###License
This code is distributed under the terms and conditions of the [MIT license](LICENSE). 