//
//  TWSecurePersistingManager.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWDataConvertible.h"

@interface TWSecureKeychainManager : NSObject

// this secure keychain manager use KeyChain techology to persist objects safety

+ (instancetype)sharedManager;

- (void)add:(id<TWDataConvertible>)convertableData as:(NSString *)key;
- (id<TWDataConvertible>)search:(NSString *)key result:(id<TWDataConvertible>)result;
- (void)remove:(NSString *)key;

@end
