//
//  TWSceneBoxNavigationExtension.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2020/11/23.
//  Copyright © 2020年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWSceneBoxExtension.h"
#import "TWSceneBoxManipulation.h"
#import "TWSceneBoxSceneManipulation.h"
 
NS_ASSUME_NONNULL_BEGIN

@protocol TWSceneBoxNavigationExtension <TWSceneBoxExtension, TWSceneBoxManipulation, TWSceneBoxSceneManipulation>

@required

@property (nonatomic, strong) NSDictionary<NSNumber *, NSUUID *> *stateSceneIdentifierTable;

+ (NSInteger)entryState;
+ (NSInteger)terminationState;

- (void)transitToState:(NSNumber *)state;

@end

// acceptableDispatchEventsOnEventBus: TWSceneBoxNavigationTrackEvent, TWSceneBoxNavigationGetScenesResponseEvent
@interface TWSceneBoxNavigationExtension : NSObject <TWSceneBoxNavigationExtension>

@end

NS_ASSUME_NONNULL_END
