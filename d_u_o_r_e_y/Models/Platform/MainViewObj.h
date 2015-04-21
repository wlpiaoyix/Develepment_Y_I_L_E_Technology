//
//  MainViewObj.h
//  Duorey
//
//  Created by lixu on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel+DNullableScalar.h"

@interface MainViewObj : MTLModel<MTLJSONSerializing>

@property (copy, nonatomic) NSNumber *listId;
@property (copy, nonatomic) NSString *listName;
@property (copy, nonatomic) NSNumber *listenCount;
@property (copy, nonatomic) NSString *listIcon;

@end
