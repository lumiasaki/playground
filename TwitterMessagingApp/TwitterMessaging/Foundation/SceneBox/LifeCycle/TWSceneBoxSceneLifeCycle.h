//
//  TWSceneBoxSceneLifeCycle.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxSceneLifeCycle <NSObject>

@optional

- (void)sceneDidLoaded;
- (void)sceneWillUnload;

@end

NS_ASSUME_NONNULL_END
