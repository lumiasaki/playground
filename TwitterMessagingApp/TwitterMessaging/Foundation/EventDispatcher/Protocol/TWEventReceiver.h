//
//  TWEventReceiver.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/27.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWUniversalEvent;

NS_ASSUME_NONNULL_BEGIN

@protocol TWEventReceiver <NSObject>

@required
- (NSSet<NSString *> *)acceptEventNames;
- (void)receivedEvent:(TWUniversalEvent *)event;

@end

NS_ASSUME_NONNULL_END
