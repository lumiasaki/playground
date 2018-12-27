//
//  TWEndpointAPIManager+Oauth2TokenRequest.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager+Oauth2TokenRequest.h"
#import "TWEndpointOauth2TokenRequest.h"
#import "TWBusinessEndpointRequestManager.h"

@implementation TWEndpointAPIManager (Oauth2TokenRequest)

+ (TWEndpointRequestOperation *)fetchOauth2Token:(TWEndpointResponseBlock)completion {
    // not reasonable
    return [TWBusinessEndpointRequestManager.businessEndpointAPIManager startEndpointRequest:[[TWEndpointOauth2TokenRequest alloc] init] completion:completion];
}

@end
