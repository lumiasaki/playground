//
//  TWMessageRenderer.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWMessageRenderer <NSObject>

@optional
- (void)renderPlainText:(NSString *)text;
- (void)renderTimestamp:(NSString *)timestamp;
- (void)renderReadStatus:(BOOL)read;

@end
