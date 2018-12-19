//
//  TWEndpointServiceImpl.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointServiceImpl.h"
#import "TWUtils.h"

static NSTimeInterval const TIMEOUT_INTERVAL = 30.f;

@interface TWEndpointServiceImpl ()

@property (nonatomic, strong) TWNetworkConfiguration *configuration;
@property (nonatomic, strong, readwrite) id<TWEndpointAPIRequest> request;
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation TWEndpointServiceImpl

@synthesize request = _request;

- (instancetype)initWithConfiguration:(TWNetworkConfiguration *)configuration {
    NSAssert(configuration, @"configuration should never be nil");
    if (self = [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (void)request:(id<TWEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *, NSDictionary *, NSError *))completion {
    NSAssert(request, @"request should never be nil");
    self.request = request;
    
    NSURLRequest *urlRequest = [self generateUrlRequestFrom:request];
    
    if (urlRequest) {
        // replace NSURLSession.sharedSession if needed.
        self.task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error && completion) {
                completion(response, nil, error);
                return;
            }
            
            if (((NSHTTPURLResponse *)response).statusCode >= 300 && ((NSHTTPURLResponse *)response).statusCode < 200) {
                if (completion) {
                    completion(response, nil, [NSError errorWithDomain:@"request error" code:((NSHTTPURLResponse *)response).statusCode userInfo:nil]);
                }
            }
            
            NSDictionary *responseDictionary = [[self.configuration serializer:request.deserializerType] deserializeData:data];
            if (responseDictionary && completion) {
                completion(response, responseDictionary, nil);
            }
        }];
        
        [self.task resume];
    }
}

- (void)cancel {
    [self.task cancel];
}

- (void)setRequest:(id<TWEndpointAPIRequest>)request {
    NSAssert([TWUtils validateEndpointRequest:request], @"request format error");
    _request = request;
}

#pragma mark - private
                                              
- (NSURL *)formalUrl:(id<TWEndpointAPIRequest>)request {
    NSAssert(request, @"request should be nil");
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.configuration.baseUrl, request.endpoint]];
    
    // handle with the params when using GET method
    if ([request.httpMethod caseInsensitiveCompare:@"get"] == NSOrderedSame && request.params.count != 0) {
        NSMutableArray *queryItems = [[NSMutableArray alloc] init];
        
        for (NSString *key in request.params.allKeys) {
            NSString *value = request.params[key];
            if (![TWUtils stringIsEmpty:value]) {
                [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
            }
        }
        
        urlComponents.queryItems = queryItems.copy;
    }
    
    return urlComponents.URL;
}

- (NSURLRequest *)generateUrlRequestFrom:(id<TWEndpointAPIRequest>)request {
    NSMutableURLRequest *mutableUrlRequest = [[NSMutableURLRequest alloc] initWithURL:[self formalUrl:request] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT_INTERVAL];
    mutableUrlRequest.HTTPMethod = request.httpMethod;
    
    NSMutableDictionary *mutableHeaders = [[NSMutableDictionary alloc] initWithDictionary:request.additionalHeaders];
    
    // inject necessary information into header fields
    // the request doesn't conform to the protocol in default case, means that the framework should inject the default headers
    // if the request conforms to the protocol, the framework will check the `injectDefaultHeaders` flag in order to inject default headers
    if (![request conformsToProtocol:@protocol(TWEndpointAPIRequestInjectDefaultHeaders)] || [[request performSelector:@selector(injectDefaultHeaders)] boolValue]) {
        if (![TWUtils stringIsEmpty:self.configuration.authToken] && !mutableHeaders[@"Authorization"]) {
            mutableHeaders[@"Authorization"] = self.configuration.authToken;
        }
        
        [mutableHeaders addEntriesFromDictionary:[self.configuration defaultHeadersWith:request]];
    }
    
    mutableUrlRequest.allHTTPHeaderFields = mutableHeaders.copy;
    
    if ([request.httpMethod caseInsensitiveCompare:@"post"] == NSOrderedSame) {
        mutableUrlRequest.HTTPBody = [[self.configuration serializer:request.serializerType] serializeDictionary:request.params];
    }
    
    return mutableUrlRequest.copy;
}

@end