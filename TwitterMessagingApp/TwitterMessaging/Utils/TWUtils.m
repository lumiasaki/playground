//
//  TWUtils.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWUtils.h"
#import <objc/runtime.h>

@implementation TWUtils

+ (BOOL)validateEndpointRequest:(id<TWEndpointAPIRequest>)request {
    if ([self stringIsEmpty:request.endpoint]) {
        return NO;
    }
    
    if ([self stringIsEmpty:request.httpMethod]) {
        return NO;
    }
    
    if (![request.params isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    
    if (![request.additionalHeaders isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)stringIsEmpty:(NSString *)string {
    return ![string isKindOfClass:NSString.class] || string.length == 0;
}

+ (NSString *)encodeURL:(NSString *)urlString {
    return [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

static NSDateFormatter *DateFormatter;
+ (NSString *)formattedDateString:(NSDate *)date format:(NSString *)format {
    if (!DateFormatter) {
        DateFormatter = [[NSDateFormatter alloc] init];
    }
    @synchronized (DateFormatter) {
        DateFormatter.dateFormat = format;
        return [DateFormatter stringFromDate:date];
    }
}

static NSDateFormatter *ReverseDateFormatter;
+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format {
    if (!ReverseDateFormatter) {
        ReverseDateFormatter = [[NSDateFormatter alloc] init];
    }
    @synchronized (ReverseDateFormatter) {
        ReverseDateFormatter.dateFormat = format;
        return [ReverseDateFormatter dateFromString:dateString];
    }
}

+ (NSArray<Class> *)getAllClasses {
    int numClasses;
    Class *classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    NSMutableArray<Class> *result = [[NSMutableArray alloc] init];
    
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class c = classes[i];
            
            if ([NSBundle bundleForClass:c] == NSBundle.mainBundle) {
                [result addObject:c];
            }
        }
        free(classes);
    }
    
    return result.copy;
}

@end
