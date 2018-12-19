//
//  TWEndpointAPIRequest.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWNetworkDataSerializer.h"

@protocol TWEndpointAPIRequest <NSObject>

@property (nonatomic, strong, readonly) NSString *endpoint;
@property (nonatomic, strong, readonly) NSString *httpMethod;
@property (nonatomic, strong, readonly) NSDictionary *params;
@property (nonatomic, strong, readonly) NSDictionary *additionalHeaders;
@property (nonatomic, assign, readonly) TWNetworkDataSerializerType serializerType;
@property (nonatomic, assign, readonly) TWNetworkDataSerializerType deserializerType;

@end

@protocol TMEndpointAPIRequestInjectDefaultHeaders <NSObject>

@property (nonatomic, assign, readonly) BOOL injectDefaultHeaders;

@end
