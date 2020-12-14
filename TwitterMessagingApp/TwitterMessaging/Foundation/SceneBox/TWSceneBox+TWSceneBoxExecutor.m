//
//  TWSceneBox+TWSceneBoxExecutor.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import "TWSceneBox+TWSceneBoxExecutor.h"
#import <objc/runtime.h>

@implementation TWSceneBox (TWSceneBoxExecutor)

- (void)setActiveScene:(UIViewController<TWSceneBoxScene> *)activeScene {
    objc_setAssociatedObject(self, @selector(activeScene), activeScene, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController<TWSceneBoxScene> *)activeScene {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTerminateBox:(void (^)(TWSceneBox *))terminateBox {
    objc_setAssociatedObject(self, @selector(terminateBox), terminateBox, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(TWSceneBox *))terminateBox {
    return objc_getAssociatedObject(self, _cmd);
}

@end
