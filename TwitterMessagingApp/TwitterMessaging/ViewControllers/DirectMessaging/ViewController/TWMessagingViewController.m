//
//  TWMessagingViewController.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWMessagingViewController.h"
#import "TWMessagingAction.h"
#import "TWGlobalConfiguration.h"
#import "TWUtils.h"
#import "TWMessageRenderer.h"

static NSString *const TEXT_MESSAGE_HOST_CELL_IDENTIFIER = @"TWMessagingHostCellIdentifier";
static NSString *const TEXT_MESSAGE_RECIPIENT_CELL_IDENTIFIER = @"TWMessagingRecipientCellIdentifier";

@interface TWMessagingViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messagingTableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextFieldContainerBottomConstraint;

@property (nonatomic, strong) TWMessagingAction *dispatchAction;
@property (nonatomic, strong) NSArray<TWMessage *> *messages;

@end

@implementation TWMessagingViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    
    [self.dispatchAction requestMessagesFromRemote];
    [self setUpNotifications];
}

- (void)renderMessages:(NSArray<TWMessage *> *)messages {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messages = messages;
        [self.messagingTableView reloadData];
        [self.messagingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}

#pragma mark - actions

- (IBAction)sendButtonPressed:(UIButton *)sender {
    [self.messageTextField endEditing:YES];    
    [self.dispatchAction sendMessage];
}

#pragma mark - tableview delegate & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWMessage *message = self.messages[indexPath.row];
    
    UITableViewCell<TWMessageRenderer> *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifierFrom(message)];
    
    if ([cell conformsToProtocol:@protocol(TWMessageRenderer)]) {
        [message renderInRenderer:cell];
    }
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.messageTextField resignFirstResponder];
}

#pragma mark - textfield delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.messageTextField resignFirstResponder];
    [self.dispatchAction textFieldDidEndEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.messageTextField resignFirstResponder];
    return [self.dispatchAction textFieldShouldReturn:textField];
}

#pragma mark - private

- (void)setUpNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self changeMessageTextFieldBottomConstraintWhenKeyboardWith:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self changeMessageTextFieldBottomConstraintWhenKeyboardWith:notification];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    [self changeMessageTextFieldBottomConstraintWhenKeyboardWith:notification];
}

- (void)changeMessageTextFieldBottomConstraintWhenKeyboardWith:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo isKindOfClass:NSDictionary.class]) {
        NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        NSUInteger curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        CGFloat marginToBottom = UIScreen.mainScreen.bounds.size.height - [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
        
        self.messageTextFieldContainerBottomConstraint.constant = marginToBottom;
        [UIView animateWithDuration:duration delay:0 options:(curve | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            if (self.messages.count > 0) {
                [self.messagingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

static NSString *cellReuseIdentifierFrom(TWMessage *message) {
    switch (message.messageType.integerValue) {
        case TWPlainTextMessageType:
        {
            if ([message.sender.userId isEqualToString:TWGlobalConfiguration.sharedConfiguration.currentUser.userId]) {
                return TEXT_MESSAGE_HOST_CELL_IDENTIFIER;
            }
            
            return TEXT_MESSAGE_RECIPIENT_CELL_IDENTIFIER;
        }
        default:
            // should never reach here
            assert(false);
            return nil;
    }
}

#pragma mark - getters

- (TWMessagingAction *)dispatchAction {
    if (!_dispatchAction) {
        _dispatchAction = [[TWMessagingAction alloc] initWithViewController:self];
    }
    return _dispatchAction;
}

@end
