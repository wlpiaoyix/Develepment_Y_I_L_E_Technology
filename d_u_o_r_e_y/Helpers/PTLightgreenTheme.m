//
//  PTDefaultTheme.m
//  PhonTunes
//
//  Created by CoreXDY on 14-3-9.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "PTLightgreenTheme.h"

@implementation PTLightgreenTheme

- (UIColor *)whiteColor{
    return [UIColor whiteColor];
}
- (UIColor *)blackColor{
    return [UIColor blackColor];
}
- (UIColor *)grayColor{
    return [UIColor grayColor];
}

- (UIColor *)redColor{
    return [UIColor redColor];
}

- (UIColor *)greenColor{
    return [UIColor colorWithRed:0.259 green:0.780 blue:0.365 alpha:1.000];
}

- (UIColor *)navBarTintColor{
    return [self whiteColor];
}

- (UIColor *)navTintColor{
    return [self greenColor];
}

//tabbar背景颜色
- (UIColor *)tabBarTintColor{
    return [self blackColor];
}
//tabbar tint 颜色
- (UIColor *)tabTintColor{
    return [UIColor colorWithRed:0.000 green:0.780 blue:0.353 alpha:1.000];
}

- (UIColor *)progressTintColor{
    return [self greenColor];
}
- (UIColor *)progressTrackTintColor{
    return [self greenColor];
}

- (UIColor *)toolBarTintColor{
    return [self greenColor];
}

- (UIColor *)sliderTintColor{
    return [self greenColor];
}

- (UIColor *)shadowColor{
    return nil;
}

- (UIColor *)backgroundColor{
    return [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
}

- (UIColor *)badgeColor{
//    168,226,106
//    return UIColorFromHex(0xa8ea6a);
    return [self redColor];
}

- (UIColor *)accentTintColor{
    return nil;
}

- (UIColor *)switchThumbColor{
    return nil;
}
- (UIColor *)switchOnColor{
    return nil;
}
- (UIColor *)switchTintColor{
    return nil;
}

- (CGSize)shadowOffset{
    return CGSizeMake(0.0, 1.0);
}

- (UIImage *)topShadow{
    return [UIImage imageNamed:@"topShadow"];
}
- (UIImage *)bottomShadow{
    return nil;
}

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics{
    return [UIImage imageNamed:@"navBackground7"];
}

- (UIImage *)searchBackground{
    return [[UIImage imageNamed:@"searchBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0)];
}
- (UIImage *)searchFieldImage{
	return [[UIImage imageNamed:@"searchBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0)];
}
- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state{
    NSString *name;
//    if (icon == UISearchBarIconSearch) {
//        name = @"searchIconSearch";
//    } else if (icon == UISearchBarIconClear) {
//        name = @"searchIconClear";
//        if (state == UIControlStateHighlighted) {
//            name = [name stringByAppendingString:@"Highlighted"];
//        }
//    }
    return (name ? [UIImage imageNamed:name] : nil);
}
- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state{
    return nil;
}
- (UIImage *)searchScopeButtonDivider{
    return nil;
}

- (UIImage *)sliderMinTrack{
    UIImage *image = [UIImage imageNamed:@"sliderMinTrack"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)];
    return image;
}
- (UIImage *)sliderMaxTrack{
    UIImage *image = [UIImage imageNamed:@"sliderMaxTrack"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)];
    return image;
}

- (UIImage *)sliderThumbImageForState:(UIControlState)state{
    NSString *name = @"sliderThumbImage";
    if (state == UIControlStateHighlighted) {
        
    }else if (state == UIControlStateSelected){
        
    }else{
        name = @"sliderThumbImage";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

- (UIImage *)greenButtonBackgroundForState:(UIControlState)state{
	NSString *name = @"btnGreen";
//    if (state == UIControlStateHighlighted) {
//		name = [name stringByAppendingString:@"Highlighted"];
//    }else if(state == UIControlStateDisabled){
//
//    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)];
    return image;
}
- (UIImage *)redButtonBackgroundForState:(UIControlState)state{
	NSString *name = @"btnRed";
//    if (state == UIControlStateHighlighted) {
////		name = [name stringByAppendingString:@"Highlighted"];
//        name = [name stringByAppendingString:@"Disabled"];
//    }else if(state == UIControlStateDisabled){
//        name = [name stringByAppendingString:@"Disabled"];
//    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 3.0)];
    return image;
}

- (UIImage *)loginButtonBackgroundWithImage:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 50.0, 0.0, 10.0)];
    return image;
}

- (UIImage *)tableViewBackground{
    return nil;
}

- (UIImage *)tabBarBackground{
    return [UIImage imageNamed:@"tabBarBackground"];
}
- (UIImage *)tabBarSelectedIndicatorImage{
    return [UIImage imageNamed:@"tabBarSelectedBackground"];
}

- (NSDictionary *)navigationBarTitleTextAttributes{
    //    NSShadow *shadow = [[NSShadow alloc] init];//字体阴影
    //    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    //    shadow.shadowOffset = CGSizeMake(0, 1);
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self blackColor],NSForegroundColorAttributeName,
//            [UIColor clearColor],NSShadowAttributeName,
//            [NSValue valueWithCGSize:CGSizeMake(0, 0)],NSShadowAttributeName,
//            [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName,
            nil];
}

@end
