//
//  PTDefinitions.h
//  PhonTunes
//
//  Created by xdy on 14-1-9.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#ifndef PhonTunes_PTDefinitions_h
#define PhonTunes_PTDefinitions_h

/**
 * AppDelegate
 */
#define PTAppDelegate ((PhonTunesAppDelegate *)[UIApplication sharedApplication].delegate)
#define PTAppDelegateID [UIApplication sharedApplication].delegate

//UserDefaults
#define DEFAULTS(type, key) ([[NSUserDefaults standardUserDefaults] type##ForKey:key])
#define SET_DEFAULTS(Type, key, val) do {\
[[NSUserDefaults standardUserDefaults] set##Type:val forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];\
} while (0)

//16进制颜色转换
#define UIColorFromHex(hexValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define PTNSLocalizedString(key,comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"PTLocalizable"]

#endif


