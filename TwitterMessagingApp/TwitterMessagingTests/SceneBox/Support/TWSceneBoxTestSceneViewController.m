//
//  TWSceneBoxTestSceneViewController.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/27.
//  Copyright © 2020 tianren.zhu. All rights reserved.
//

#import "TWSceneBoxTestSceneViewController.h"

@interface TWSceneBoxTestSceneViewController ()

@end

@implementation TWSceneBoxTestSceneViewController

@synthesize getSharedStateBy = _getSharedStateBy;
@synthesize putSharedState = _putSharedState;
@synthesize transitToState = _transitToState;
@synthesize transitToPreviousState = _transitToPreviousState;
@synthesize sceneIsActiveScene = _sceneIsActiveScene;
@synthesize sceneIdentifier = _sceneIdentifier;
@synthesize correctCurrentStateWhenBackGesture = _correctCurrentStateWhenBackGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)transitToState:(NSNumber *)state {
    self.transitToState(state);
}

- (void)transitToPreviousSceneState {
    self.transitToPreviousState();
}

- (void)sceneDidLoaded {
    if (self.sceneDidLoadedBlock) {
        self.sceneDidLoadedBlock();
    }
}

- (void)sceneWillUnload {
    if (self.sceneWillUnloadBlock) {
        self.sceneWillUnloadBlock();
    }
}

- (BOOL)isActiveScene {
    if (!self.sceneIsActiveScene) {
        return NO;
    }
    return self.sceneIsActiveScene(self);
}

@end
