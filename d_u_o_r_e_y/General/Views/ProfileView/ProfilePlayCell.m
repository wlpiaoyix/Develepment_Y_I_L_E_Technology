//
//  ProfilePlayCell.m
//  Duorey
//
//  Created by xdy on 14/11/22.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "ProfilePlayCell.h"
#import "PTDefinitions.h"
#import "Music.h"
#import "CellPlayView.h"

@interface ProfilePlayCell()

@property (weak, nonatomic) IBOutlet CellPlayView *firstView;
@property (weak, nonatomic) IBOutlet CellPlayView *secondView;
@property (weak, nonatomic) IBOutlet CellPlayView *thirdView;
@property (weak, nonatomic) IBOutlet CellPlayView *fourView;
@property (weak, nonatomic) IBOutlet UIView *moreView;

@end

@implementation ProfilePlayCell

@synthesize musics = _musics;

+ (NSString *)xibName{
    return NSStringFromClass(self.class);
}

+ (NSString *)reuseIdentifier
{
    return [NSString stringWithFormat:@"%@Identifier",NSStringFromClass(self.class)];
}

+ (CGFloat)cellHeight
{
    return 135.0;
}

- (void)awakeFromNib {
    // Initialization code
    self.playCellTitleLabel.text = @"";
    self.playCellDetailLabel.text = PTNSLocalizedString(@"MoreButtonMsgKey", nil);
    self.noPlayedInfoLabel.text = PTNSLocalizedString(@"NoPlayedInfoMsgKey", nil);
    self.firstView.hidden = YES;
    self.secondView.hidden = YES;
    self.thirdView.hidden = YES;
    self.fourView.hidden = YES;
    self.noPlayedInfoLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellType:(ProfilePlayCellType)cellType{
    _cellType = cellType;
    switch (cellType) {
        case ProfilePlayCellTypeRecent:
            self.playCellTitleLabel.text = PTNSLocalizedString(@"RecentPlayedButtonMsgKey", nil);
            break;
        default:
            self.playCellTitleLabel.text = PTNSLocalizedString(@"MostPlayedThisWeekButtonMsgKey", nil);
            break;
    }
}

- (void)setMusics:(NSArray *)musics{
    _musics = musics;
    if (!musics || [musics count] == 0) {
        self.noPlayedInfoLabel.hidden = NO;
        return;
    }
    else
    {
        self.noPlayedInfoLabel.hidden = YES;
    }
    
    if ([_musics count]<=4) {
        self.playCellDetailLabel.hidden = YES;
        self.smallArrowsImageView.hidden = YES;
    }else{
        self.playCellDetailLabel.hidden = NO;
        self.smallArrowsImageView.hidden = NO;
        UITapGestureRecognizer *showMoreGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMoreMusic)];
        [self.moreView addGestureRecognizer:showMoreGR];
    }
    
    for (int i=0; i<[_musics count]; i++) {
        if (i>3) {
            return;
        }
        
        if (i==0) {
            [self.firstView setMusic:_musics[i]];
            self.firstView.playCell = self;
        }else if (i==1){
            [self.secondView setMusic:_musics[i]];
            self.firstView.playCell = self;

        }else if (i==2){
            [self.thirdView setMusic:_musics[i]];
            self.firstView.playCell = self;

        }else if (i==3){
            [self.fourView setMusic:_musics[i]];
            self.firstView.playCell = self;

        }
    }
}

#pragma mark - Action

- (void)showMoreMusic{
    if ([self.delegate respondsToSelector:@selector(profilePlayCell:didShowMore:)]) {
        [self.delegate profilePlayCell:self didShowMore:self.cellType];
    }
}

@end
