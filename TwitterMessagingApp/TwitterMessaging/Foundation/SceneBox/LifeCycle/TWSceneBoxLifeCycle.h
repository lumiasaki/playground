//
//  TWSceneBoxLifeCycle.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxLifeCycle <NSObject>

@optional

- (void)sceneBoxWillTerminate;

@end

NS_ASSUME_NONNULL_END
