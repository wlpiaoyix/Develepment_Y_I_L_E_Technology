//
//  AttributedLabel.m
//  AttributedStringTest
//
//  Created by sun huayu on 13-2-19.
//  Copyright (c) 2013年 sun huayu. All rights reserved.
//

#import "AttributedLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface AttributedLabel() {
    CATextLayer *textLayer;
}
@property (nonatomic,retain)NSMutableAttributedString *attributeText;
@end

@implementation AttributedLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (!textLayer) {
        textLayer = [CATextLayer layer];
        textLayer.string = _attributeText;
        textLayer.transform = CATransform3DMakeScale(0.5,0.5,1);
        textLayer.frame = CGRectMake(0, 6, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:textLayer];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (text == nil) {
        self.attributeText = nil;
    } else {
        self.attributeText = [[NSMutableAttributedString alloc] initWithString:text];
    }
}

- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length {
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    [_attributeText addAttribute:(NSString *)kCTForegroundColorAttributeName
                           value:(id)color.CGColor
                           range:NSMakeRange(location, length)];
}

- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length {
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    [_attributeText addAttribute:(NSString *)kCTFontAttributeName
                        value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName,
                                                       font.pointSize*2,
                                                       NULL))
                        range:NSMakeRange(location, length)];
}

- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length {
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    [_attributeText addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                           value:(id)[NSNumber numberWithInt:style]
                           range:NSMakeRange(location, length)];
}

@end
