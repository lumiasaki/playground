//
//  TWSceneBoxUnitTestHelperExtension.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/27.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtension.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxUnitTestHelperExtension <TWSceneBoxExtension>

@end

// acceptableDispatchEventsOnEventBus: TWSceneBoxGetSharedStateByKeyEvent, TWSceneBoxNavigationGetScenesEvent
@interface TWSceneBoxUnitTestHelperExtension : NSObject <TWSceneBoxUnitTestHelperExtension>

@property (nonatomic, copy, nullable) void(^sceneBoxWillTerminateBlock)(void);

@property (nonatomic, copy, nullable) void(^extensionDidMountBlock)(void);
@property (nonatomic, copy, nullable) void(^navigationTrackBlock)(NSNumber *from, NSNumber *to);
@property (nonatomic, copy) NSArray<NSUUID *> *(^getScenesBlock)(void);

@property (nonatomic, copy, nullable) void(^sharedStateChangesBlock)(id key, id object);

@end

NS_ASSUME_NONNULL_END
