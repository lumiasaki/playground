//
//  NSString+TWExtension.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "NSString+TWExtension.h"

@implementation NSString (TWExtension)

- (NSData *)convertToNSData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (instancetype)convertFromNSData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
