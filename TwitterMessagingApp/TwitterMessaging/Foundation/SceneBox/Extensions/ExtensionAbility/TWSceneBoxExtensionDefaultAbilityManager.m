//
//  TWSceneBoxExtensionDefaultAbilityManager.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxExtensionDefaultAbilityManager.h"
#import "TWSceneBoxSceneManipulation.h"
#import "TWSceneBoxExtension.h"

@implementation TWSceneBoxExtensionDefaultAbilityManager

@synthesize markSceneAsActive = _markSceneAsActive;
@synthesize navigateToScene = _navigateToScene;
@synthesize getScenes = _getScenes;
@synthesize terminateBox = _terminateBox;

- (void)applyAbilitySetForExtension:(id<TWSceneBoxExtension>)extension {
    NSParameterAssert([extension conformsToProtocol:@protocol(TWSceneBoxExtension)]);
    
    [self applySceneManipulationIfNeeded:extension];
    [self applyBoxManipulationIfNeeded:extension];
}

#pragma mark - private

- (void)applySceneManipulationIfNeeded:(id<TWSceneBoxExtension>)extension {
    if (extension.extensionType != TWSceneBoxExtensionTypeNavigation) {
        return;
    }
    
    assert(self.markSceneAsActive);
    assert(self.navigateToScene);
    assert(self.getScenes);
    
    id<TWSceneBoxExtensionAbilityManagement> _extension = (id<TWSceneBoxExtensionAbilityManagement>)extension;
    
    _extension.markSceneAsActive = self.markSceneAsActive;
    _extension.navigateToScene = self.navigateToScene;
    _extension.getScenes = self.getScenes;
}

- (void)applyBoxManipulationIfNeeded:(id<TWSceneBoxExtension>)extension {
    if (extension.extensionType != TWSceneBoxExtensionTypeNavigation) {
        return;
    }
    
    assert(self.terminateBox);
    
    id<TWSceneBoxExtensionAbilityManagement> _extension = (id<TWSceneBoxExtensionAbilityManagement>)extension;
    
    _extension.terminateBox = self.terminateBox;
}

@end
