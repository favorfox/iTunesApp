//
//  ISWelcomeVC.m
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISWelcomeVC.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "CountryListDataSource.h"
@interface ISWelcomeVC ()

@end

#pragma mark - Life Cycle

@implementation ISWelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    
    CountryListDataSource *dataSource = [[CountryListDataSource alloc] init];
    NSArray *dataRows = [dataSource countries];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    
    for (NSDictionary *dataDic in dataRows)
    {
        if ([countryCode isEqualToString:[dataDic valueForKey:@"code"]])
        {
            self.txtCountyCode.text = [dataDic valueForKey:@"dial_code"];
            NSLog(@"%@",[dataDic valueForKey:@"dial_code"]);
            NSLog(@"%@",[dataDic valueForKey:@"code"]);
            break;
        }
    }
    
    //NSLog(@"%@",[diallingCodesArray valueForKey:[countryCode lowercaseString]]);
    
    [self setTextFieldPadding];
    
//    ISCurrentUserData *currentUser = [[AppData sharedInstance] getCurrentUserData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewWillAppear:(BOOL)animated{
   [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark - Button Action

- (IBAction)btnNextClicked:(id)sender {
    
    [self.view endEditing:true];

    NSString *errorMessage = @"";

    if([self.txtCountyCode.text  isEqual: @""]) {
        errorMessage = @"Please select country code";
    }    else if([self.txtMobileNumber.text  isEqual: @""]) {
        errorMessage = @"Please enter mobile number";
    }
    else if(self.txtMobileNumber.text.length != 10) {
        errorMessage = @"Please enter valid mobile number";
    }
    
    if([errorMessage isEqualToString:@""]) {
        [self sendConfirmationCodeAPI];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FavorFox" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:true completion:nil];
    }
}

- (IBAction)btnCountryCodeClicked:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    
//    BIZPopupViewController *popupViewController = [[BIZPopupViewController alloc] initWithContentViewController:cv contentSize:CGSizeMake(300, 400)];
    
    [self presentViewController:cv animated:YES completion:nil];
}

#pragma mark - CountryListViewController Delegate

- (void)didSelectCountry:(NSDictionary *)country {
    NSString *dialCode = [country valueForKey:@"dial_code"];
    self.txtCountyCode.text = dialCode;
}

#pragma mark - Custom Methods

- (void) setTextFieldPadding {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtMobileNumber.leftView = paddingView;
    self.txtMobileNumber.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - SendConfirmationCode API

- (void) sendConfirmationCodeAPI {
    
    NSString *countryCode = self.txtCountyCode.text;
    NSString *mobileNumber = self.txtMobileNumber.text;
    NSString *sms_mode = SMS_Mode;
    
    NSString *countryCodeWithOutPlus = [countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSDictionary *param = @{@"contact_number":mobileNumber,@"country_code":countryCodeWithOutPlus,@"sms_mode":sms_mode};
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Loading"];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [APIUtility servicePostToEndPoint:SendConfirmationCode withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        [SVProgressHUD dismiss];

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if(isSuccess) {
            
            NSLog(@"%@",response);
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [response valueForKey:@"message"];
            if([status  isEqual: @"1"]) {
                NSString *is_newuser = [response valueForKey:@"is_newuser"];
                
                if([is_newuser  isEqual: @"NO"]) {
                    NSArray *data = [response valueForKey:@"data"];
                    
                    if(data.count > 0) {
                        NSDictionary *dataDict = [data objectAtIndex:0];
                        [[AppData sharedInstance] saveUserData:dataDict];
                    }
                }
                NSString *verificationCode_request_id = [response valueForKey:@"verificationCode_request_id"];
                ISVerificationVC *verificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISVerificationVC"];
                
                verificationVC.verificationCode_request_id = verificationCode_request_id;
                verificationVC.countryCode = countryCode;
                NSLog(@"%@",countryCode);
                verificationVC.mobileNumber = mobileNumber;
                [self.navigationController pushViewController:verificationVC animated:true];
                
            }
            else if([status  isEqual: @"3"]) {
                [AppData displayAlert:message];
            }
            else if([status  isEqual: @"10"]) {
                [AppData displayAlert:message];
            }
            else {
                [AppData displayAlert:message];
            }
        }
        else {
            if(error != nil) {
                [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
                NSLog(@"%@",error.localizedDescription);
            }
        }
    }];
}

@end
