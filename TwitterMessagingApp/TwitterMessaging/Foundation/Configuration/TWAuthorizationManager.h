//
//  TWAuthorizationManager.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWAuthorizationManager : NSObject

@property (nonatomic, assign, readonly) BOOL isAuthorized;
@property (nonatomic, strong, readonly) NSString *authToken;

+ (instancetype)sharedManager;
- (void)requestAuth:(void(^)(BOOL))completion;

@end
