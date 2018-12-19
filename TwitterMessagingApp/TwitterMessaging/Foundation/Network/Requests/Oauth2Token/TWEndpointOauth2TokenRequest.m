//
//  TWEndpointOauth2TokenRequest.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointOauth2TokenRequest.h"

// Twitter rejected my developer account application, so I couldn't use valid consumer key and secret key
static NSString *const CONSUMER_KEY = @"CONSUMER_KEY";
static NSString *const SECRET_KEY = @"SECRET_KEY";

@implementation TWEndpointOauth2TokenRequest

- (NSString *)endpoint {
    return @"oauth2/token";
}

- (NSString *)httpMethod {
    return @"POST";
}

- (NSDictionary *)params {
    return @{@"grant_type" : @"client_credentials"};
}

- (NSDictionary *)additionalHeaders {    
    return @{
             @"Authorization" : [NSString stringWithFormat:@"Basic %@", self.bearerTokenCredentialsInBase64],
             @"Content-Type" : @"application/x-www-form-urlencoded;charset=UTF-8"
             };
}

- (TWNetworkDataSerializerType)serializerType {
    return TWNetworkDataSerializerFormURLEncodedType;
}

- (TWNetworkDataSerializerType)deserializerType {
    return TWNetworkDataSerializerJSONType;
}

#pragma mark - private

- (NSString *)bearerTokenCredentialsInBase64 {
    NSString *bearerTokenCredentials = [NSString stringWithFormat:@"%@:%@", CONSUMER_KEY, SECRET_KEY];
    return [[bearerTokenCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

@end
