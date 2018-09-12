//
//  TWMessagingAction.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWMessagingAction.h"
#import "TWPersistingManager.h"
#import "TWEndpointAPIManager+DirectMessagesEventsNew.h"
#import "TWEndpointAPIManager+DirectMessagesEventList.h"
#import "TWUtils.h"
#import "TWGlobalConfiguration.h"
#import "TWTextMessage.h"

@interface TWMessagingAction ()

@property (nonatomic, strong) NSString *currentUnsendMessageContent;

@end

@implementation TWMessagingAction

- (instancetype)initWithViewController:(TWMessagingViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)requestMessagesFromRemote {
    [self fakeRequestMessageFromRemote];
}

- (void)sendMessage {
    if ([TWUtils stringIsEmpty:self.currentUnsendMessageContent]) {
        return;
    }
    
    [TWEndpointAPIManager sendDirectMessage:@{
                                              @"recipient_id" : self.viewController.dialogue.recipient.userId ?: @"",
                                              @"text" : self.currentUnsendMessageContent
                                              } completion:^(NSError *error, NSDictionary *response) {
                                                  if (!error) {
                                                      TWTextMessage *message = [[TWTextMessage alloc] init];
                                                      message.sender = TWGlobalConfiguration.sharedConfiguration.currentUser;
                                                      message.receiver = self.viewController.dialogue.recipient;
                                                      message.messageType = @(TWPlainTextMessageType);    // for now, always plain text type
                                                      message.timestamp = [NSDate date];
                                                      message.readStatus = @NO;
                                                      message.messageUniqueIdentifier = NSUUID.UUID.UUIDString; // in real API endpoint, the message id should be retrieved by server side
                                                      message.textMessageContent = self.currentUnsendMessageContent.copy;
                                                      
                                                      [TWPersistingManager.sharedManager insertObject:message];
                                                      
                                                      NSMutableSet *messages = [[NSMutableSet alloc] initWithSet:self.viewController.dialogue.messages];
                                                      [messages addObject:message];
                                                      
                                                      self.viewController.dialogue.messages = messages.copy;
                                                      
                                                      [TWPersistingManager.sharedManager updateObject:self.viewController.dialogue];
                                                      [TWPersistingManager.sharedManager save];
                                                      
                                                      self.currentUnsendMessageContent = nil;
                                                      [self.viewController renderMessages:[self sortedMessages]];
                                                      
                                                      // within real scenario, real-time messaging might be duplex, for this fake app, just simply pull new messages from remote after sending.
                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                          [self pullLatestMessagesFromRemote];
                                                      });
                                                  }
                                              }];
}

#pragma mark - textfield delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentUnsendMessageContent = textField.text.copy;
    textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self sendMessage];
    return YES;
}

#pragma mark - private

- (void)fakeRequestMessageFromRemote {
    // replace real network requests with read messages from local persistence
    NSArray<TWMessage *> *messages = [self sortedMessages];
    
    if (messages.count > 0) {
        [self.viewController renderMessages:messages];
    }
}

- (void)pullLatestMessagesFromRemote {
    [self fakePullLatestMessageFromRemote];
}

- (void)fakePullLatestMessageFromRemote {
    [TWEndpointAPIManager pullLatestDirectMessage:@{
                                                    @"dialogueId" : self.viewController.dialogue.dialogueId ?: @"",
                                                    @"senderId" : self.viewController.dialogue.recipient.userId ?: @"",
                                                    @"receiverId" : TWGlobalConfiguration.sharedConfiguration.currentUser.userId ?: @""
                                                    } completion:^(NSError *error, NSDictionary *response) {
                                                        if (error) {
                                                            return;
                                                        }
                                                        
                                                        // mock scenario
                                                        NSString *latestMessageContent = response[@"text"];
                                                        NSString *messageSenderId = response[@"senderId"];
                                                        NSString *messageReceiverId = response[@"receiverId"];
                                                        
                                                        if ([TWUtils stringIsEmpty:latestMessageContent] || [TWUtils stringIsEmpty:messageSenderId] || [TWUtils stringIsEmpty:messageReceiverId]) {
                                                            return;
                                                        }
                                                        
                                                        NSSet<TWUser *> *selectedSenders = (NSSet<TWUser *> *)[TWPersistingManager.sharedManager selectObjects:TWUser.class predicate:[NSPredicate predicateWithFormat:@"userId = %@", messageSenderId]];
                                                        NSSet<TWUser *> *selectedReceivers = (NSSet<TWUser *> *)[TWPersistingManager.sharedManager selectObjects:TWUser.class predicate:[NSPredicate predicateWithFormat:@"userId = %@", messageReceiverId]];
                                                        
                                                        TWUser *sender;
                                                        TWUser *receiver;
                                                        if (selectedSenders.count == 1) {
                                                            sender = selectedSenders.anyObject;
                                                        }
                                                        
                                                        if (selectedReceivers.count == 1) {
                                                            receiver = selectedReceivers.anyObject;
                                                        }
                                                        
                                                        if (!sender || !receiver) {
                                                            return;
                                                        }
                                                        
                                                        TWTextMessage *textMessage = [[TWTextMessage alloc] init];
                                                        textMessage.sender = sender;
                                                        textMessage.receiver = receiver;
                                                        textMessage.messageType = @(TWPlainTextMessageType);    // for now, always plain text type
                                                        textMessage.timestamp = [NSDate date];
                                                        textMessage.messageUniqueIdentifier = NSUUID.UUID.UUIDString;
                                                        textMessage.textMessageContent = latestMessageContent;
                                                        
                                                        self.viewController.dialogue.lastMessage.readStatus = @(YES);
                                                        
                                                        NSMutableSet *messages = [[NSMutableSet alloc] initWithSet:self.viewController.dialogue.messages];
                                                        [messages addObject:textMessage];
                                                        
                                                        self.viewController.dialogue.messages = messages.copy;
                                                        
                                                        [TWPersistingManager.sharedManager insertObject:textMessage];
                                                        [TWPersistingManager.sharedManager updateObject:self.viewController.dialogue];
                                                        [TWPersistingManager.sharedManager save];
                                                        
                                                        [self.viewController renderMessages:[self sortedMessages]];
                                                    }];
}

- (NSArray<TWMessage *> *)sortedMessages {
    NSSortDescriptor *sortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    return [self.viewController.dialogue.messages sortedArrayUsingDescriptors:@[sortDesciptor]];
}

@end
