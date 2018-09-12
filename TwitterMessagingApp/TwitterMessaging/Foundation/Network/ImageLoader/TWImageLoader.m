//
//  TWImageLoader.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2018/8/8.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWImageLoader.h"
#import "TWNetworkingOperationManager.h"

@implementation TWImageLoader

+ (void)downloadImageWithUrl:(NSString *)url completion:(void (^)(NSString *, UIImage *))completion {
    if ([self imageFromCache:url] && completion) {
        completion(url, [self imageFromCache:url]);
        return;
    }
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error && completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil);
                });
                return;
            }
            
            UIImage *image = [UIImage imageWithData:data];
            if (image && completion) {
                [self cacheImage:image url:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(url, image);
                });
            }
        }];
        [task resume];
    }];
    
    [TWNetworkingOperationManager.sharedManager addOperation:blockOperation purpose:TWNetworkingImageDownloadingPurpose];
}

#pragma mark - private


+ (NSCache *)cachedImages {
    static NSCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSCache alloc] init];
    });
    return instance;
}

+ (void)cacheImage:(UIImage *)image url:(NSString *)url {
    @synchronized (self.cachedImages) {
        if (image && url) {
            [[self cachedImages] setObject:image forKey:url];
        }
    }
}

+ (UIImage *)imageFromCache:(NSString *)url {
    @synchronized (self.cachedImages) {        
        return [[self cachedImages] objectForKey:url];
    }
}

@end
