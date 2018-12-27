//
//  TWNetworkConfiguration.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWNetworkDataSerializer.h"
#import "TWEndpointAPIRequest.h"

__attribute__((objc_subclassing_restricted))

@interface TWNetworkConfiguration : NSObject

@property (nonatomic, strong, readonly) NSString *baseUrl;
@property (nonatomic, strong, readonly) NSString *authToken;

+ (instancetype)sharedConfiguration;

- (Class<TWNetworkDataSerializer>)serializer:(TWNetworkDataSerializerType)serializerType;

@end

@interface TWNetworkConfiguration (TWEndpointAPIRequest)

- (NSDictionary *)defaultHeadersWith:(id<TWEndpointAPIRequest>)request;

@end
