//
//  ProfilePlayCell.h
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, ProfileWeekPlayCellType){
    ProfileWeekPlayCellTypeRecent,
    ProfileWeekPlayCellTypeWeekRecent
};

@class ProfileWeekPlayCell;

@protocol ProfileWeekPlayCellDelegate <NSObject>

- (void)profilePlayCell:(ProfileWeekPlayCell *)cell didShowMore:(ProfileWeekPlayCellType)type;

@end

@interface ProfileWeekPlayCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *playCellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playCellDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *noPlayedInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallArrowsImageView;
@property (assign, nonatomic) ProfileWeekPlayCellType cellType;
@property (strong, nonatomic) NSArray *musics;
@property (weak, nonatomic) id<ProfileWeekPlayCellDelegate> delegate;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
