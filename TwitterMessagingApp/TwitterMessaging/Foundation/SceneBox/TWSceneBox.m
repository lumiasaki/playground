//
//  TWSceneBox.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/20.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBox.h"
#import "TWSceneBoxEventBus.h"
#import "TWSceneBox+TWSceneBoxExecutor.h"
#import "TWSceneBoxCoreExtensions.h"
#import "TWBinaryTuple.h"

@interface TWSceneBox ()

@property (nonatomic, strong, readwrite) TWSceneBoxConfiguration *configuration;
@property (nonatomic, strong, readwrite) NSUUID *boxIdentifier;
@property (nonatomic, copy, readwrite) TWSceneBoxEntryBlock entryBlock;
@property (nonatomic, copy, readwrite) TWSceneBoxExitBlock exitBlock;

@property (nonatomic, copy) NSMutableDictionary<NSNumber *, id<TWSceneBoxExtension>> *extensions;   // NSNumber should be TWSceneBoxExtensionType
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, UIViewController<TWSceneBoxScene> *> *scenesIdentifierMap;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, UIViewController<TWSceneBoxScene> *(^)(void)> *lazySceneConstructors;

@property (nonatomic, strong) TWSceneBoxEventBus *eventBus;

@end

@implementation TWSceneBox

- (instancetype)initWithConfiguration:(TWSceneBoxConfiguration *)configuration entryBlock:(TWSceneBoxEntryBlock)entryBlock exitBlock:(TWSceneBoxExitBlock)exitBlock {
    if (self = [super init]) {
        NSParameterAssert(entryBlock);
        NSParameterAssert(exitBlock);
        
        _boxIdentifier = NSUUID.UUID;
        _configuration = configuration;
        _entryBlock = entryBlock;
        _exitBlock = exitBlock;
    }
    return self;
}

- (NSUUID *)addScene:(UIViewController<TWSceneBoxScene> *)scene {
    // should run on the main queue, check the main thread roughly here
    NSAssert([NSThread isMainThread], @"must run on main thread");
    NSParameterAssert([scene isKindOfClass:UIViewController.class]);
    NSParameterAssert([scene conformsToProtocol:@protocol(TWSceneBoxScene)]);
    
    NSUUID *sceneIdentifier = NSUUID.UUID;
    [self attachSceneAbilityToScene:scene];
    NSUUID *identifier = [self attachSceneIdentifierToScene:scene identifier:sceneIdentifier];
    self.scenesIdentifierMap[identifier] = scene;
    
    return sceneIdentifier;
}

- (void)lazyAddScene:(UIViewController<TWSceneBoxScene> * _Nonnull (^)(void))sceneConstructor sceneIdentifier:(NSUUID *)sceneIdentifier {
    // should run on the main queue, check the main thread roughly here
    NSAssert([NSThread isMainThread], @"must run on main thread");
    NSParameterAssert(sceneConstructor);
    NSParameterAssert([sceneIdentifier isKindOfClass:NSUUID.class]);
        
    self.lazySceneConstructors[sceneIdentifier] = sceneConstructor;
}

- (void)execute {
    [self processConfiguration:self.configuration];
    
    TWBinaryTuple<NSUUID *, UIViewController<TWSceneBoxScene> *> *tuple = [self findEntrySceneFromTable:self.stateSceneIdentifierTable];
    NSAssert(tuple, @"can't find a valid entry scene");
    
    if ([tuple.$0 isKindOfClass:NSUUID.class]) {
        [self transitToStateBlock](@(TWSceneBoxNavigationExtension.entryState));
        [self markSceneAsActiveBlock](tuple.$0);
    }
    
    self.entryBlock(self.activeScene, self);
}

- (void)setStateSceneIdentifierTable:(NSDictionary<NSNumber *,NSUUID *> *)stateSceneIdentifierTable {
    NSParameterAssert([stateSceneIdentifierTable isKindOfClass:NSDictionary.class]);
    
    _stateSceneIdentifierTable = stateSceneIdentifierTable;
}

#pragma mark - private

- (void)processConfiguration:(TWSceneBoxConfiguration *)configuration {
    [self setUpExtensionAbilityManager:configuration];
    [self setUpExtensionsWith:configuration];
    [self additionalSetUpNavigationExtension];
    [self checkExtensionsCompleteness];
    [self applyAbilitySetToExtensions:self.extensions configuration:configuration];
    [self notifyExtensionsMountEvent];
}

- (nullable TWBinaryTuple<NSUUID *, UIViewController<TWSceneBoxScene> *> *)findEntrySceneFromTable:(NSDictionary<NSNumber *, NSUUID *> *)stateSceneIdentifierTable {
    if (![stateSceneIdentifierTable isKindOfClass:NSDictionary.class]) {
        assert(NO);
        return nil;
    }
    
    for (NSNumber *sceneState in stateSceneIdentifierTable.allKeys) {
        if (![sceneState isEqualToNumber:@(TWSceneBoxNavigationExtension.entryState)]) {
            continue;
        }
        
        NSUUID *sceneIdentifier = stateSceneIdentifierTable[sceneState];
        UIViewController<TWSceneBoxScene> *entryScene = [self initiateSceneFromIdentifierIfNeeded:sceneIdentifier];
        
        TWBinaryTuple *tuple = [[TWBinaryTuple alloc] init];
        tuple.$0 = sceneIdentifier;
        tuple.$1 = entryScene;
        
        return tuple;
    }
        
    return nil;
}

- (nullable UIViewController<TWSceneBoxScene> *)initiateSceneFromIdentifierIfNeeded:(NSUUID *)sceneIdentifier {
    UIViewController<TWSceneBoxScene> *targetScene = [self sceneByIdentifier:sceneIdentifier];
    if (!targetScene) {
        targetScene = self.lazySceneConstructors[sceneIdentifier]();
        
        if (![targetScene conformsToProtocol:@protocol(TWSceneBoxScene)]) {
            NSLog(@"can't initiate scene from identifier with id: %@", sceneIdentifier);
            assert(NO);
            return nil;
        }
        
        // attach abilities to scene
        [self attachSceneAbilityToScene:targetScene];
        // fill identifier
        [self attachSceneIdentifierToScene:targetScene identifier:sceneIdentifier];
        
        // set the real scene to scenes dictionary
        self.scenesIdentifierMap[sceneIdentifier] = targetScene;
    }
    
    return targetScene;
}

- (void)setUpExtensionAbilityManager:(TWSceneBoxConfiguration *)configuration {
    NSParameterAssert([configuration isKindOfClass:TWSceneBoxConfiguration.class]);
    
    configuration.extensionAbilityManager.markSceneAsActive = [self markSceneAsActiveBlock];
    configuration.extensionAbilityManager.getScenes = [self getScenesBlock];
    configuration.extensionAbilityManager.navigateToScene = [self navigateSceneBlock];
    configuration.extensionAbilityManager.terminateBox = [self terminateBoxBlock];
}

- (void)setUpExtensionsWith:(TWSceneBoxConfiguration *)configuration {
    NSMutableSet<NSString *> *acceptableDispatchEvents = [[NSMutableSet alloc] init];
        
    for (TWBinaryTuple<NSNumber *, id<TWSceneBoxExtension>> *tuple in [configuration configuredExtensions]) {
        
        NSNumber *type = tuple.$0;
        id<TWSceneBoxExtension> extension = tuple.$1;
        
        if (![type isKindOfClass:NSNumber.class] || ![extension conformsToProtocol:@protocol(TWSceneBoxExtension)]) {
            NSLog(@"extension processing failed");
            continue;
        }
        
        [self.extensions setObject:extension forKey:type];
        
        if ([extension respondsToSelector:@selector(acceptableDispatchEventsOnEventBus)] && [extension.acceptableDispatchEventsOnEventBus isKindOfClass:NSSet.class]) {
            [acceptableDispatchEvents unionSet:extension.acceptableDispatchEventsOnEventBus];
        }
    }
    
    self.eventBus = [[TWSceneBoxEventBus alloc] initWithAcceptableDispatchEvents:acceptableDispatchEvents.copy];
    
    for (id<TWSceneBoxExtension> extension in self.extensions.allValues) {
        if ([extension conformsToProtocol:@protocol(TWSceneBoxExtension)]) {
            extension.eventBus = self.eventBus;
        }
    }
}

- (void)additionalSetUpNavigationExtension {
    NSAssert(self.stateSceneIdentifierTable, @"stateSceneIdentifierTable is nil");
    
    id<TWSceneBoxNavigationExtension> navigationExtension = [self extractNavigationExtension];
    navigationExtension.stateSceneIdentifierTable = self.stateSceneIdentifierTable;
}

- (void)checkExtensionsCompleteness {
    // throw the assert during development phase
    NSAssert(self.extensions[@(TWSceneBoxExtensionTypeSharedState)], @"shared state extension is lost, the extension is mandatory");
    NSAssert(self.extensions[@(TWSceneBoxExtensionTypeNavigation)], @"navigation extension is lost, the extension is mandatory");
}

- (void)applyAbilitySetToExtensions:(NSDictionary<NSNumber *, id<TWSceneBoxExtension>> *)extensions configuration:(TWSceneBoxConfiguration *)configuration {
    for (id<TWSceneBoxExtension> extension in extensions.allValues) {
        if ([extension conformsToProtocol:@protocol(TWSceneBoxExtension)]) {
            [configuration.extensionAbilityManager applyAbilitySetForExtension:extension];
        }
    }
}

- (void)notifyExtensionsMountEvent {
    for (id<TWSceneBoxExtension> extension in self.extensions.allValues) {
        if ([extension respondsToSelector:@selector(extensionDidMount:)]) {
            [extension extensionDidMount:self];
        }
    }
}

#pragma mark - provide TWSceneBoxSceneManipulation

- (void(^)(NSUUID *))markSceneAsActiveBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSUUID *sceneIdentifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSAssert([NSThread isMainThread], @"must run on main thread");
        
        UIViewController<TWSceneBoxScene> *targetScene = [strongSelf initiateSceneFromIdentifierIfNeeded:sceneIdentifier];
        if (targetScene) {
            if ([strongSelf.activeScene respondsToSelector:@selector(sceneWillUnload)]) {
                [strongSelf.activeScene sceneWillUnload];
            }
            
            if ([targetScene respondsToSelector:@selector(sceneDidLoaded)]) {
                [targetScene sceneDidLoaded];
            }
            
            strongSelf.activeScene = targetScene;
        }
    };
}

- (void(^)(NSUUID *))navigateSceneBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSUUID *sceneIdentifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSAssert([NSThread isMainThread], @"must run on main thread");
        assert([strongSelf.configuration.navigationController isKindOfClass:UINavigationController.class]);
        assert([sceneIdentifier isKindOfClass:NSUUID.class]);
        
        UIViewController<TWSceneBoxScene> *targetScene = [strongSelf initiateSceneFromIdentifierIfNeeded:sceneIdentifier];
        if (!targetScene) {
            return;
        }
                
        if ([strongSelf.configuration.navigationController.viewControllers containsObject:targetScene] || [strongSelf tryToFindChildViewControllerIfExists:targetScene]) {
            if (![strongSelf.configuration.navigationController.viewControllers containsObject:targetScene]) {
                [strongSelf.configuration.navigationController popToViewController:targetScene.parentViewController animated:YES];
            } else {
                [strongSelf.configuration.navigationController popToViewController:targetScene animated:YES];
            }
            
            NSMutableArray<NSUUID *> *candidates = [[NSMutableArray alloc] init];
            for (NSUUID *identifier in strongSelf.scenesIdentifierMap.allKeys) {
                UIViewController<TWSceneBoxScene> *scene = strongSelf.scenesIdentifierMap[identifier];
                
                if (scene && ![strongSelf.configuration.navigationController.viewControllers containsObject:scene] && ![strongSelf.configuration.navigationController.viewControllers containsObject:scene.parentViewController]) {
                    [candidates addObject:identifier];
                }
            }
            
            for (NSUUID *identifier in candidates) {
                [strongSelf.scenesIdentifierMap removeObjectForKey:identifier];
            }
            
            return;
        }
        
        [strongSelf.configuration.navigationController pushViewController:targetScene animated:YES];
    };
}

- (NSArray<NSUUID *> *(^)(void))getScenesBlock {
    __weak typeof(self) weakSelf = self;
    return ^NSArray<NSUUID *> * {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        return strongSelf.scenesIdentifierMap.allKeys.copy;
    };
}

#pragma mark - provide TWSceneBoxManipulation

- (void(^)(void))terminateBoxBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        // notify last scene will unload event
        if (strongSelf.activeScene && [strongSelf.activeScene respondsToSelector:@selector(sceneWillUnload)]) {
            [strongSelf.activeScene sceneWillUnload];
        }
        
        // notify scenes
        for (UIViewController<TWSceneBoxScene> *scene in strongSelf.scenesIdentifierMap.allValues) {
            if ([scene respondsToSelector:@selector(sceneBoxWillTerminate)]) {
                [scene sceneBoxWillTerminate];
            }
        }
        
        // notify extensions
        for (id<TWSceneBoxExtension> extension in strongSelf.extensions.allValues) {
            if ([extension respondsToSelector:@selector(sceneBoxWillTerminate)]) {
                [extension sceneBoxWillTerminate];
            }
        }
        
        // notify box executor to kill self
        if (strongSelf.terminateBox) {
            strongSelf.terminateBox(strongSelf);
        }
    };
}

#pragma mark - bind core extension abilities to scenes

- (id _Nullable(^)(TWSceneBoxSharedStateKey))getSharedStateBlock {
    __weak typeof(self) weakSelf = self;
    return ^id _Nullable(TWSceneBoxSharedStateKey key) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSAssert([NSThread isMainThread], @"must run on main thread");
        NSParameterAssert(key);
        // occurred during runtime
        if (!key) {
            NSLog(@"try to get shared state by nil key");
            return nil;
        }
        
        id<TWSceneBoxSharedStateExtension> extension = [strongSelf extractSharedStateExtension];
        
        return [extension querySharedStateByKey:key];
    };
}

- (void(^)(id sharedState, TWSceneBoxSharedStateKey))putSharedStateBlock {
    __weak typeof(self) weakSelf = self;
    return ^void(id sharedState, TWSceneBoxSharedStateKey key) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSAssert([NSThread isMainThread], @"must run on main thread");
        NSParameterAssert(key);
        NSParameterAssert(sharedState);
        // occurred during runtime
        if (!key || !sharedState) {
            NSLog(@"try to put shared state by nil key or nil sharedState");
            return;
        }
        
        id<TWSceneBoxSharedStateExtension> extension = [strongSelf extractSharedStateExtension];
        
        [extension setSharedState:sharedState onKey:key];
    };
}

- (void(^)(NSNumber *state))transitToStateBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSNumber *state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSAssert([NSThread isMainThread], @"must run on main thread");
        NSParameterAssert([state isKindOfClass:NSNumber.class]);
        if (![state isKindOfClass:NSNumber.class]) {
            NSLog(@"try to transit to state by nil state");
            return;
        }                
        
        id<TWSceneBoxNavigationExtension> extension = [strongSelf extractNavigationExtension];
        
        [extension transitToState:state];
    };
}

- (BOOL(^)(UIViewController<TWSceneBoxScene> *))sceneIsActiveSceneBlock {
    __weak typeof(self) weakSelf = self;
    return ^BOOL(UIViewController<TWSceneBoxScene> *scene) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        return strongSelf.activeScene == scene;
    };
}

#pragma mark - private

- (NSUUID *)attachSceneIdentifierToScene:(UIViewController<TWSceneBoxScene> *)scene identifier:(NSUUID *)identifier {
    scene.sceneIdentifier = identifier;
    return identifier;
}

- (nullable UIViewController<TWSceneBoxScene> *)sceneByIdentifier:(NSUUID *)identifier {
    return [self.scenesIdentifierMap objectForKey:identifier];
}

- (void)attachSceneAbilityToScene:(UIViewController<TWSceneBoxScene> *)scene {
    NSParameterAssert([scene conformsToProtocol:@protocol(TWSceneBoxScene)]);
    
    scene.getSharedStateBy = [self getSharedStateBlock];
    scene.putSharedState = [self putSharedStateBlock];
    scene.transitToState = [self transitToStateBlock];
    scene.sceneIsActiveScene = [self sceneIsActiveSceneBlock];    
}

- (id<TWSceneBoxSharedStateExtension>)extractSharedStateExtension {
    return (id<TWSceneBoxSharedStateExtension>)[self strictlyExtractExtensionByType:TWSceneBoxExtensionTypeSharedState protocol:@protocol(TWSceneBoxSharedStateExtension)];
}

- (id<TWSceneBoxNavigationExtension>)extractNavigationExtension {
    return (id<TWSceneBoxNavigationExtension>)[self strictlyExtractExtensionByType:TWSceneBoxExtensionTypeNavigation protocol:@protocol(TWSceneBoxNavigationExtension)];
}

- (id<TWSceneBoxExtension>)strictlyExtractExtensionByType:(TWSceneBoxExtensionType)type protocol:(Protocol *)protocol {
    id<TWSceneBoxSharedStateExtension> extension = (id<TWSceneBoxSharedStateExtension>)self.extensions[@(type)];
    assert(extension.extensionType == type);
    assert([extension conformsToProtocol:protocol]);
    return extension;
}

- (BOOL)tryToFindChildViewControllerIfExists:(UIViewController<TWSceneBoxScene> *)targetScene {
    for (UIViewController *viewController in self.configuration.navigationController.viewControllers) {
        if ([viewController.childViewControllers containsObject:targetScene]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - getter

- (NSMutableDictionary<NSNumber *, id<TWSceneBoxExtension>> *)extensions {
    if (!_extensions) {
        _extensions = [[NSMutableDictionary alloc] init];
    }
    return _extensions;
}

- (NSMutableDictionary<NSUUID *, UIViewController<TWSceneBoxScene> *> *)scenesIdentifierMap {
    if (!_scenesIdentifierMap) {
        _scenesIdentifierMap = [[NSMutableDictionary alloc] init];
    }
    return _scenesIdentifierMap;
}

- (NSMutableDictionary<NSUUID *, UIViewController<TWSceneBoxScene> *(^)(void)> *)lazySceneConstructors {
    if (!_lazySceneConstructors) {
        _lazySceneConstructors = [[NSMutableDictionary alloc] init];
    }
    return _lazySceneConstructors;
}

@end

@implementation TWSceneBox (TWSharedState)

- (nullable id)tw_getSharedStateByKey:(id)key {
    return self.getSharedStateBlock(key);
}

@end
