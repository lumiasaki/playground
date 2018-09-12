//
//  TWFollowerListViewController.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWFollowerListViewController.h"
#import "TWFollowerListCell.h"
#import "TWFollowerListAction.h"
#import "TWTextMessage.h"
#import "TWMessagingViewController.h"
#import "TWUtils.h"
#import "TWGlobalConfiguration.h"
#import "TWUser+Rendering.h"
#import "UIImageView+DownLoadImage.h"

static NSString *const FOLLOWER_CELL_REUSE_IDENTIFIER = @"TWFollowerListCellIdentifier";

@interface TWFollowerListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *followerListTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSArray<TWDialogue *> *dialogues;
@property (nonatomic, strong) TWFollowerListAction *dispatchAction;

@end

@implementation TWFollowerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self animateActivityIndicator:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.dispatchAction fetchFollowers];
}

- (void)renderDialogues:(NSArray<TWDialogue *> *)dialogues {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![dialogues isKindOfClass:NSArray.class]) {
            return;
        }
                
        [self animateActivityIndicator:NO];
        
        self.dialogues = dialogues;
        [self.followerListTableView reloadData];
    });
}

- (void)displayNetworkErrorAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Network Error"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - actions

- (IBAction)changeCurrentUserPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Search User ID"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"User ID";
    }];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.dispatchAction changeCurrentUserWith:alertController.textFields.firstObject.text];
    }];
    
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dialogues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWFollowerListCell *cell = [tableView dequeueReusableCellWithIdentifier:FOLLOWER_CELL_REUSE_IDENTIFIER];
    
    // clean the cell
    cell.avatarImageView.image = nil;
    cell.nameLabel.text = @"";
    cell.lastMessageDateLabel.text = @"";
    cell.contentPreviewLabel.text = @"";
    
    // ignore the beyond array bounds checks.
    TWDialogue *dialogue = self.dialogues[indexPath.row];
    
    if ([dialogue.recipient isKindOfClass:TWUser.class]) {        
        cell.nameLabel.attributedText = [dialogue.recipient nameAttributeString];
        [cell.avatarImageView tw_setImageUrl:dialogue.recipient.profileUrl];
    }
    
    if ([dialogue.lastMessage isKindOfClass:TWMessage.class]) {
        cell.lastMessageDateLabel.text = [TWUtils formattedDateString:dialogue.lastMessage.timestamp format:@"yyyy/MM/dd"];
        
        if ([dialogue.lastMessage.messageType isEqualToNumber:@(TWPlainTextMessageType)]) {
            NSString *previewContentPrefix = @"";
            if ([dialogue.lastMessage.sender.userId isEqualToString:TWGlobalConfiguration.sharedConfiguration.currentUser.userId]) {
                previewContentPrefix = @"You: ";
            }
            
            cell.contentPreviewLabel.text = [NSString stringWithFormat:@"%@%@", previewContentPrefix, ((TWTextMessage *)dialogue.lastMessage).textMessageContent];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];        
}

#pragma mark - private

- (void)animateActivityIndicator:(BOOL)animate {
    if (animate) {
        [self.loadingIndicator startAnimating];
    } else {
        [self.loadingIndicator stopAnimating];
    }
    
    self.loadingIndicator.hidden = !animate;
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToMessagingVC"]) {
        TWMessagingViewController *messagingViewController = segue.destinationViewController;
        if ([messagingViewController isKindOfClass:TWMessagingViewController.class]) {
            TWDialogue *selectedDialogue = self.dialogues[self.followerListTableView.indexPathForSelectedRow.row];  // if crashed because of beyond of bounds exception, it's a bug, must find the reason.
                        
            messagingViewController.navigationItem.title = selectedDialogue.recipient.screenName;
            [messagingViewController setValue:selectedDialogue forKey:@"dialogue"];
        }
    }
}

#pragma mark - getter

- (TWFollowerListAction *)dispatchAction {
    if (!_dispatchAction) {
        _dispatchAction = [[TWFollowerListAction alloc] initWithViewController:self];
    }
    return _dispatchAction;
}

@end
