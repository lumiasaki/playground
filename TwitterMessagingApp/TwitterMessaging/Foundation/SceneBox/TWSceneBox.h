//
//  TWSceneBox.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/20.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxConfiguration.h"
#import "TWSceneBoxScene.h"

@class TWSceneBox;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TWSceneBoxEntryBlock)(UIViewController<TWSceneBoxScene> *scene, TWSceneBox *sceneBox);
typedef void(^TWSceneBoxExitBlock)(UIViewController<TWSceneBoxScene> *scene, TWSceneBox *sceneBox);

__attribute__((objc_subclassing_restricted))

/// It's a mechanism what really helpful and suitable for those processes which can not be interrupted, fully decoupled, might be reordered in the future, contains a lot of states need to be shared
@interface TWSceneBox : NSObject

@property (nonatomic, strong, readonly) NSUUID *boxIdentifier;

@property (nonatomic, strong, readonly) TWSceneBoxConfiguration *configuration;

@property (nonatomic, copy) NSDictionary<NSNumber *, NSUUID *> *stateSceneIdentifierTable;

@property (nonatomic, copy, readonly) TWSceneBoxEntryBlock entryBlock;
@property (nonatomic, copy, readonly) TWSceneBoxExitBlock exitBlock;

- (instancetype)initWithConfiguration:(TWSceneBoxConfiguration *)configuration entryBlock:(TWSceneBoxEntryBlock)entryBlock exitBlock:(TWSceneBoxExitBlock)exitBlock NS_DESIGNATED_INITIALIZER;

/// Add a scene by a initialized view controller, the method will return an identifier for the scene, you should use it to configure the `stateSceneIdentifierTable` later
- (NSUUID *)addScene:(UIViewController<TWSceneBoxScene> *)scene;

/// A peer method of `addScene:`, lazy add a scene with an identifier
- (void)lazyAddScene:(UIViewController<TWSceneBoxScene> *(^)(void))sceneConstructor sceneIdentifier:(NSUUID *)sceneIdentifier;

/// start a scene box, you can call this manually or delegate to TWSceneBoxExecutor
- (void)execute;

#pragma mark - unavailable

- (instancetype)init NS_UNAVAILABLE;

@end

@interface TWSceneBox (TWSharedState)

- (nullable id)tw_getSharedStateByKey:(id)key;

@end

NS_ASSUME_NONNULL_END
