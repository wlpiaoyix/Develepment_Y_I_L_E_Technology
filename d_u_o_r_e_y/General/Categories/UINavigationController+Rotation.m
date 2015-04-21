//
//  UINavigationController+Rotation.m
//  PhonTunes
//
//  Created by PhonTunes on 14-6-24.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "UINavigationController+Rotation.h"

@implementation UINavigationController (Rotation)

-(BOOL)shouldAutorotate
{
    
//    return UIInterfaceOrientationMaskPortrait;
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
//    return UIInterfaceOrientationMaskPortrait;
    return 1;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
//    return UIInterfaceOrientationPortrait;
    return 1;
}

@end
