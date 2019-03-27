//
//  _TWInternalEventDispatcher.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWUniversalEvent;
@protocol TWEventReceiver;

NS_ASSUME_NONNULL_BEGIN

@interface _TWInternalEventDispatcher : NSObject

@property (nonatomic, strong) NSString *dipsatcherId;
@property (nonatomic, assign, readonly) NSUInteger currentTaskCount;
@property (nonatomic, assign, getter=isRunning, readonly) BOOL running;

- (void)dispatchEvent:(TWUniversalEvent *)event onEventReceivers:(NSMapTable<NSString *, id<TWEventReceiver>> *)eventReceivers;

@end
NS_ASSUME_NONNULL_END
