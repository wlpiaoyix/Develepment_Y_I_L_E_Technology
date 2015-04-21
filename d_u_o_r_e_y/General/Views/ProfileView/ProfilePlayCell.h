//
//  ProfilePlayCell.h
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, ProfilePlayCellType){
    ProfilePlayCellTypeRecent,
    ProfilePlayCellTypeWeekRecent
};

@class ProfilePlayCell;

@protocol ProfilePlayCellDelegate <NSObject>

- (void)profilePlayCell:(ProfilePlayCell *)cell didShowMore:(ProfilePlayCellType)type;

@end

@interface ProfilePlayCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *playCellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playCellDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *noPlayedInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallArrowsImageView;
@property (assign, nonatomic) ProfilePlayCellType cellType;
@property (strong, nonatomic) NSArray *musics;
@property (weak, nonatomic) id<ProfilePlayCellDelegate> delegate;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
