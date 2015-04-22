#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


/** 
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

extern NSString * const kReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    NotReachable = 0,
    ReachableViaWiFi = 2,
    ReachableViaWWAN = 1
};

@class Reachability;

typedef void (^NetworkReachable)(Reachability * reachability);
typedef void (^NetworkUnreachable)(Reachability * reachability);

@interface Reachability : NSObject

@property (nonatomic, copy) NetworkReachable    reachableBlock;
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;

@property (nonatomic, assign) BOOL reachableOnWWAN;

/**
 *  根据域名来判断网络状态
 *
 *  @param hostname 域名
 *
 *  @return Reachability
 */
+ (Reachability*)reachabilityWithHostname:(NSString*)hostname;

// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+ (Reachability*)reachabilityWithHostName:(NSString*)hostname;

/**
 *  判断网络状态
 *
 *  @return Reachability
 */
+ (Reachability*)reachabilityForInternetConnection;

/**
 *  根据ip地址判断网络状态
 *
 *  @param hostAddress ip地址
 *
 *  @return Reachability
 */
+ (Reachability*)reachabilityWithAddress:(void *)hostAddress;

/**
 *  判断Wifi是否连接
 *
 *  @return Reachability
 */
+ (Reachability*)reachabilityForLocalWiFi;

/**
 *  初始化
 *
 *  @param ref SCNetworkReachabilityRef
 *
 *  @return Reachability
 */
- (Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

/**
 *  开始监听
 *
 *  @return 判断成功与否
 */
- (BOOL)startNotifier;

/**
 *  停止监听
 */
- (void)stopNotifier;

/**
 *  网络连接是否正常
 *
 *  @return 连接是否成功
 */
- (BOOL)isReachable;

/**
 *  WWAN连接是否正常
 *
 *  @return 连接是否成功
 */
- (BOOL)isReachableViaWWAN;

/**
 *  Wifi连接是否正常
 *
 *  @return 连接是否成功
 */
- (BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired; // Identical DDG variant.
- (BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand;
// Is user intervention required?
- (BOOL)isInterventionRequired;

- (NetworkStatus)currentReachabilityStatus;
- (SCNetworkReachabilityFlags)reachabilityFlags;
- (NSString*)currentReachabilityString;
- (NSString*)currentReachabilityFlags;

@end
