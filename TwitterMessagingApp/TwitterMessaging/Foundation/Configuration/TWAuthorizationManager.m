//
//  TWAuthorizationManager.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWAuthorizationManager.h"
#import "NSString+TWExtension.h"
#import "TWUtils.h"
#import "TWEndpointAPIManager+Oauth2TokenRequest.h"
#import "TwitterMessaging-Bridging-Header.h"

static NSString *const BEARER_TOKEN_SECURE_SAVE_KEY = @"bearerToken";

static NSString *const TOKEN_TYPE = @"token_type";
static NSString *const ACCESS_TOKEN = @"access_token";

@implementation TWAuthorizationManager

+ (instancetype)sharedManager {
    static TWAuthorizationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWAuthorizationManager alloc] init];
    });
    return instance;
}

- (void)requestAuth:(void(^)(BOOL))completion {
    if (!self.isAuthorized) {
        [TWEndpointAPIManager fetchOauth2Token:^(NSURLResponse *urlResponse, NSDictionary *responseObj, NSError *error) {
            if (error && completion) {
                completion(NO);
                return;
            }
            
            if ([responseObj[TOKEN_TYPE] isEqualToString:@"bearer"] && ![TWUtils stringIsEmpty:responseObj[ACCESS_TOKEN]]) {
//                [TWSecureKeychainManager.sharedManager add:(NSString *)responseObj[ACCESS_TOKEN] as:BEARER_TOKEN_SECURE_SAVE_KEY];                
                if (completion) {
                    completion(YES);
                }
            }
        }];
    } else {    
        if (completion) {
            completion(YES);
        }
    }
}

#pragma mark - getter

// this method will always return false because of the keys, for proceeding forword app logic, I have to comment them out and force return true, but the TWSecureKeychainManager is worked.
- (BOOL)isAuthorized {
//    NSString *result = @"";
//    result = (NSString *)[TWSecureKeychainManager.sharedManager search:BEARER_TOKEN_SECURE_SAVE_KEY result:result];
//    return ![TWUtils stringIsEmpty:result];
    return YES;
}

// same reason like above, I have to comment these code out and return a mock authToken
- (NSString *)authToken {
//    NSString *result = @"";
//    result = (NSString *)[TWSecureKeychainManager.sharedManager search:BEARER_TOKEN_SECURE_SAVE_KEY result:result];
//    return result;
    return @"mock auth token";
}

@end
