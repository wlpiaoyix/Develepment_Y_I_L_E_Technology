//
//  ActivityTableViewCell.h
//  Acticity
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityObj.h"
#import "NSDate+TimeAgo.h"
#import "UIImageView+PTSImageCache.h"

@protocol ActivityTableCellDelegate <NSObject>
@optional
-(void)activityCellPlaySong:(ActivityObj *)obj;
-(void)activityCellAddSong:(ActivityObj *)obj;
-(void)activityCellClickedUser:(UserAccount *)user;
-(void)activityCellClickPlayList:(PlaylistObj *)playList;
@end

@interface ActivityTableViewCell : UITableViewCell
-(void)loadCellData:(ActivityObj *)obj;
@property (nonatomic,weak) id <ActivityTableCellDelegate> cellDelegate;
@end
