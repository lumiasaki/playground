//
//  TWBusinessEndpointRequestManager.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2018/12/27.
//  Copyright © 2018 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWEndpointAPIManager;

NS_ASSUME_NONNULL_BEGIN

@interface TWBusinessEndpointRequestManager : NSObject

+ (TWEndpointAPIManager *)businessEndpointAPIManager;

@end

NS_ASSUME_NONNULL_END
