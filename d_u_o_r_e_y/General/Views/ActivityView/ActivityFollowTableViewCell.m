//
//  ActivityFollowTableViewCell.m
//  Acticity
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import "ActivityFollowTableViewCell.h"
#import "PTUtilities.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TapActionLabel.h"
@interface ActivityFollowTableViewCell ()
@property (nonatomic,weak) IBOutlet UIImageView *userHeaderImageView;
@property (nonatomic,weak) IBOutlet TapActionLabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet TapActionLabel *followNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (nonatomic,strong) ActivityObj *activityObj;
@end

@implementation ActivityFollowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userHeaderImageView.layer.cornerRadius = self.userHeaderImageView.bounds.size.height/2.0f;
    self.userHeaderImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)loadCellData:(ActivityObj *)obj
{
    self.activityObj = obj;
    self.nameLabel.text = obj.user.nickname;
    self.followNameLabel.text = obj.followUser.nickname;

    self.nameLabel.tapTarget = self;
    self.nameLabel.tapAction = @selector(tapUserGesture);
    
    self.followNameLabel.tapTarget = self;
    self.followNameLabel.tapAction = @selector(tapFollowUserGesture);
    
    self.followingLabel.text = PTNSLocalizedString(@"FollowingMsgKey", nil);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:obj.creatTime];
    self.timeLabel.text = [date timeAgo];
    [self.userHeaderImageView sd_setImageWithURL:obj.user.userAvatarImageLargeURL placeholderImage:[UIImage imageNamed:@"cellAvatarImage"]];

}

-(void)tapUserGesture
{
    if (_followDelegate && [_followDelegate respondsToSelector:@selector(activityFollowTableViewCellSelectUser:)]) {
        [_followDelegate activityFollowTableViewCellSelectUser:self.activityObj];
    }
}

-(void)tapFollowUserGesture
{
    if (_followDelegate && [_followDelegate respondsToSelector:@selector(activityFollowTableViewCellSelectUser:)]) {
        [_followDelegate activityFollowTableViewCellSelectFollowUser:self.activityObj];
    }
}
@end
