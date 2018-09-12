//
//  TWFollowerListViewModel.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWFollowerListAction.h"
#import "TWEndpointAPIManager+FollowerListRequest.h"
#import "TWUtils.h"
#import "TWAuthorizationManager.h"
#import "NSArray+TWExtension.h"
#import "TWGlobalConfiguration.h"
#import "TWPersistingManager.h"

@interface TWFollowerListAction ()

@property (nonatomic, weak, readwrite) TWFollowerListViewController *viewController;

@end

@implementation TWFollowerListAction

- (instancetype)initWithViewController:(TWFollowerListViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)fetchFollowers {
    if (!TWAuthorizationManager.sharedManager.isAuthorized) {
        [TWAuthorizationManager.sharedManager requestAuth:^(BOOL success) {
            if (success) {
                [self _fetchFollowers];
            } else {
                // error handling
                [self.viewController displayNetworkErrorAlert];
            }
        }];
    } else {
        [self _fetchFollowers];
    }
}

// this method is designed as a handle for switch between host users, to fetch specific followers, and generate corresponding dialogues, because I have not retrieved keys from Twitter, so this method is commented out and do nothing.
- (void)changeCurrentUserWith:(NSString *)userId {
//    NSSet *selectedUser = [TWPersistingManager.sharedManager selectObjects:TWUser.class predicate:[NSPredicate predicateWithFormat:@"userId = %@", userId]];
//    if (selectedUser.count == 1) {
//        TWGlobalConfiguration.sharedConfiguration.currentUser = selectedUser.anyObject;
//    } else {
//        // search the user by request API endpoint, create user model, persist it.
//        // this
//    }
//
//    [self _fetchFollowers];
}

#pragma mark - private

- (void)_fetchFollowers {
    [TWEndpointAPIManager fetchFollowerList:@{@"user_id" : TWGlobalConfiguration.sharedConfiguration.currentUser.userId ?: @""} completion:^(NSError *error, NSDictionary *data) {
        // because of mock data, the response data will be nil, I have to comment them out.
        if (error || !data) {
            return;
        }
        
        
        NSArray<NSDictionary *> *rawUsers = data[@"users"];
        if ([rawUsers isKindOfClass:NSArray.class]) {
            NSArray<TWUser *> *followers = [self followersFromRawUsers:rawUsers];
            NSArray<TWDialogue *> *dialogues = [self dialoguesFromFollowers:followers timeline:YES];
            [self.viewController renderDialogues:dialogues];
            
            // for previewing messaging content could be updated status on the follower list cell, we should request check the latest messages hear,
            // because of the mocks, self.requestLatestMessagesFor(dialogues) does nothing
            NSArray<TWDialogue *> *dialoguesShouldCheckUpdates = [dialogues tw_filter:^BOOL(TWDialogue * _Nonnull dialogue) {
                return dialogue.messages.count != 0;
            }];
            
            [self requestLatestMessagesFor:dialoguesShouldCheckUpdates];
        }
    }];
}

- (void)requestLatestMessagesFor:(NSArray<TWDialogue *> *)dialogues {
    // request latest messages by requesting message list by talkTo user userId,
    // then filter those messages which not existed in current dialogue messages,
    // appending them to dialogue.messages, and assign the last message to dialogue.lastMessage,
    // last, sort dialogues by their last message date desecently, and refresh the view
    //
    // for this fake twitter direct messaging app, do nothing.
}

#pragma mark - utils

- (NSArray<TWUser *> *)followersFromRawUsers:(NSArray<NSDictionary *> *)rawUsers {
    NSMutableArray<TWUser *> *users = [[NSMutableArray alloc] init];
    for (NSDictionary *rawUser in rawUsers) {
        if ([rawUser isKindOfClass:NSDictionary.class]) {
            NSString *userId = rawUser[@"id_str"];
            
            NSSet<TWUser *> *selectedUser = (NSSet<TWUser *> *)[TWPersistingManager.sharedManager selectObjects:TWUser.class predicate:[NSPredicate predicateWithFormat:@"userId = %@", userId]];
            // if exist, update it
            if (selectedUser.count == 1) {
                TWUser *userModel = selectedUser.anyObject;
                
                [userModel parseFromDict:rawUser];
                [users addObject:userModel];
                [TWPersistingManager.sharedManager updateObject:userModel];
            } else {
                // if not exist, create a user accroding to rawUser
                TWUser *userModel = [[TWUser alloc] init];
                
                [userModel parseFromDict:rawUser];                
                [users addObject:userModel];
                [TWPersistingManager.sharedManager insertObject:userModel];
            }
        }
    }
    
    [TWPersistingManager.sharedManager save];
    
    return users.copy;
}

- (NSArray<TWDialogue *> *)dialoguesFromFollowers:(NSArray<TWUser *> *)followers timeline:(BOOL)timelineMode {
    NSMutableArray<TWDialogue *> *dialogues = [[NSMutableArray alloc] init];
    
    for (TWUser *follower in followers) {
        NSString *dialogueId = [TWDialogue calculateDialogIdFromPeer:TWGlobalConfiguration.sharedConfiguration.currentUser recipient:follower];
        
        NSSet<TWDialogue *> *selectedDialogues = (NSSet<TWDialogue *> *)[TWPersistingManager.sharedManager selectObjects:TWDialogue.class predicate:[NSPredicate predicateWithFormat:@"dialogueId = %@", dialogueId]];
        if (selectedDialogues.count == 1) {
            TWDialogue *selectedDialogue = selectedDialogues.anyObject;
            selectedDialogue.recipient = follower;
            
            [dialogues addObject:selectedDialogue];
            [TWPersistingManager.sharedManager updateObject:selectedDialogue];
        } else {
            TWDialogue *dialogue = [[TWDialogue alloc] initWithUserPeer:TWGlobalConfiguration.sharedConfiguration.currentUser recipient:follower];
            dialogue.recipient = follower;
            
            [dialogues addObject:dialogue];
            [TWPersistingManager.sharedManager insertObject:dialogue];
        }
    }
    
    [TWPersistingManager.sharedManager save];
    
    if (timelineMode) {
        dialogues = [[dialogues sortedArrayUsingComparator:^NSComparisonResult(TWDialogue * _Nonnull dialogue1, TWDialogue *  _Nonnull dialogue2) {
            if (dialogue1.lastMessage.timestamp && dialogue2.lastMessage.timestamp) {
                return [dialogue1.lastMessage.timestamp compare:dialogue2.lastMessage.timestamp] != NSOrderedDescending;
            } else if (dialogue1.lastMessage && !dialogue2.lastMessage) {
                return NSOrderedAscending;
            } else if (dialogue2.lastMessage && !dialogue1.lastMessage) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }] copy];
    }
    
    return dialogues;
}

@end
