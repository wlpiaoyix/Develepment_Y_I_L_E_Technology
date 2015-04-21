//
//  PlaylistInfoTableViewController.h
//  Duorey
//
//  Created by lixu on 14/11/25.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistObj.h"

@interface PlaylistInfoTableViewController : UITableViewController

@property (copy, nonatomic) NSString *listId;
@property (copy, nonatomic) PlaylistObj *playlistObj;

@end
