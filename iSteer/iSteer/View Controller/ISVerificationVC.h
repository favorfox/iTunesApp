//
//  ISVerificationVC.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "APIUtility.h"
#import "SVProgressHUD.h"
#import "ISCompletedProfileVC.h"

@interface ISVerificationVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtVerificationCode;

- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnResendCodeClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (nonatomic, strong) NSString *verificationCode_request_id;
@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, strong) NSString *countryCode;

@end
