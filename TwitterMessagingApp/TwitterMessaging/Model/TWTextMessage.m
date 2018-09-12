//
//  TWTextMessage.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWTextMessage.h"
#import "TWUtils.h"

@implementation TWTextMessage

- (void)renderInRenderer:(id<TWMessageRenderer>)renderer {
    if ([renderer respondsToSelector:@selector(renderPlainText:)]) {
        [renderer renderPlainText:self.textMessageContent];
    }
    
    if ([renderer respondsToSelector:@selector(renderTimestamp:)]) {
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        
        NSDate *nextDay = [NSCalendar.currentCalendar dateByAddingComponents:dayComponent toDate:NSDate.date options:0];
        
        NSString *formatString = @"yyyy/MM/dd";
        if ([self.timestamp compare:nextDay] == NSOrderedAscending) {
            formatString = @"hh:mm";
        }
        
        [renderer renderTimestamp:[TWUtils formattedDateString:self.timestamp format:formatString]];
    }
    
    if ([renderer respondsToSelector:@selector(renderReadStatus:)]) {
        [renderer renderReadStatus:self.readStatus.boolValue];
    }
}

@end
