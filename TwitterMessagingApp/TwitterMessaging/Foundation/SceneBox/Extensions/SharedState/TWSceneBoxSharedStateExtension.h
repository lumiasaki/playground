//
//  TWSceneBoxSharedStateExtension.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtension.h"
#import "TWSceneBoxExtensionConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxSharedStateExtension <TWSceneBoxExtension>

@required

- (nullable id)querySharedStateByKey:(TWSceneBoxSharedStateKey)key;
- (void)setSharedState:(id)state onKey:(TWSceneBoxSharedStateKey)key;

@end

// TODO: swift immutable

// acceptableDispatchEventsOnEventBus: TWSceneBoxSharedStateChangesEvent, TWSceneBoxGetSharedStateByKeyEvent
@interface TWSceneBoxSharedStateExtension : NSObject <TWSceneBoxSharedStateExtension>

@end

NS_ASSUME_NONNULL_END
