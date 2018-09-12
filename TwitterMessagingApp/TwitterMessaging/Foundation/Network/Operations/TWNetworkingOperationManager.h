//
//  TWNetworkingOperationManager.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TWNetworkingOperationPurpose) {
    TWNetworkingEndpointRequestPurpose,
    TWNetworkingImageDownloadingPurpose
};

@interface TWNetworkingOperationManager : NSObject

+ (instancetype)sharedManager;

- (void)addOperation:(NSOperation *)operation purpose:(TWNetworkingOperationPurpose)purpose;

@end
