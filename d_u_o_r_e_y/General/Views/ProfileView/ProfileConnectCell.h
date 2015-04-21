//
//  ProfileConnectCell.h
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileConnectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
