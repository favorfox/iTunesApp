//
//  ISWelcomeVC.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISVerificationVC.h"
#import "CountryListViewController.h"
#import "BIZPopupViewController.h"
#import "Constants.h"
#import "APIUtility.h"
#import "SVProgressHUD.h"
#import "ISCurrentUserData.h"
@interface ISWelcomeVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtCountyCode;
@property (weak, nonatomic) IBOutlet UITextField *txtMobileNumber;

- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnCountryCodeClicked:(id)sender;

@end
