//
//  TWSecurePersistingManager.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWSecureKeychainManager.h"
#import <Security/Security.h>

static NSString *const SERVICE_DOMAIN = @"com.faketwitter.twtwitterdm.keychain";

@implementation TWSecureKeychainManager

+ (instancetype)sharedManager {
    static TWSecureKeychainManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWSecureKeychainManager alloc] init];
    });
    return instance;
}

- (void)add:(id<TWDataConvertible>)convertableData as:(NSString *)key {
    NSMutableDictionary *queryDictionary = [self queryDictionary];
    [queryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
    
    OSStatus status = -1;
    CFTypeRef result = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, &result);
    
    if (status == errSecItemNotFound) {
        NSData *data = [convertableData convertToNSData];
        [queryDictionary setObject:data forKey:(__bridge id)kSecValueData];
        
        status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
    } else if (status == errSecSuccess) {
        NSData *data = [convertableData convertToNSData];
        
        NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] initWithDictionary:queryDictionary];
        [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
        
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
    }
    
    NSLog(@"Keychain add successed: %d", status);
}

- (id<TWDataConvertible>)search:(NSString *)key result:(id<TWDataConvertible>)result {
    NSMutableDictionary *queryDictionary = [self queryDictionary];
    [queryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
    [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    OSStatus status = -1;
    CFTypeRef resultRef = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, &resultRef);
    
    if (status != errSecSuccess) {
        NSLog(@"Keychain search failed: %@", key);
        return nil;
    }
    
    return [result convertFromNSData:(__bridge NSData *)resultRef];
}

- (void)remove:(NSString *)key {
    NSMutableDictionary *queryDictionary = [self queryDictionary];
    [queryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
    [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
    
    if (status != errSecSuccess) {
        NSLog(@"Keychain delete failed: %@", key);
    }
}

#pragma mark - private

- (NSMutableDictionary *)queryDictionary {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    
    [mutableDictionary setObject:SERVICE_DOMAIN forKey:(__bridge id)kSecAttrService];
    [mutableDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    return mutableDictionary;
}

@end
