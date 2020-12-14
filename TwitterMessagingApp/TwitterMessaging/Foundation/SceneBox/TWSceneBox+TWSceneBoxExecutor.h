//
//  TWSceneBox+TWSceneBoxExecutor.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBox.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWSceneBox (TWSceneBoxExecutor)

@property (nonatomic, strong, nullable) UIViewController<TWSceneBoxScene> *activeScene;
@property (nonatomic, copy, nullable) void(^terminateBox)(TWSceneBox *box);

@end

NS_ASSUME_NONNULL_END
