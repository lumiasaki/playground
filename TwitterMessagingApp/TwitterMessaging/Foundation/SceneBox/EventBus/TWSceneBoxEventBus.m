//
//  TWSceneBoxEventBus.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxEventBus.h"
#import "TWBinaryTuple.h"

// keep NSString here, the type may change in the future
@interface _TWSceneBoxEventBusStoreDispatcher : NSObject

- (void)dispatch:(NSString *)event userInfo:(NSDictionary *)userInfo;
- (void)watchEvent:(NSString *)event queue:(dispatch_queue_t)queue next:(TWSceneBoxEventBusNextBlock)nextBlock;

@end

@interface _TWSceneBoxEventBusStoreDispatcher () {
    dispatch_queue_t _workQueue;
}

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<TWBinaryTuple<dispatch_queue_t, TWSceneBoxEventBusNextBlock> *> *> *eventNameBlockMap;

@end

@implementation _TWSceneBoxEventBusStoreDispatcher

- (instancetype)init {
    if (self = [super init]) {
        _workQueue = dispatch_queue_create(DISPATCH_QUEUE_SERIAL, NULL);
    }
    return self;
}

- (void)dispatch:(NSString *)event userInfo:(NSDictionary *)userInfo {
    dispatch_async(_workQueue, ^{
        if (![event isKindOfClass:NSString.class]) {
            return;
        }
        
        NSMutableArray<TWBinaryTuple<dispatch_queue_t, TWSceneBoxEventBusNextBlock> *> *nexts = self.eventNameBlockMap[event];
        if (![nexts isKindOfClass:NSMutableArray.class]) {
            return;
        }
        
        for (TWBinaryTuple<dispatch_queue_t, TWSceneBoxEventBusNextBlock> *tuple in nexts) {
            dispatch_async(tuple.$0, ^{
                if (tuple.$1) {
                    tuple.$1(userInfo);
                }
            });
        }
    });
}

- (void)watchEvent:(NSString *)event queue:(dispatch_queue_t)queue next:(TWSceneBoxEventBusNextBlock)nextBlock {
    if (![event isKindOfClass:NSString.class] || !nextBlock) {
        return;
    }
    
    @synchronized (self.eventNameBlockMap) {
        if (![self.eventNameBlockMap[event] isKindOfClass:NSMutableArray.class]) {
            self.eventNameBlockMap[event] = [[NSMutableArray alloc] init];
        }
        
        TWBinaryTuple<dispatch_queue_t, TWSceneBoxEventBusNextBlock> *tuple = [[TWBinaryTuple alloc] init];
        tuple.$0 = queue;
        tuple.$1 = nextBlock;
        
        [self.eventNameBlockMap[event] addObject:tuple];
    }
}

#pragma mark - getter

- (NSMutableDictionary<NSString *, NSMutableArray<TWBinaryTuple<dispatch_queue_t, TWSceneBoxEventBusNextBlock> *> *> *)eventNameBlockMap {
    if (!_eventNameBlockMap) {
        _eventNameBlockMap = [[NSMutableDictionary alloc] init];
    }
    return _eventNameBlockMap;
}

@end

@interface TWSceneBoxEventBus ()

@property (nonatomic, strong) NSSet<TWSceneBoxExtensionEventBusEvent> *acceptableDispatchEvents;
@property (nonatomic, strong) _TWSceneBoxEventBusStoreDispatcher *dispatcher;

@end

@implementation TWSceneBoxEventBus

#pragma mark - initializer

- (instancetype)initWithAcceptableDispatchEvents:(NSSet<TWSceneBoxExtensionEventBusEvent> *)acceptableEvents {
    if (self = [super init]) {
        NSParameterAssert([acceptableEvents isKindOfClass:NSSet.class]);
        NSParameterAssert(acceptableEvents.count > 0);
        
        _acceptableDispatchEvents = acceptableEvents;
    }
    return self;
}

#pragma mark - public

- (void)dispatch:(TWSceneBoxExtensionEventBusEvent)event userInfo:(NSDictionary *)userInfo {
    if (![self.acceptableDispatchEvents containsObject:event]) {
        NSLog(@"dispatch an unrecognized event: %@", event);
        assert(NO);
        return;
    }
    
    [self.dispatcher dispatch:event userInfo:userInfo];
}

- (void)watchEvent:(TWSceneBoxExtensionEventBusEvent)event next:(void (^)(NSDictionary * _Nonnull))nextBlock {
    [self watchEvent:event queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) next:nextBlock];
}

- (void)watchEvent:(TWSceneBoxExtensionEventBusEvent)event queue:(dispatch_queue_t)queue next:(TWSceneBoxEventBusNextBlock)nextBlock {
    [self.dispatcher watchEvent:event queue:queue next:nextBlock];
}

#pragma mark - getter

- (_TWSceneBoxEventBusStoreDispatcher *)dispatcher {
    if (!_dispatcher) {
        _dispatcher = [[_TWSceneBoxEventBusStoreDispatcher alloc] init];        
    }
    return _dispatcher;
}

@end
