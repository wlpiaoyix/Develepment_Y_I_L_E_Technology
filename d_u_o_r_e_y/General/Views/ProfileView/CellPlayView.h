//
//  CellPlayView.h
//  ViewDemo
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Music.h"
#import "PTConstant.h"
#import "PTUtilities.h"
#import "YLAudioPlayer.h"
#import "ProfilePlayCell.h"

@interface CellPlayView : UIView

@property (strong, nonatomic) Music *music;
@property (assign, nonatomic) ProfilePlayCell *playCell;

@end
