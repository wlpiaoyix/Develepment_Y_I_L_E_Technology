//
//  PlaylistObj.m
//  Duorey
//
//  Created by lixu on 14/11/19.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "PlaylistObj.h"

@implementation PlaylistObj

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"creater":@"creater",
             @"likeNum":@"ding_num",
             @"favouriteNum":@"fav_num",
             @"flowNum":@"flow_num",
             @"listId":@"lid",
             @"listAttr":@"list_attr",
             @"listIcon":@"list_ico",
             @"listName":@"list_name",
             @"listStyle":@"list_style",
             @"listType":@"list_type",
             @"listenNum":@"ting_num",
             @"modifyTime":@"modifytime",
             @"totalNum":@"num",
             @"comments":@"comments",
             @"playCountNum":@"ting_num",
             @"category":@"category",
             @"extId":@"ext_lid"
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end
