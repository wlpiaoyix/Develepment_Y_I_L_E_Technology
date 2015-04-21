//
//  CellPlaylistView.h
//  Duorey
//
//  Created by xdy on 14/11/26.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTConstant.h"
#import "PTUtilities.h"
#import "PlaylistObj.h"

@interface CellPlaylistView : UIView

- (void)addTouchUpInsideTarget:(id)target action:(SEL)action;

@property (strong, nonatomic) PlaylistObj *playlist;
@end
