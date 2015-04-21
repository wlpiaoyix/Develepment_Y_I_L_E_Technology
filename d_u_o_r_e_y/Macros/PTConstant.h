//
//  PTConstant.h
//  PhonTunes
//
//  Created by xdy on 14-1-9.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#ifndef PhonTunes_PTConstant_h
#define PhonTunes_PTConstant_h

/**
 *  sdk key & secret
 */

//google analytics
//UA-57348052-1
static NSString * const GoogleAnalytics_Tracking_ID = @"UA-56758245-2";

//Flurry API key
static NSString * const FLURRY_API_KEY    = @"K83FKXMHD43JVC8N9R5M";

//Parse
static NSString * const PARSE_APPLICATION_ID_KEY = @"4KoIWbJMuCS3PFOBznXrTXA7935yxmq0R8JrAIJ0";
static NSString * const PARSE_CLIENT_KEY = @"s5eDkm4K0FnsoFat6cbEVN0JlWK62KwQtSqlU57C";

//twitter
static NSString * const TWITTER_CONSUMER_KEY = @"DuUuoyL7prcEkwt9piShhgLij";
static NSString * const TWITTER_CONSUMER_SECRET = @"KYZ9t2imqLNwBtmzngJzwtZ08LVM7v1BlFHm2GvSp5vbOCPz0k";

//my app info
//com.yile.Duorey
static NSString * const PHONTUNES_BUNDLE_ID = @"com.yile.duorey";
static NSString * const PHONTUNES_APPLE_ID = @"953384726";
static NSInteger const PHONTUNES_APPRATE_LIMITCOUNT = 1;
static NSInteger const PHONTUNES_APPRATE_LIMITDAY = 3;
static NSString * const PHONTUNES_EMAIL = @"support@duorey.com";


/**
 *  string constant
 */
static NSString * const UNKNOWN_STRING	  = @"unknown";

static NSString * const SHOW_SPLASH_CURRENTVERSION_KEY = @"showIntroViewCurrentVersion";
static NSString * const APP_ITUNES_DOWNLOAD_URL_KEY = @"https://itunes.apple.com/app/id953384726?mt=8";

//Notification string
static NSString * const DuoreyDidLoginNotification = @"com.duorey.didLogin.notification";
//static NSString * const MusicPlayCellPlayViewStartingNotification = @"com.duorey.music.cellpalyview.playing.notification";
//static NSString * const MusicPlayCellRecentPlayViewStopNotification = @"com.duorey.music.cellrecentpalyview.stop.notification";
//
//static NSString * const MusicPlayCellRecentPlayViewStartingNotification = @"com.duorey.music.cellrecentpalyview.start.notification";
//static NSString * const MusicPlayCellWeekPlayViewStartingNotification = @"com.duorey.music.cellweekpalyview.start.notification";

//static NSString * const MusicPlayCellWeekPlayViewStopNotification = @"com.duorey.music.cellweekpalyview.stop.notification";

static NSString * const PlaylistLastMusicPlayed = @"com.duorey.music.playlistlastmusic.stop.notification";


//
static NSString * const NO_WIFI_PLAY_SETTING = @"kNoWifiPlaySetting";
static NSString * const NoWifiPlaySettingCancel = @"kNoWifiPlaySettingCancel";
static NSString * const ForcePausePlayer = @"kForcePausePlayer";

//for balancer view animation
static NSString * const START_BALANCER_ANIMATION = @"start_balancer_animation";
static NSString * const STOP_BALANCER_ANIMATION = @"stop_balancer_animation";

//set itunes play start
static NSString * const STOP_ITUNES_PLAY_ALL_START = @"com.duorey.music.itunes.play.all";
static NSString * const STOP_PLAYLIST_PLAY_ALL_START = @"com.duorey.music.playlist.play.all";

#endif
