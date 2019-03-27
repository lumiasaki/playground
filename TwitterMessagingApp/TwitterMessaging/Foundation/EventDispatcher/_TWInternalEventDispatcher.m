//
//  _TWInternalEventDispatcher.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "_TWInternalEventDispatcher.h"
#import "TWUniversalEvent.h"
#import "TWEventReceiver.h"

@interface _TWInternalEventDispatcher ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation _TWInternalEventDispatcher

- (void)dispatchEvent:(TWUniversalEvent *)event onEventReceivers:(NSMapTable<NSString *,id<TWEventReceiver>> *)eventReceivers {
    if (![event isKindOfClass:TWUniversalEvent.class]) {
        return;
    }
    
    if (![eventReceivers isKindOfClass:NSMapTable.class]) {
        return;
    }
    
    [self.operationQueue addOperationWithBlock:^{
        id<TWEventReceiver> receiver = [eventReceivers objectForKey:event.eventName];
        if ([receiver conformsToProtocol:@protocol(TWEventReceiver)]) {
            [receiver receivedEvent:event];
        }
    }];
}

#pragma mark - getter

- (NSUInteger)currentTaskCount {
    return self.operationQueue.operationCount;
}

- (BOOL)isRunning {
    return self.operationQueue.operationCount != 0;
}

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 5;
    }
    return _operationQueue;
}

@end
