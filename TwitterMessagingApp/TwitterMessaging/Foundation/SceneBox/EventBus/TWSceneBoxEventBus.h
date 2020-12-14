//
//  TWSceneBoxEventBus.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtension.h"
#import "TWSceneBoxExtensionConstants.h"

typedef void(^TWSceneBoxEventBusNextBlock)(NSDictionary * _Nullable);

NS_ASSUME_NONNULL_BEGIN

/// Retained by TWSceneBox, the lifecycle of EventBus should be same as SceneBox
// TODO: swift, general type support
@interface TWSceneBoxEventBus : NSObject

/// Acceptable dispatch event indicates an event that extension could emit
- (instancetype)initWithAcceptableDispatchEvents:(NSSet<TWSceneBoxExtensionEventBusEvent> *)acceptableEvents;

- (void)dispatch:(TWSceneBoxExtensionEventBusEvent)event userInfo:(NSDictionary *)userInfo;

// watch on any queue, next block is trigged on global queue
- (void)watchEvent:(TWSceneBoxExtensionEventBusEvent)event next:(TWSceneBoxEventBusNextBlock)nextBlock;

// watch on any queue, next block is trigged on specific queue
- (void)watchEvent:(TWSceneBoxExtensionEventBusEvent)event queue:(dispatch_queue_t)queue next:(TWSceneBoxEventBusNextBlock)nextBlock;

@end

NS_ASSUME_NONNULL_END
