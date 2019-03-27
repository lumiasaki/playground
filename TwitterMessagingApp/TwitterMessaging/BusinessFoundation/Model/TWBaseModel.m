//
//  TWBaseModel.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWBaseModel.h"

@implementation TWBaseModel

- (instancetype)init {
    if (self = [super init]) {
        _modelUniqueId = [NSUUID UUID];
    }
    return self;
}

@end
