//
//  ActivityFollowTableViewCell.h
//  Acticity
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityObj.h"
#import "NSDate+TimeAgo.h"
#import "UIImageView+PTSImageCache.h"
@protocol ActivityFollowTableViewCellDelegate <NSObject>
@optional
-(void)activityFollowTableViewCellSelectUser:(ActivityObj *)obj;
-(void)activityFollowTableViewCellSelectFollowUser:(ActivityObj *)obj;
@end
@interface ActivityFollowTableViewCell : UITableViewCell
@property (nonatomic,assign) id <ActivityFollowTableViewCellDelegate> followDelegate;
-(void)loadCellData:(ActivityObj *)obj;
@end
