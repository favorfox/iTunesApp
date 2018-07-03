//
//  ICEventRequestDetailVC.h
//  iSteer
//
//  Created by EL Capitan on 21/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISRequestTextPopUpVC.h"
#import "BIZPopupViewController.h"
#import "ISRequestTextModelClass.h"
#import "ISDueDateModel.h"
#import "ISDestinationAddressModel.h"
#import "ISSourceAddressModel.h"
#import "ISContactNumberModel.h"
#import "ISRequestDataModel.h"
#import "APIUtility.h"
#import "AppData.h"

@protocol  ICEventRequestDetailDelegate<NSObject>

@required
- (void) userManipulateEventRequest;

@end

@interface ICEventRequestDetailVC : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestAcceptMessageViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *lblSelectTimeText;

@property (weak, nonatomic) IBOutlet UILabel *lblSelectTime;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestAcceptedBy;

@property (weak, nonatomic) IBOutlet UIView *textViewBGView;

@property (weak, nonatomic) IBOutlet UITextView *txtCurrentUserRequestAcceptText;

@property (weak, nonatomic) IBOutlet UITextView *txtOtherUserRequestAcceptText;

@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;

@property (weak, nonatomic) IBOutlet UIView *viewAcceptRejectRequest;

@property (weak, nonatomic) IBOutlet UIView *viewOtherUserAcceptText;

@property (weak, nonatomic) IBOutlet UIView *viewCurrentUserAcceptText;

@property (weak, nonatomic) IBOutlet UITextView *txtEventTask;

@property (assign, nonatomic) NSInteger eventRequestType;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;

@property (weak, nonatomic) IBOutlet UIView *acceptMsgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aceeptMsgViewHeight;
@property (weak, nonatomic) IBOutlet UIView *textViewContainerView;
@property (weak, nonatomic) IBOutlet UITextView *textViewAcceptMsg;

@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePIcker;

- (IBAction)btnSaveEditRequestClicked:(id)sender;
- (IBAction)btnAcceptRequestClicked:(id)sender;
- (IBAction)btnRejectRequestClicked:(id)sender;
- (IBAction)btnSaveClicked:(id)sender;

@property (nonatomic, strong) ISRequestDataModel *requestData;

@property (nonatomic, weak) id <ICEventRequestDetailDelegate> delegate;

@property (nonatomic, assign) BOOL isFromNotification;
@property (nonatomic, strong) NSString *request_id;

@end
