//
//  ActivityObj.h
//  Duorey
//
//  Created by ice on 14/11/27.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import "MTLModel+DNullableScalar.h"
#import "Music.h"
#import "PlaylistObj.h"
#import "UserAccount.h"

/*
 'play'=>1,          //听了歌曲
 'flow_user'=>2,     //关注某人
 'flow_list'=>3,     //关注某歌单
 'ding'=>4,          //赞某歌单
 'add'=>5,           //添加歌曲到歌单
 'del'=>6            //删除歌单中的某个歌
 */
typedef NS_ENUM(NSInteger, ActivityType)
{
    ActivityTypeListen = 1,//听歌曲
    ActivityTypeFollowSomebody,//关注某人
    ActivityTypeFollowPlayList,//关注某个歌单
    ActivityTypeCommentPlayList,//赞歌单
    ActivityTypeAddSongToPlayList,//添加到歌单
    ActivityTypeDeleteSongFromPlayList,//从歌单删除
};
@interface ActivityObj : MTLModel <MTLJSONSerializing>

@property (nonatomic,copy) NSString *activityType;//用户行为
@property (nonatomic,strong) Music *music;//歌曲对象
@property (nonatomic,strong) PlaylistObj *playList;//歌单对象
@property (nonatomic,strong) UserAccount *followUser;//跟随者
@property (nonatomic,strong) UserAccount *user;//动作对象
@property (nonatomic,copy) NSString *creatTime;//创建时间
@end
