//
//  OneListObj.h
//  Duorey
//
//  Created by lixu on 14/11/19.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel+DNullableScalar.h"
#import "Music.h"

@interface OneListObj : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *songId; //歌曲ID
@property (nonatomic, copy) NSString *songName; //歌名
@property (nonatomic, copy) NSString *songUrl; //第三方源的url地址
@property (nonatomic, copy) NSString *meid; //第三方源中的id号
@property (nonatomic, copy) NSString *eid; //第三方源code即eid
@property (nonatomic, copy) NSString *sourceType; //类型M(music) V (video)
@property (nonatomic, copy) NSString *style; //曲风
@property (nonatomic, copy) NSNumber *timeLength; //时长
@property (nonatomic, copy) NSString *album; //所属专辑
@property (nonatomic, copy) NSString *iconBig;  //专辑大图
@property (nonatomic, copy) NSString *iconSamll; //专辑小图
@property (nonatomic, copy) NSString *iconNomal; //专辑正常图
@property (nonatomic, copy) NSString *pubYear; //发布时间
@property (nonatomic, copy) NSString *singer; // 演唱者
@property (nonatomic, copy) NSString *musicLang; //语言
@property (nonatomic, copy) NSNumber *creater; //创建者
@property (nonatomic, copy) NSNumber *ower;  //拥有者

@end
