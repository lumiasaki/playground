//
//  TWEventDispatcher.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWEventDispatcher.h"
#import "TWEventReceiver.h"
#import "TWUniversalEvent.h"
#import "_TWInternalEventDispatcher.h"

@interface TWEventDispatcher ()

@property (nonatomic, strong) NSSet<_TWInternalEventDispatcher *> *internalDispatchers;
@property (nonatomic, strong) NSMapTable<NSString *, id<TWEventReceiver>> *receivers;

@end

@implementation TWEventDispatcher

#pragma mark - TWMicroService

+ (NSString *)serviceKey {    
    return NSStringFromClass(self);
}

+ (TWMicroServiceIsolateLevel)isolateLevel {
    return TWMicroServiceIsolateGlobalLevel;
}

+ (TWMicroServiceInitializeLevel)initializeLevel {
    return TWMicroServiceInitializeImmediatelyLevel;
}

- (void)start {
    // do nothing
}

#pragma mark - initializer

- (instancetype)init {
    if (self = [super init]) {
        // setup at beginning phase, maybe we can lazy init them
        (void)self.internalDispatchers;
        (void)self.receivers;
    }
    return self;
}

#pragma mark - public method

- (void)registerEventReceiver:(id<TWEventReceiver>)receiver {
    if (![receiver conformsToProtocol:@protocol(TWEventReceiver)]) {
        return;
    }
    
    [self registerEventReceivers:@[receiver]];
}

- (void)registerEventReceivers:(NSArray<id<TWEventReceiver>> *)eventReceivers {
    if (![eventReceivers isKindOfClass:NSArray.class]) {
        return;
    }
    
    @synchronized (self.receivers) {
        for (id<TWEventReceiver> receiver in eventReceivers) {
            if ([receiver conformsToProtocol:@protocol(TWEventReceiver)]) {
                [self addReceiver:receiver];
            }
        }
    }
}

- (void)dispatchEvent:(TWUniversalEvent *)event {
    if (![event isKindOfClass:TWUniversalEvent.class]) {
        return;
    }
    
    // find pressureless dispatcher to dispatch event
    [self.pressurelessDispatcher dispatchEvent:event onEventReceivers:self.receivers.copy];
}

#pragma mark - getter

- (NSMapTable<NSString *, id<TWEventReceiver>> *)receivers {
    if (!_receivers) {
        _receivers = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:10];
    }
    return _receivers;
}

- (NSSet<_TWInternalEventDispatcher *> *)internalDispatchers {
    if (!_internalDispatchers) {
        NSMutableSet<_TWInternalEventDispatcher *> *mutableSet = [[NSMutableSet alloc] init];
        
        static const NSUInteger countOfInternalDispatchers = 3;
        for (NSUInteger i = 0; i < countOfInternalDispatchers; i++) {
            _TWInternalEventDispatcher *dispatcher = [[_TWInternalEventDispatcher alloc] init];
            dispatcher.dispatcherId = [NSString stringWithFormat:@"dispatcher_%lu", (unsigned long)i];
            
            [mutableSet addObject:dispatcher];
        }
        _internalDispatchers = mutableSet.copy;
    }
    return _internalDispatchers;
}

#pragma mark - util

// not thread safe, guaranteed by caller (registerEventReceivers:)
- (void)addReceiver:(id<TWEventReceiver>)receiver {
    if (![receiver conformsToProtocol:@protocol(TWEventReceiver)]) {
        return;
    }        
    
    NSSet<NSString *> *acceptEventNames = receiver.acceptEventNames;
    if (![acceptEventNames isKindOfClass:NSSet.class]) {
        return;
    }
    
    for (NSString *eventName in acceptEventNames) {
        [self.receivers setObject:receiver forKey:eventName];
    }
}

- (_TWInternalEventDispatcher *)pressurelessDispatcher {
    static NSArray<NSSortDescriptor *> *descriptors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptors = @[
                        [[NSSortDescriptor alloc] initWithKey:@"currentTaskCount" ascending:YES]
                        ];
    });
    
    return [[self.internalDispatchers sortedArrayUsingDescriptors:descriptors] firstObject];
}

@end
