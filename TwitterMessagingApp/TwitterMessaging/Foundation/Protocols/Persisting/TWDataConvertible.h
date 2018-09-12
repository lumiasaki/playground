//
//  TWDataConvertable.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWDataConvertible <NSObject>

- (NSData *)convertToNSData;
- (instancetype)convertFromNSData:(NSData *)data;

@end
