//
//  UIImageView+PTSImageCache.m
//  PhonTunes
//
//  Created by PhonTunes on 14-6-16.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "UIImageView+PTSImageCache.h"
#import <objc/runtime.h>
#import "AFHTTPRequestOperation.h"
#import "NSString+Path.h"
#import "NSString+Hash.h"
#import "NSString+Additions.h"

#pragma mark -
@interface UIImageView (_PTSImageCache)
@property (readwrite, nonatomic, strong, setter = pts_setImageRequestOperation:) AFHTTPRequestOperation *pts_imageRequestOperation;
@end

@implementation UIImageView (_PTSImageCache)

+ (NSOperationQueue *)pts_sharedImageRequestOperationQueue {
    static NSOperationQueue *_pts_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pts_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _pts_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _pts_sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)pts_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(pts_imageRequestOperation));
}

- (void)pts_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(pts_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -
static inline NSString * PTSImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation UIImageView (PTSImageCache)

@dynamic image_ResponseSerializer;

- (id <AFURLResponseSerialization>)image_ResponseSerializer {
    static id <AFURLResponseSerialization> _pts_defaultImageResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pts_defaultImageResponseSerializer = [AFImageResponseSerializer serializer];
    });
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(image_ResponseSerializer)) ?: _pts_defaultImageResponseSerializer;
#pragma clang diagnostic pop
}

- (void)setImage_ResponseSerializer:(id <AFURLResponseSerialization>)serializer {
    objc_setAssociatedObject(self, @selector(image_ResponseSerializer), serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)set_ImageWithURL:(NSURL *)url{
    [self set_ImageWithURL:url placeholderImage:nil];
}

- (void)set_ImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self set_ImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)set_ImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancel_ImageRequestOperation];
    
    NSString *cachedImagePath = [[NSString imageDirectory] stringByAppendingPathComponent:[PTSImageCacheKeyFromURLRequest(urlRequest) md5]];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:cachedImagePath]) {
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImagePath];
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
        
        self.pts_imageRequestOperation = nil;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }
        
        __weak __typeof(self)weakSelf = self;
        self.pts_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.pts_imageRequestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:cachedImagePath append:NO];
        self.pts_imageRequestOperation.responseSerializer = self.image_ResponseSerializer;
        [self.pts_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [UIImageJPEGRepresentation(responseObject, 0.7) writeToFile:cachedImagePath atomically:YES];
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.pts_imageRequestOperation.request URL]]) {
                if (success) {
                    success(urlRequest, operation.response, responseObject);
                } else if (responseObject) {
                    strongSelf.image = responseObject;
                }
                
                if (operation == strongSelf.pts_imageRequestOperation){
                    strongSelf.pts_imageRequestOperation = nil;
                }
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.pts_imageRequestOperation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }
                
                if (operation == strongSelf.pts_imageRequestOperation){
                    strongSelf.pts_imageRequestOperation = nil;
                }
            }
        }];
        
        [[[self class] pts_sharedImageRequestOperationQueue] addOperation:self.pts_imageRequestOperation];
    }
}

- (void)cancel_ImageRequestOperation {
    [self.pts_imageRequestOperation cancel];
    self.pts_imageRequestOperation = nil;
}
@end
