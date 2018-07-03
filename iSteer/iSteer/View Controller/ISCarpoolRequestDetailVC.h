//
//  ISCarpoolRequestDetailVC.h
//  iSteer
//
//  Created by EL Capitan on 20/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIZPopupViewController.h"
#import "ISRequestTextPopUpVC.h"
#import "ISRequestTextModelClass.h"
#import "ISDueDateModel.h"
#import "ISDestinationAddressModel.h"
#import "ISSourceAddressModel.h"
#import "ISContactNumberModel.h"
#import "ISRequestDataModel.h"
#import "AppData.h"
#import "APIUtility.h"
#import "ISLocalContactVC.h"

@protocol ISCarpoolRequestDetailDelegate <NSObject>

@required
- (void) userManipulateCarpoolRequest;

@end

@interface ISCarpoolRequestDetailVC : UIViewController<UITextViewDelegate,ISLocalContactVCDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestAcceptMessageViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *lblSelectType;

@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolWho;
@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolPhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolFrom;
@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolTo;

@property (weak, nonatomic) IBOutlet UITextView *txtOtherUserRequestAcceptText;

@property (weak, nonatomic) IBOutlet UITextView *txtCurrentUserRequestAcceptText;

@property (weak, nonatomic) IBOutlet UILabel *lblSelectTimeText;

@property (weak, nonatomic) IBOutlet UILabel *lblSelectTime;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestAcceptedBy;

@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;

@property (weak, nonatomic) IBOutlet UIView *viewAcceptRejectRequest;

@property (weak, nonatomic) IBOutlet UIView *viewOtherUserAcceptText;

@property (weak, nonatomic) IBOutlet UIView *viewCurrentUserAcceptText;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;

@property (weak, nonatomic) IBOutlet UIButton *btnAceept;
@property (assign, nonatomic) NSInteger carpoolRequestType;

@property (weak, nonatomic) IBOutlet UIView *viewAcceptMsg;
@property (weak, nonatomic) IBOutlet UIView *viewAcceptMsgContainer;
@property (weak, nonatomic) IBOutlet UITextView *textViewAceeptMsg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAcceptMsgHeight;

@property (weak, nonatomic) IBOutlet UIDatePicker *carpoolDatepicker;

@property (weak, nonatomic) IBOutlet UIButton *btnWho;

- (IBAction)btnSaveEditRequestClicked:(id)sender;

- (IBAction)btnAcceptRequestClicked:(id)sender;
- (IBAction)btnRejectRequestClicked:(id)sender;

- (IBAction)btnSaveClicked:(id)sender;

- (IBAction)btnWhoClicked:(id)sender;

@property (nonatomic, strong) ISRequestDataModel *requestData;

@property (nonatomic, weak) id <ISCarpoolRequestDetailDelegate> delegate;

@property (nonatomic, assign) BOOL isFromNotification;
@property (nonatomic, strong) NSString *request_id;

@property (nonatomic, strong) NSString *selectedName;

@property (nonatomic, strong) NSString *selectedContactNumber;

@end
