//
//  MyLabel.h
//  Duorey
//
//  Created by ice on 14/12/9.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TapActionLabel : UILabel
@property (nonatomic, strong) UIColor *tapColor;
@property (nonatomic, weak) id tapTarget;
@property (nonatomic, assign) SEL tapAction;
@end
