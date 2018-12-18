//
//  TWEndpointAPIManager+Oauth2TokenRequest.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"
@class TWEndpointRequestOperation;

@interface TWEndpointAPIManager (Oauth2TokenRequest)

+ (TWEndpointRequestOperation *)fetchOauth2Token:(TWEndpointResponseBlock)completion;

@end
