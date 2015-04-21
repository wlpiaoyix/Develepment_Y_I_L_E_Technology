//
//  ImportSongObj.h
//  Duorey
//
//  Created by lixu on 14/12/18.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import "PTEnum.h"
#import "MTLModel+DNullableScalar.h"

@interface ImportSongObj : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *sid;
@property (copy, nonatomic) NSString *trackName;
@property (copy, nonatomic) NSString *trackId;
@property (strong, nonatomic) NSURL *trackURL;
@property (copy, nonatomic) NSString *genreName;
@property (assign, nonatomic) MusicSource source;
@property (assign, nonatomic) MediaSource type;
@property (strong, nonatomic) NSNumber *trackTime;
@property (copy, nonatomic) NSString *albumName;
@property (copy, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSURL *artworkUrlMini;
@property (strong, nonatomic) NSURL *artworkUrlNormal;
@property (strong, nonatomic) NSURL *artworkUrlBigger;
@property (copy, nonatomic) NSString *pubYear;
@property (strong, nonatomic) NSNumber *createrId;
@property (copy, nonatomic) NSString *musicLang;
@property (nonatomic, copy) NSString *ower;  //拥有者

@end
