//
//  TWBusinessEndpointRequestManager.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2018/12/27.
//  Copyright © 2018 tianren.zhu. All rights reserved.
//

#import "TWBusinessEndpointRequestManager.h"
#import "TWEndpointAPIManager.h"
#import "TWNetworkConfiguration.h"

@implementation TWBusinessEndpointRequestManager

+ (TWEndpointAPIManager *)businessEndpointAPIManager {
    static TWEndpointAPIManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWEndpointAPIManager alloc] initWithConfiguration:({
            TWNetworkConfiguration *config = [[TWNetworkConfiguration alloc] init];
            config.baseUrl = @"";
            config.authToken = @"";
            
            config;
        })];
    });
    
    return instance;
}

@end
