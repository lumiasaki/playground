//
//  TWEventDispatcher.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWUniversalEvent;
@protocol TWEventReceiver;

NS_ASSUME_NONNULL_BEGIN

@interface TWEventDispatcher : NSObject

+ (instancetype)shared;

- (void)registerEventReceiver:(id<TWEventReceiver>)receiver;
- (void)registerEventReceivers:(NSArray<id<TWEventReceiver>> *)receivers;

- (void)dispatchEvent:(TWUniversalEvent *)event;

@end

NS_ASSUME_NONNULL_END
