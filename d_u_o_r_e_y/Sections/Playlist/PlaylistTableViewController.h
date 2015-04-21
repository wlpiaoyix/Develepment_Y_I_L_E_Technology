//
//  PlaylistTableViewController.h
//  Duorey
//
//  Created by lixu on 14/11/17.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface PlaylistTableViewController : UITableViewController<SWTableViewCellDelegate>

- (IBAction)addButtonAction:(id)sender;
- (IBAction)playButtonAction:(id)sender;
- (void)reloadPlaylistData;
@end
