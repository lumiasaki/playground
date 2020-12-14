//
//  TWSceneBoxSceneManipulation.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWSceneBoxScene;

NS_ASSUME_NONNULL_BEGIN

/// Functionalities provided by SceneBox core
@protocol TWSceneBoxSceneManipulation <NSObject>

@required

/// Mark a scene as active scene
/// We only hope the Navigation Extension has this capability
/// Why: Since box is the sole owner of the scene, the concept of so-called activeScene is also managed by box, which belongs to the core capabilities of box and needs to be implemented through box
@property (nonatomic, copy) void(^markSceneAsActive)(NSUUID *sceneIdentifier);

/// Navigate to a scene, should be notified, if a scene has contained in the stack, the action will be `popTo`, not `push`
@property (nonatomic, copy) void(^navigateToScene)(NSUUID *sceneIdentifier);

/// Get identifiers of scenes. Note that the order is not guaranteed to follow the generated order
@property (nonatomic, copy) NSArray<NSUUID *> *(^getScenes)(void);

@end

NS_ASSUME_NONNULL_END
