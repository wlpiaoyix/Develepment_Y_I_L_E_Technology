//
//  OtherProfilePlayCell.h
//  Duorey
//
//  Created by xdy on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistObj.h"

@class OtherProfilePlaylistCell;

@protocol OtherProfilePlaylistCellDelegate <NSObject>

- (void)profilePlaylistCellShowMore:(OtherProfilePlaylistCell *)cell;
- (void)profilePlaylistCell:(OtherProfilePlaylistCell *)cell playlistDetail:(PlaylistObj *)playlist;
@end

@interface OtherProfilePlaylistCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playCellImageView;
@property (weak, nonatomic) IBOutlet UILabel *playCellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playCellDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallArrowsImageView;
@property (weak, nonatomic) IBOutlet UIView *feedTitleView;

@property (weak, nonatomic) id<OtherProfilePlaylistCellDelegate> delegate;


@property (strong, nonatomic) NSArray *feedPlaylists;

+ (NSString *)xibName;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
