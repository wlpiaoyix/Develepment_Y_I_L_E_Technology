//
//  UIImageView+PTSImageCache.h
//  PhonTunes
//
//  Created by PhonTunes on 14-6-16.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <Availability.h>
#import <UIKit/UIKit.h>

@protocol AFURLResponseSerialization;

@interface UIImageView (PTSImageCache)

@property (nonatomic, strong) id <AFURLResponseSerialization> image_ResponseSerializer;

- (void)set_ImageWithURL:(NSURL *)url;
- (void)set_ImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage;

- (void)set_ImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;


- (void)cancel_ImageRequestOperation;
@end
