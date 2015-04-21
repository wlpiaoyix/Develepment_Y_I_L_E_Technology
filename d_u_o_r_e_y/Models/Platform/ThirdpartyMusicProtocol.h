//
//  ThirdpartyMusicProtocol.h
//  Duorey
//
//  Created by xdy on 15/3/12.
//  Copyright (c) 2015年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTEnum.h"
#import "Music.h"

@protocol ThirdpartyMusicProtocol <NSObject>

@required
- (NSString *)songName; //歌名
- (NSString *)meid; //第三方源中的id号
- (NSString *)style; //曲风
- (NSNumber *)timeLength; //时长
- (NSString *)album; //所属专辑
- (NSURL *)iconBigURL;  //专辑大图
- (NSURL *)iconSmallURL; //专辑小图
- (NSURL *)iconNormalURL; //专辑正常图
- (NSURL *)songUrl; //第三方源的url地址
- (NSString *)pubYear; //发布时间
- (NSString *)singer; // 演唱者
- (NSString *)musicLang; //语言
- (NSString *)purchaseUrl;//购买链接
- (NSString *)price;

- (MusicSource) source; //第三方源code即eid
- (MediaSource) type; //类型M(music) V (video)
- (NSString *)typeString;

- (NSDictionary *)duoreySystemMusicDictionary;
- (Music *)duoreyMusicModel;

@end
