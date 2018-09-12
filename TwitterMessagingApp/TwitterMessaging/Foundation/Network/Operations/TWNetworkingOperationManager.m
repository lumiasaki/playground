//
//  TWNetworkingOperationManager.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWNetworkingOperationManager.h"

@interface TWNetworkingOperationManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSOperationQueue *> *queuesAssociateWithPurpose;

@end

@implementation TWNetworkingOperationManager

+ (instancetype)sharedManager {
    static TWNetworkingOperationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWNetworkingOperationManager alloc] init];
        instance.queuesAssociateWithPurpose = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

- (void)addOperation:(NSOperation *)operation purpose:(TWNetworkingOperationPurpose)purpose {
    if (!operation) {
        return;
    }
    
    @synchronized (self.queuesAssociateWithPurpose) {
        if (!self.queuesAssociateWithPurpose[@(purpose)]) {
            self.queuesAssociateWithPurpose[@(purpose)] = generateQueueWith(purpose);
        }
        
        [self.queuesAssociateWithPurpose[@(purpose)] addOperation:operation];
    }
}

#pragma mark - private

static NSOperationQueue *generateQueueWith(TWNetworkingOperationPurpose purpose) {
    switch (purpose) {
        case TWNetworkingEndpointRequestPurpose:
            return queueWithDefaultSetting();
        case TWNetworkingImageDownloadingPurpose:
            return queueWithDefaultSetting();
        default:
            return queueWithDefaultSetting();
    }
}

static inline NSOperationQueue *queueWithDefaultSetting() {
    NSOperationQueue *result = [[NSOperationQueue alloc] init];
    result.maxConcurrentOperationCount = 5;
    return result;
}

@end
