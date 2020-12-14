//
//  TWSceneBoxExtensionConstants.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#ifndef TWSceneBoxExtensionConstants_h
#define TWSceneBoxExtensionConstants_h

typedef NSString *TWSceneBoxExtensionEventBusEvent NS_EXTENSIBLE_STRING_ENUM;

typedef NSString *TWSceneBoxSharedStateKey NS_EXTENSIBLE_STRING_ENUM;

typedef NS_ENUM(NSInteger, TWSceneBoxExtensionType) {
    TWSceneBoxExtensionTypeUnknown = 0,
    TWSceneBoxExtensionTypeSharedState,   // shared state
    TWSceneBoxExtensionTypeNavigation, // a mechanism to navigate scenes
//    TWSceneBoxExtensionTypeRendering  // a type of extension to support rendering
    TWSceneBoxExtensionTypeLogger, // a logger which collecting information during the progress of scenebox
    TWSceneBoxExtensionTypeUnitTest    // an extension which helping unit test to access some state changes
};

#endif /* TWSceneBoxExtensionConstants_h */
