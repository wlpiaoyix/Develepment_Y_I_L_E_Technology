//
//  ItunesTableViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BalancerView.h"
@protocol ItunesTableViewCellDelegate <NSObject>

- (void)moreButtonActionWithIndex:(int)aIndexPathRow;

@end

@interface ItunesTableViewCell : UITableViewCell

@property (strong, nonatomic) id<ItunesTableViewCellDelegate> delegate;
@property (nonatomic ) int aIndexPathRow;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNameLable;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
//@property (weak, nonatomic) IBOutlet UIImageView *playBuleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fromIconImageView;
@property (weak, nonatomic) IBOutlet BalancerView *balancerView;

- (IBAction)moreButtonAction:(id)sender;
@end
