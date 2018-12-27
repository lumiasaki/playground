//
//  TWEndpointAPIManager.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"
#import "TWEndpointRequestOperation.h"
#import "TWNetworkingOperationManager.h"
#import "TWNetworkConfiguration.h"

@interface TWEndpointAPIManager ()

@property (nonatomic, strong) TWNetworkConfiguration *configuration;

@end

@implementation TWEndpointAPIManager

- (instancetype)initWithConfiguration:(TWNetworkConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (TWEndpointRequestOperation *)startEndpointRequest:(id<TWEndpointAPIRequest>)request completion:(TWEndpointResponseBlock)completion {
    if (![request conformsToProtocol:@protocol(TWEndpointAPIRequest)]) {
        return nil;
    }
    
    TWEndpointRequestOperation *operation = [[TWEndpointRequestOperation alloc] initWithConfiguration:self.configuration endpointRequest:request completion:completion];
    
    [TWEndpointAPIManager startOperation:operation];
    
    return operation;
}

#pragma mark - private

+ (void)startOperation:(TWEndpointRequestOperation *)operation {
    if (!operation) {
        return;
    }
    
    [TWNetworkingOperationManager.sharedManager addOperation:operation purpose:TWNetworkingEndpointRequestPurpose];
}

@end
