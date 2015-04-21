//
//  MyLabel.m
//  Duorey
//
//  Created by ice on 14/12/9.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "TapActionLabel.h"
#import <objc/message.h>
//#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
//#define msgTarget(target) (__bridge void *)(target)
@interface TapActionLabel ()
{

}
@property (nonatomic,copy) UIColor *oldColor;
@end

@implementation TapActionLabel

-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    self.oldColor = self.textColor;
    self.tapColor = [UIColor colorWithRed:142.0f/255.0f green:186.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.tapColor) {
        self.textColor = self.tapColor;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.oldColor) {
        self.textColor = self.oldColor;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.oldColor) {
        self.textColor = self.oldColor;
    }
    if (_tapTarget && _tapAction){
        @try {
            objc_msgSend(_tapTarget, _tapAction);
        }
        @catch (NSException *exception) {
            
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
