//
//  NSMutableArray+SWUtilityButtons.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "NSMutableArray+SWUtilityButtons.h"

@implementation SWUtilityButton

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"])
    {
        if ([[change objectForKey:@"new"] integerValue]) {
            if (self.highlitedBackgroudColor)
            {
                [self setBackgroundColor:self.highlitedBackgroudColor];
            }
        }
        else
        {
            if (self.normolBackgroudColor) {
                [self setBackgroundColor:self.normolBackgroudColor];
            }
            
        }
        
    }
    
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"highlighted"];
}

@end

@implementation NSMutableArray (SWUtilityButtons)

- (void)sw_addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title
{
    SWUtilityButton *button = [SWUtilityButton buttonWithType:UIButtonTypeCustom];
    button.normolBackgroudColor = color;
    button.backgroundColor = color;
    button.highlitedBackgroudColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color attributedTitle:(NSAttributedString *)title
{
    SWUtilityButton *button = [SWUtilityButton buttonWithType:UIButtonTypeCustom];
    button.normolBackgroudColor = color;
    button.backgroundColor = color;
    button.highlitedBackgroudColor = color;
    [button setAttributedTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon
{
    SWUtilityButton *button = [SWUtilityButton buttonWithType:UIButtonTypeCustom];
    button.normolBackgroudColor = color;
    button.backgroundColor = color;
    button.highlitedBackgroudColor = color;
    [button setImage:icon forState:UIControlStateNormal];
    [self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color normalIcon:(UIImage *)normalIcon selectedIcon:(UIImage *)selectedIcon {
    SWUtilityButton *button = [SWUtilityButton buttonWithType:UIButtonTypeCustom];
    button.normolBackgroudColor = color;
    button.backgroundColor = color;
    button.highlitedBackgroudColor = color;
    [button setImage:normalIcon forState:UIControlStateNormal];
    [button setImage:selectedIcon forState:UIControlStateHighlighted];
    [button setImage:selectedIcon forState:UIControlStateSelected];
    [self addObject:button];
}

@end


@implementation NSArray (SWUtilityButtons)

- (BOOL)sw_isEqualToButtons:(NSArray *)buttons
{
    buttons = [buttons copy];
    if (!buttons || self.count != buttons.count) return NO;
    
    for (NSUInteger idx = 0; idx < self.count; idx++) {
        id buttonA = self[idx];
        id buttonB = buttons[idx];
        if (![buttonA isKindOfClass:[SWUtilityButton class]] || ![buttonB isKindOfClass:[SWUtilityButton class]]) return NO;
        if (![[self class] sw_button:buttonA isEqualToButton:buttonB]) return NO;
    }
    
    return YES;
}

+ (BOOL)sw_button:(SWUtilityButton *)buttonA isEqualToButton:(SWUtilityButton *)buttonB
{
    if (!buttonA || !buttonB) return NO;
    
    UIColor *normalBackgroundColorA = buttonA.normolBackgroudColor;
    UIColor *normalBackgroundColorB = buttonB.normolBackgroudColor;
    BOOL haveEqualNormalBackgroundColors = (!normalBackgroundColorA && !normalBackgroundColorB) || [normalBackgroundColorA isEqual:normalBackgroundColorB];
    
    UIColor *highlitedBackgroundColorA = buttonA.highlitedBackgroudColor;
    UIColor *highlitedBackgroundColorB = buttonB.highlitedBackgroudColor;
    BOOL haveEqualHighlitedBackgroundColors = (!highlitedBackgroundColorA && !highlitedBackgroundColorB) || [highlitedBackgroundColorA isEqual:highlitedBackgroundColorB];
    
    NSString *titleA = [buttonA titleForState:UIControlStateNormal];
    NSString *titleB = [buttonB titleForState:UIControlStateNormal];
    BOOL haveEqualTitles = (!titleA && !titleB) || [titleA isEqualToString:titleB];
    
    UIImage *normalIconA = [buttonA imageForState:UIControlStateNormal];
    UIImage *normalIconB = [buttonB imageForState:UIControlStateNormal];
    BOOL haveEqualNormalIcons = (!normalIconA && !normalIconB) || [normalIconA isEqual:normalIconB];
    
    UIImage *selectedIconA = [buttonA imageForState:UIControlStateSelected];
    UIImage *selectedIconB = [buttonB imageForState:UIControlStateSelected];
    BOOL haveEqualSelectedIcons = (!selectedIconA && !selectedIconB) || [selectedIconA isEqual:selectedIconB];
    
    return haveEqualNormalBackgroundColors && haveEqualHighlitedBackgroundColors && haveEqualTitles && haveEqualNormalIcons && haveEqualSelectedIcons;
}

@end
