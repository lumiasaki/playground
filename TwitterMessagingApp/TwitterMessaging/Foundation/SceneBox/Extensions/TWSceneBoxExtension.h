//
//  TWSceneBoxExtension.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxLifeCycle.h"
#import "TWSceneBoxExtensionLifeCycle.h"
#import "TWSceneBoxExtensionConstants.h"

@class TWSceneBoxEventBus;

NS_ASSUME_NONNULL_BEGIN

/// This protocol is used to enrich the capabilities of SceneBox. Ideally, all non-core functionality should be implemented by Extension
@protocol TWSceneBoxExtension <NSObject, TWSceneBoxExtensionLifeCycle, TWSceneBoxLifeCycle>

@required

@property (nonatomic, assign, readonly) TWSceneBoxExtensionType extensionType;

// 采用block形式是为了从box内部delegate出来，而不公开方法在box类上，这样方法调用的管控收束在extension上，后续加一个extensionManager就可以管理所有的extension的能力，甚至这里的blocks都可以收束在extensionManager上，extension可以采用方法调用的方式调用自己的instance method

/// All inter-extension communication methods use the event bus，watchEvent:(String) next:(id), interaction between extensions does not care who requests and who responds
@property (nonatomic, weak) TWSceneBoxEventBus *eventBus;

@optional

/// Each extension should declare which events it can dispatch
- (NSSet<TWSceneBoxExtensionEventBusEvent> *)acceptableDispatchEventsOnEventBus;

@end

NS_ASSUME_NONNULL_END
