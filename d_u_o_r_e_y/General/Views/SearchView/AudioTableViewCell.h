//
//  AudioTableViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BalancerView.h"

@protocol AudioTableViewCellDelegate <NSObject>

- (void)addButtonAction:(NSIndexPath *)aIndexPath;

@end

@interface AudioTableViewCell : UITableViewCell

@property (strong, nonatomic) id<AudioTableViewCellDelegate> delegate;
@property (copy, nonatomic) NSIndexPath *aIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playImage;
@property (weak, nonatomic) IBOutlet BalancerView *balancerView;
- (IBAction)addButtonAction:(id)sender;

@end
