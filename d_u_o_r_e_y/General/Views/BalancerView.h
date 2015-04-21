//
//  BalancerView.h
//  Test
//
//  Created by ice on 14/11/26.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTEnum.h"
#import "Music.h"
#import "PTConstant.h"
@interface BalancerView : UIView
@property (nonatomic,strong) UIColor *strokeColor;
+(BalancerView *)instanceView;
-(void)setSomething:(Music *)music;
@end
