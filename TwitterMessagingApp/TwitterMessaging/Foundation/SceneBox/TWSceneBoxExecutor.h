//
//  TWSceneBoxExecutor.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWSceneBox;

NS_ASSUME_NONNULL_BEGIN

// executor supports executing consequent scene boxes just like a pipeline
@interface TWSceneBoxExecutor : NSObject

+ (instancetype)shared;

- (void)executeBox:(TWSceneBox *)box;

@end

NS_ASSUME_NONNULL_END
