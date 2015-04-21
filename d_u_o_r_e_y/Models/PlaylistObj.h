//
//  PlaylistObj.h
//  Duorey
//
//  Created by lixu on 14/11/19.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel+DNullableScalar.h"

@interface PlaylistObj : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *comments;//描述
@property (nonatomic, copy) NSNumber *creater; //创建者
@property (nonatomic, copy) NSNumber *likeNum; //喜欢的人数
@property (nonatomic, copy) NSNumber *favouriteNum; //最喜欢的人数
@property (nonatomic, copy) NSNumber *flowNum; //关注人数
@property (nonatomic, copy) NSNumber *listId; //歌单ID
@property (nonatomic, copy) NSString *listAttr; //歌单属性
@property (nonatomic, copy) NSString *listIcon; //歌单icon
@property (nonatomic, copy) NSString *listName; //歌单名
@property (nonatomic, copy) NSString *listStyle; //歌单风格
@property (nonatomic, copy) NSString *listType; //歌单类型
@property (nonatomic, copy) NSNumber *totalNum; //歌的总数
@property (nonatomic, copy) NSNumber *modifyTime; //修改时间
@property (nonatomic, copy) NSNumber *listenNum; //听过的总数
@property (nonatomic, copy) NSNumber *playCountNum; //播放了多少次
@property (nonatomic, copy) NSNumber *extId;//第三方平台的歌单ID
@property (nonatomic, copy) NSNumber *category;

@end
