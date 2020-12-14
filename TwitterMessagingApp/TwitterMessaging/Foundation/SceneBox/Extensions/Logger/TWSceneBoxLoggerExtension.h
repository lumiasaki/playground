//
//  TWSceneBoxLoggerExtension.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/26.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtension.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxLoggerExtension <NSObject, TWSceneBoxExtension>

@end

@interface TWSceneBoxLoggerExtension : NSObject <TWSceneBoxLoggerExtension>

@property (nonatomic, assign) BOOL printBoxActivitiesToConsole;  // default is YES
@property (nonatomic, assign) BOOL printNavigationTrackToConsole;    // default is YES
@property (nonatomic, assign) BOOL printSharedStateChangesToConsole; // default is YES

@end

NS_ASSUME_NONNULL_END
