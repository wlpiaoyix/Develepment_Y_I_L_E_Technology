//
//  PlaylistSearchTableViewCell.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BalancerView.h"
@protocol PlaylistSearchViewCellDelegate <NSObject>

- (void)addButtonAction:(NSIndexPath *)aIndexPath;

@end

@interface PlaylistSearchViewCell : UITableViewCell

@property (strong, nonatomic) id<PlaylistSearchViewCellDelegate> delegate;
@property (copy, nonatomic) NSIndexPath *aIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNameLabel;
@property (weak, nonatomic) IBOutlet BalancerView *balancerView;

- (IBAction)addButtonAction:(id)sender;

@end
