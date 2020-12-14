//
//  TWSceneBoxConfiguration.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TWSceneBoxExtensionConstants.h"
#import "TWSceneBoxExtension.h"
#import "TWBinaryTuple.h"
#import "TWSceneBoxExtensionAbilityManagement.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWSceneBoxConfiguration : NSObject

@property (nonatomic, strong, null_resettable) id<TWSceneBoxExtensionAbilityManagement> extensionAbilityManager;
@property (nonatomic, strong) UINavigationController *navigationController;

// TODO: swift throwable
- (void)setExtension:(id<TWSceneBoxExtension>)extension;
- (NSArray<TWBinaryTuple<NSNumber *, id<TWSceneBoxExtension>> *> *)configuredExtensions;  // the configured extensions contain some build in extensions

@end

NS_ASSUME_NONNULL_END
