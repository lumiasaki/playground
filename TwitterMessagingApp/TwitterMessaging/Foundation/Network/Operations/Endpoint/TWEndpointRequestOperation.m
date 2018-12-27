//
//  TWNetworkOperation.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointRequestOperation.h"
#import "TWEndpointServiceImpl.h"
#import "TWNetworkConfiguration.h"
#import "TWNetworkDataJSONSerializer.h"

static NSString *const IS_READY = @"isReady";
static NSString *const IS_EXECUTING = @"isExecuting";
static NSString *const IS_FINISHED = @"isFinished";
static NSString *const IS_CANCELLED = @"isCancelled";

@interface TWEndpointRequestOperation ()

@property (nonatomic, strong) id<TWEndpointService> requestService;
@property (nonatomic, strong, readwrite) id<TWEndpointAPIRequest> request;
@property (nonatomic, copy) void(^completion)(NSURLResponse *, NSDictionary *, NSError *);

@end

@implementation TWEndpointRequestOperation

@synthesize ready = _ready;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithConfiguration:(TWNetworkConfiguration *)configuration endpointRequest:(id<TWEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *, NSDictionary *, NSError *))completion {
    NSAssert(configuration, @"configuration should never be nil");
    NSAssert(request, @"request should never be nil");
    if (self = [super init]) {        
        _requestService = [[TWEndpointServiceImpl alloc] initWithConfiguration:configuration];
        _request = request;
        _completion = completion;
        
        self.name = @"com.faketwitter.twtwitterdm.operation.endpoint";
        self.ready = YES;
        self.executing = NO;
        self.finished = NO;
        self.cancelled = NO;
    }
    return self;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)start {
    @synchronized (self.request) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        
        self.ready = NO;
        self.executing = YES;
        self.finished = NO;
        self.cancelled = NO;
        
        __weak typeof (self) weakSelf = self;
        [self.requestService request:self.request completion:^(NSURLResponse *urlResponse, NSDictionary *responseObj, NSError *error) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            
            if (strongSelf.isCancelled) {
                strongSelf.finished = YES;
                return;
            }
            if (strongSelf.completion) {
                strongSelf.completion(urlResponse, responseObj, error);
            }
            
            strongSelf.finished = YES;
        }];
    }
}

- (void)cancel {
    [self.requestService cancel];
    
    self.ready = NO;
    self.executing = NO;
    self.finished = NO;
    self.cancelled = YES;
}

#pragma mark - setters

#define SETTER_WRAPPER(setterName, valueName, key)  \
- (void)setterName:(BOOL)valueName {\
[self willChangeValueForKey:key]; \
_##valueName = valueName; \
[self didChangeValueForKey:key];    \
}

SETTER_WRAPPER(setReady, ready, IS_READY)
SETTER_WRAPPER(setExecuting, executing, IS_EXECUTING)
SETTER_WRAPPER(setFinished, finished, IS_FINISHED)
SETTER_WRAPPER(setCancelled, cancelled, IS_CANCELLED)

#pragma mark - getters

- (BOOL)isReady {
    return _ready;
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isCancelled {
    return _cancelled;
}

@end
