//
//  TWDialogue.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWDialogue.h"

@implementation TWDialogue
{
    TWMessage *_lastMessage;
    BOOL _messagesChanged;
}

- (instancetype)initWithUserPeer:(TWUser *)host recipient:(TWUser *)recipient {
    if (self = [super init]) {
        _dialogueId = [TWDialogue generateDialogueIdFromUserPeer:host recipient:recipient];
    }
    return self;
}

+ (NSString *)calculateDialogIdFromPeer:(TWUser *)host recipient:(TWUser *)recipient {
    return [TWDialogue generateDialogueIdFromUserPeer:host recipient:recipient];
}

- (TWMessage *)lastMessage {
    if (!_lastMessage || _messagesChanged) {
        NSSortDescriptor *sortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        _lastMessage = [self.messages sortedArrayUsingDescriptors:@[sortDesciptor]].lastObject;
        _messagesChanged = NO;
    }
    return _lastMessage;
}

#pragma mark - private

+ (NSString *)generateDialogueIdFromUserPeer:(TWUser *)host recipient:(TWUser *)recipient {
    TWUser *user1 = nil;
    TWUser *user2 = nil;
    
    if ([host.createTime compare:recipient.createTime] == NSOrderedAscending) {
        user1 = host;
        user2 = recipient;
    } else {
        user1 = recipient;
        user2 = host;
    }
    
    return [NSString stringWithFormat:@"%@:%@", user1.userId, user2.userId];
}

#pragma mark - setters

- (void)setMessages:(NSSet<TWMessage *> *)messages {
    _messages = messages;
    _messagesChanged = YES;
}

@end
