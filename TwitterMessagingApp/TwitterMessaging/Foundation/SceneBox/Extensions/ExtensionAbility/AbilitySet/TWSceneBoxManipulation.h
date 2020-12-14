//
//  TWSceneBoxManipulation.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/24.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The following capabilities are provided by box, and the implementation after the call is provided by box
@protocol TWSceneBoxManipulation <NSObject>

@required

/// terminateBox, after the call will end the box life cycle, will be automatically removed from the sceneBoxExecutor
/// We just hope Navigation Extension has the ability.
/// Why: The purpose of calling terminateBox is to terminate the life cycle of the box, meaning that the current state of the scene has come to the termination state, this ability is beyond the ability of extension, can only be applied by extension to box terminate, if all goes well, the box will handle the process, and eventually to the holder of the box - sceneBoxExecutor informed that this box can be released

@property (nonatomic, copy) void(^terminateBox)(void);

@end

NS_ASSUME_NONNULL_END
