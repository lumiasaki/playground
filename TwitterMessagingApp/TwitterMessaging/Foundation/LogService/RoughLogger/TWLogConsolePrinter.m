//
//  TWLogConsolePrinter.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWLogConsolePrinter.h"
#import "TWLogService.h"

@implementation TWLogConsolePrinter

- (void)consumeObservedInformation:(TWLogInformation *)information {
    NSLog(@"log level code: %ld\nmessage: %@\nextraInfo:%@", (long)information.logLevel, information.message, information.extraInfo);
}

@end
