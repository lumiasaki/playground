//
//  TWDialogue.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWBaseModel.h"
#import "TWMessage.h"
#import "TWUser.h"

// a dialogue represents messages between peers, it mainly contains messages, and the participants, in this case, i just simply use the userIds and create_time of participants to generate the dialogueId, but in real case should use more strict method to generate it.
@interface TWDialogue : TWBaseModel

@property (nonatomic, strong) NSSet<TWMessage *> *messages;
@property (nonatomic, strong) NSString *dialogueId;
@property (nonatomic, strong) TWUser *recipient;    // opposite to current user

- (instancetype)initWithUserPeer:(TWUser *)host recipient:(TWUser *)recipient;

+ (NSString *)calculateDialogIdFromPeer:(TWUser *)host recipient:(TWUser *)recipient;

// for convenience and efficiency purpose
- (TWMessage *)lastMessage;

@end
