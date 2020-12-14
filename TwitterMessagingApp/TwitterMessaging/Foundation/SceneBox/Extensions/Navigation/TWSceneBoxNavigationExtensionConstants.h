//
//  TWSceneBoxNavigationExtensionConstants.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/26.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#ifndef TWSceneBoxNavigationExtensionConstants_h
#define TWSceneBoxNavigationExtensionConstants_h

#import "TWSceneBoxExtensionConstants.h"

static TWSceneBoxExtensionEventBusEvent const TWSceneBoxNavigationTrackEvent = @"TWSceneBoxNavigationTrackEvent";

static TWSceneBoxExtensionEventBusEvent const TWSceneBoxNavigationGetScenesRequestEvent = @"TWSceneBoxNavigationGetScenesRequestEvent";
static TWSceneBoxExtensionEventBusEvent const TWSceneBoxNavigationGetScenesResponseEvent = @"TWSceneBoxNavigationGetScenesResponseEvent";

static NSString *const TWSceneBoxNavigationTrackEventFromKey = @"TWSceneBoxNavigationTrackEventFromKey";
static NSString *const TWSceneBoxNavigationTrackEventToKey = @"TWSceneBoxNavigationTrackEventToKey";

static NSString *const TWSceneBoxNavigationGetScenesEventObjectKey = @"TWSceneBoxNavigationGetScenesEventObjectKey";

#endif /* TWSceneBoxNavigationExtensionConstants_h */
