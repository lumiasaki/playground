//
//  TWSceneBoxScene.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtensionConstants.h"
#import "TWSceneBoxLifeCycle.h"
#import "TWSceneBoxSceneLifeCycle.h"
#import "TWSceneBoxNavigationExtension.h"  // to get terminationState

@protocol TWSceneBoxExtension;

#define TWSceneBoxSceneSafeCall(block, __VA_ARGS__) block ? block(__VA_ARGS__) : nil

NS_ASSUME_NONNULL_BEGIN

/// It represent a unit which is managed by TWSceneBox, it always been associated with a view controller. When we accomplish the shift from Objective-C to Swift, the class should be renamed to Scene
@protocol TWSceneBoxScene <NSObject, TWSceneBoxSceneLifeCycle, TWSceneBoxLifeCycle>

@required

/// An identifier distributed by TWSceneBox during the initialization phase
@property (nonatomic, strong) NSUUID *sceneIdentifier;  // TODO: conforms to Identifiable when shift to Swift

/// Get shared state from the internal store, the shared state feature is implemented by shared state extension
@property (nonatomic, copy) id _Nullable(^getSharedStateBy)(TWSceneBoxSharedStateKey key);

/// Set shared state to the internal store
/// Why use blocks here? Objective-C can not be attached any default implementations just like Swift extension can do, so here, in order to hide interfaces on TWSceneBox directly, keep there clean, we declare the interfaces here as blocks, assigned by TWSceneBox
@property (nonatomic, copy) void(^putSharedState)(id sharedState, TWSceneBoxSharedStateKey key);

/// Transit to a state, which represent a scene in the TWSceneBox
@property (nonatomic, copy) void(^transitToState)(NSNumber *state);  // swift之后使用范型实现state类型

/// It indicates if a scene is active scene
@property (nonatomic, copy) BOOL(^sceneIsActiveScene)(UIViewController<TWSceneBoxScene> *scene);

@end

NS_ASSUME_NONNULL_END
