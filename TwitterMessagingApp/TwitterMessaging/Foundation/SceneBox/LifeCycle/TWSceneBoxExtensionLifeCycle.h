//
//  TWSceneBoxExtensionLifeCycle.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TWSceneBox;

@protocol TWSceneBoxExtensionLifeCycle <NSObject>

@optional

- (void)extensionDidMount:(TWSceneBox *)sceneBox;  // a reasonable time to watch events on the event bus

@end

NS_ASSUME_NONNULL_END
