//
//  TWSceneBoxTestSceneViewController.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/27.
//  Copyright © 2020 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWSceneBoxScene.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWSceneBoxTestSceneViewController : UIViewController <TWSceneBoxScene>

@property (nonatomic, copy, nullable) void(^sceneDidLoadedBlock)(void);
@property (nonatomic, copy, nullable) void(^sceneWillUnloadBlock)(void);

- (void)transitToState:(NSNumber *)state;
- (BOOL)isActiveScene;

@end

NS_ASSUME_NONNULL_END
