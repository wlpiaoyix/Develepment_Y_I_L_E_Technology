//
//  ClusterPrePermissions.h
//  ClusterPrePermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>

@interface ClusterPrePermissions : NSObject

/**
 * A general descriptor for the possible outcomes of a dialog.
 */
typedef NS_ENUM(NSInteger, ClusterDialogResult) {
    /// User was not given the chance to take action.
    /// This can happen if the permission was
    /// already granted, denied, or restricted.
    ClusterDialogResultNoActionTaken,
    /// User declined access in the user dialog or system dialog.
    ClusterDialogResultDenied,
    /// User granted access in the user dialog or system dialog.
    ClusterDialogResultGranted,
    /// The iOS parental permissions prevented access.
    /// This outcome would only happen on the system dialog.
    ClusterDialogResultParentallyRestricted
};

/**
 * A general descriptor for the possible outcomes of Authorization Status.
 */
typedef NS_ENUM(NSInteger, ClusterAuthorizationStatus) {
    /// Permission status undetermined.
    ClusterAuthorizationStatusUnDetermined,
    /// Permission denied.
    ClusterAuthorizationStatusDenied,
    /// Permission authorized.
    ClusterAuthorizationStatusAuthorized,
    /// The iOS parental permissions prevented access.
    ClusterAuthorizationStatusRestricted
};

/**
 * Authorization methods for the usage of location services.
 */
typedef NS_ENUM(NSInteger, ClusterLocationAuthorizationType) {
    /// the “when-in-use” authorization grants the app to start most
    /// (but not all) location services while it is in the foreground.
    ClusterLocationAuthorizationTypeWhenInUse,
    /// the “always” authorization grants the app to start all
    /// location services
    ClusterLocationAuthorizationTypeAlways,
};

/**
 * Authorization methods for the usage of event services.
 */
typedef NS_ENUM(NSInteger, ClusterEventAuthorizationType) {
    /// Authorization for events only
    ClusterEventAuthorizationTypeEvent,
    /// Authorization for reminders only
    ClusterEventAuthorizationTypeReminder
};

/**
 * General callback for permissions. 
 * @param hasPermission Returns YES if system permission was granted 
 *                      or is already available, NO otherwise.
 * @param userDialogResult Describes whether the user granted/denied access, 
 *                         or if the user didn't have an opportunity to take action. 
 *                         ClusterDialogResultParentallyRestricted is never returned.
 * @param systemDialogResult Describes whether the user granted/denied access, 
 *                           or was parentally restricted, or if the user didn't 
 *                           have an opportunity to take action.
 * @see ClusterDialogResult
 */
typedef void (^ClusterPrePermissionCompletionHandler)(BOOL hasPermission,
                                              ClusterDialogResult userDialogResult,
                                              ClusterDialogResult systemDialogResult);

+ (instancetype) sharedPermissions;
/**
 *  返回Photo请求状态
 *
 *  @return Photo请求状态
 */
+ (ClusterAuthorizationStatus) photoPermissionAuthorizationStatus;

/**
 *  放回地址簿的请求状态
 *
 *  @return 地址簿请求状态
 */
+ (ClusterAuthorizationStatus) contactsPermissionAuthorizationStatus;

/**
 *  返回Event请求状态
 *
 *
 *  @return Event的请求状态
 */
+ (ClusterAuthorizationStatus) eventPermissionAuthorizationStatus:(ClusterEventAuthorizationType)eventType;

/**
 *  返回地理定位的请求状态
 *
 *  @return 地理定位的请求状态
 */
+ (ClusterAuthorizationStatus) locationPermissionAuthorizationStatus;

/**
 *  请求Photo的弹窗
 *
 *  @param requestTitle      标题
 *  @param message           描述
 *  @param denyButtonTitle   拒绝按钮的标题
 *  @param grantButtonTitle  允许按钮的标题
 *  @param completionHandler 完成请求的回调
 */
- (void) showPhotoPermissionsWithTitle:(NSString *)requestTitle
                               message:(NSString *)message
                       denyButtonTitle:(NSString *)denyButtonTitle
                      grantButtonTitle:(NSString *)grantButtonTitle
                     completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

/**
 *  请求地址簿的弹窗
 *
 *  @param requestTitle      标题
 *  @param message           描述
 *  @param denyButtonTitle   拒绝按钮的标题
 *  @param grantButtonTitle  允许按钮的标题
 *  @param completionHandler 完成请求的回调
 */
- (void) showContactsPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

/**
 *  请求Event的弹窗
 *
 *  @param eventType         Event状态
 *  @param requestTitle      标题
 *  @param message           描述
 *  @param denyButtonTitle   拒绝按钮的标题
 *  @param grantButtonTitle  请求按钮的标题
 *  @param completionHandler 完成请求的回调
 */
- (void) showEventPermissionsWithType:(ClusterEventAuthorizationType)eventType
                                Title:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

/**
 *  请求地理定位的弹窗
 *
 *  @param requestTitle      标题
 *  @param message           描述
 *  @param denyButtonTitle   拒绝按钮的标题
 *  @param grantButtonTitle  允许按钮的标题
 *  @param completionHandler 完成请求的回调
 */
- (void) showLocationPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

/**
 *  根据类型请求地理定位的谈装
 *
 *  @param authorizationType 请求类型
 *  @param requestTitle      标题
 *  @param message           描述
 *  @param denyButtonTitle   拒绝按钮的标题
 *  @param grantButtonTitle  允许按钮的标题
 *  @param completionHandler 完成请求的标题
 */
- (void) showLocationPermissionsForAuthorizationType:(ClusterLocationAuthorizationType)authorizationType
                                               title:(NSString *)requestTitle
                                             message:(NSString *)message
                                     denyButtonTitle:(NSString *)denyButtonTitle
                                    grantButtonTitle:(NSString *)grantButtonTitle
                                   completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

@end
