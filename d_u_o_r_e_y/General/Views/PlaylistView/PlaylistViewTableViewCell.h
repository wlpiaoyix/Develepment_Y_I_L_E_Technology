//
//  PlaylistViewTableViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface PlaylistViewTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mainIamgeView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
