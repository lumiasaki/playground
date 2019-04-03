//
//  TWEventDispatcher.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWMicroService.h"
#import "TWMicroServiceContext.h"
#import "TWUniversalEvent.h"

@protocol TWEventReceiver;

#define SUPPORT_EVENTS(events) \
FOUNDATION_EXPORT TWMicroServiceContext *GetGlobalServiceContext(void); \
- (NSSet<NSString *> *)acceptEventNames { \
return [NSSet setWithArray:events]; \
}

NS_ASSUME_NONNULL_BEGIN

@interface TWEventDispatcher : NSObject <TWMicroService>

- (void)registerEventReceiver:(id<TWEventReceiver>)receiver;
- (void)registerEventReceivers:(NSArray<id<TWEventReceiver>> *)receivers;

- (void)dispatchEvent:(TWUniversalEvent *)event;

@end

NS_ASSUME_NONNULL_END
