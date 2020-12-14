//
//  TWSceneBoxConfiguration.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/21.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxConfiguration.h"
#import "TWSceneBoxExtensionDefaultAbilityManager.h"
#import "TWSceneBoxCoreExtensions.h"

@interface TWSceneBoxConfiguration () {
    NSArray<TWBinaryTuple<NSNumber *, id<TWSceneBoxExtension>> *> *_configuredExtensions; // readonly
}

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<TWSceneBoxExtension>> *extensions;

@end

@implementation TWSceneBoxConfiguration

- (void)setExtension:(id<TWSceneBoxExtension>)extension {
    NSParameterAssert([extension conformsToProtocol:@protocol(TWSceneBoxExtension)]);
    NSParameterAssert(extension.extensionType != TWSceneBoxExtensionTypeUnknown);
    NSAssert(!self.extensions[@(extension.extensionType)], @"already configure one extension as same extension type");
    
    @synchronized (self.extensions) {
        [self.extensions setObject:extension forKey:@(extension.extensionType)];
    }
}

- (NSArray<TWBinaryTuple<NSNumber *, id<TWSceneBoxExtension>> *> *)configuredExtensions {
    if (!_configuredExtensions) {
        _configuredExtensions = ({
            NSMutableArray<TWBinaryTuple<NSNumber *, id<TWSceneBoxExtension>> *> *configuredExtensions = [[NSMutableArray alloc] init];
            
            for (NSNumber *key in self.extensions.allKeys) {
                TWBinaryTuple<NSNumber *, id<TWSceneBoxExtension>> *tuple = [[TWBinaryTuple alloc] init];
                
                tuple.$0 = key;
                tuple.$1 = [self.extensions objectForKey:key];
                
                [configuredExtensions addObject:tuple];
            }
            
            configuredExtensions.copy;
        });
    }
    
    NSAssert(self.extensions[@(TWSceneBoxExtensionTypeNavigation)], @"navigation extension not found");
    NSAssert(self.extensions[@(TWSceneBoxExtensionTypeSharedState)], @"shared state extension not found");
    
    return _configuredExtensions.copy;
}

#pragma mark - build in extensions

- (id<TWSceneBoxNavigationExtension>)defaultNavigationExtension {
    return [[TWSceneBoxNavigationExtension alloc] init];
}

- (id<TWSceneBoxSharedStateExtension>)defaultSharedStateExtension {
    return [[TWSceneBoxSharedStateExtension alloc] init];
}

#pragma mark - getter

- (id<TWSceneBoxExtensionAbilityManagement>)extensionAbilityManager {
    if (!_extensionAbilityManager) {
        _extensionAbilityManager = [[TWSceneBoxExtensionDefaultAbilityManager alloc] init];
    }
    return _extensionAbilityManager;
}

- (NSMutableDictionary<NSNumber *, id<TWSceneBoxExtension>> *)extensions {
    if (!_extensions) {
        _extensions = [[NSMutableDictionary alloc] init];
        _extensions[@(TWSceneBoxExtensionTypeSharedState)] = [self defaultSharedStateExtension];
        _extensions[@(TWSceneBoxExtensionTypeNavigation)] = [self defaultNavigationExtension];
    }
    return _extensions;
}

@end
