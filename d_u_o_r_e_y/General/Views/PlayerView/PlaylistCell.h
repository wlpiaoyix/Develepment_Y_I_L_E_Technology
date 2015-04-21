//
//  PlaylistCell.h
//  Duorey
//
//  Created by xdy on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *listNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicDescLabel;

@end
