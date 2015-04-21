//
//  ThirdpartyMusicBase.h
//  Duorey
//
//  Created by xdy on 15/3/13.
//  Copyright (c) 2015年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel+DNullableScalar.h"
#import "ThirdpartyMusicProtocol.h"
#import "PTUtilities.h"

@interface ThirdpartyMusicBase : MTLModel<ThirdpartyMusicProtocol>

@property (nonatomic, copy) NSString *songName; //歌名
@property (nonatomic, copy) NSString *meid; //第三方源中的id号
@property (nonatomic, copy) NSString *style; //曲风
@property (nonatomic, strong) NSNumber *timeLength; //时长
@property (nonatomic, copy) NSString *album; //所属专辑
@property (nonatomic, strong) NSURL *iconBigURL;  //专辑大图
@property (nonatomic, strong) NSURL *iconSmallURL; //专辑小图
@property (nonatomic, strong) NSURL *iconNormalURL; //专辑正常图
@property (nonatomic, strong) NSURL *songUrl; //第三方源的url地址
@property (nonatomic, copy) NSString *pubYear; //发布时间
@property (nonatomic, copy) NSString *singer; // 演唱者
@property (nonatomic, copy) NSString *musicLang; //语言
@property (nonatomic, copy) NSString *purchaseUrl;//购买链接
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, assign) MusicSource source; //第三方源code即eid
@property (nonatomic, assign) MediaSource type; //类型M(music) V (video)
@property (nonatomic, copy) NSString *typeString;

@end
