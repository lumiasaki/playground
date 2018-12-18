//
//  TWEndpointAPIManager+DirectMessagesEventsList.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"
#import "TWEndpointAPIManager+DirectMessagesEventsList.m"
#import "TWEndpointDirectMessagesEventsListRequest.h"
#import "TWPersistingManager.h"
#import "TWUtils.h"
#import "TWDialogue.h"
#import "TWMessage.h"
#import "TWTextMessage.h"

@implementation TWEndpointAPIManager (DirectMessagesEventsList)

+ (TWEndpointRequestOperation *)pullLatestDirectMessage:(NSDictionary *)params completion:(TWEndpointResponseBlock)completion; {
    if (!completion) {
        return nil;
    }
    
    TWEndpointDirectMessagesEventsListRequest *request = [[TWEndpointDirectMessagesEventsListRequest alloc] initWithParams:params];
    
    // fake pulling...
    // return twice of latest message of current dialogue
    
    NSString *currentDialogueId = request.params[@"dialogueId"];
    if (![TWUtils stringIsEmpty:currentDialogueId]) {
        NSSet<TWDialogue *> *selectedDialogues = (NSSet<TWDialogue *> *)[TWPersistingManager.sharedManager selectObjects:TWDialogue.class predicate:[NSPredicate predicateWithFormat:@"dialogueId = %@", currentDialogueId]];
        
        if (selectedDialogues.count == 1) {
            TWDialogue *selectedDialogue = selectedDialogues.anyObject;
            
            TWMessage *latestMessage = selectedDialogue.lastMessage;
            if (latestMessage && [latestMessage.messageType isEqualToNumber:@(TWPlainTextMessageType)]) {
                TWTextMessage *textMessage = (TWTextMessage *)latestMessage;
                
                NSMutableString *response = [[NSMutableString alloc] init];
                for (NSInteger i = 0; i < 2; i++) {
                    [response appendString:[NSString stringWithFormat:@" %@", textMessage.textMessageContent]];
                }
                
                completion(nil, @{
                                  @"text" : response.copy,
                                  @"senderId" : request.params[@"senderId"] ?: @"",
                                  @"receiverId" : request.params[@"receiverId"] ?: @""
                                  }, nil);
            }
        }
    }
    
    return nil;
}

@end
