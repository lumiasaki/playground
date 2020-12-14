//
//  TWSceneBoxExtensionAbilityManagement.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtensionConstants.h"
#import "TWSceneBoxManipulation.h"
#import "TWSceneBoxSceneManipulation.h"

@protocol TWSceneBoxExtension;

NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxExtensionAbilityManagement <NSObject, TWSceneBoxManipulation, TWSceneBoxSceneManipulation>

@required

- (void)applyAbilitySetForExtension:(id<TWSceneBoxExtension>)extension;

@end

NS_ASSUME_NONNULL_END
