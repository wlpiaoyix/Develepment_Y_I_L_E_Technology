//
//  User.m
//  Duorey
//
//  Created by xdy on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "UserAccount.h"

@implementation UserAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"userId":@"user_id",
             @"nickname":@"nick_name",
             @"email":@"user_email",
             @"userExtUserName":@"user_ext_name",
             @"userExtId":@"user_ext_id",
             @"userCoverURL":@"user_back_img",
             @"userAvatarImageURL":@"user_ico_n",
             @"userAvatarImageMiniURL":@"user_ico_s",
             @"userAvatarImageLargeURL":@"user_ico_b",
             @"userType":@"user_ext",
             @"sex":@"user_sex",
             @"interest":@"user_intersting",
             @"userSig":@"user_sig",
             @"loveStar":@"user_star",
             @"userToken":@"user_token",
             @"userFolowedCount":@"user_flowed",
             @"userFolowCount":@"user_flow"
             };
}

+ (NSValueTransformer *)userIdJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

+ (NSValueTransformer *)userCoverURLJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userAvatarImageURLJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userAvatarImageMiniURLJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userAvatarImageLargeURLJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)nicknameJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
}

+ (NSValueTransformer *)userSigJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
}

+ (NSValueTransformer *)userFolowedCountJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

+ (NSValueTransformer *)userFolowCountJSONTransformer{
    return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
}

+ (NSValueTransformer *)userTypeJSONTransformer{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"1":@(UserTypeSystem),
        @"2":@(UserTypeTwitter),
        @"3":@(UserTypeFacebook),
    }];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    
    return self;
}

@end
