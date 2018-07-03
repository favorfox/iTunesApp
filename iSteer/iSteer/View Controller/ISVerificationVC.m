//
//  ISVerificationVC.m
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISVerificationVC.h"

@interface ISVerificationVC ()
{
    int count;
    NSTimer *mainTimer;
}
@end

@implementation ISVerificationVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 1200;
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(startTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)startTimer:(NSTimer *)timer {
    //do smth
    if(count > 0){
        int minutes = count / 60;
        int seconds = count % 60;
        [self.btnResend setTitle:[NSString stringWithFormat:@"%d : %d",minutes,seconds] forState:UIControlStateNormal];
        self.btnResend.enabled = NO;
        count--;
    }
    else
    {
        [mainTimer invalidate];
        count = 1200;
        [self.btnResend setTitle:@"Haven't received code yet? Resend" forState:UIControlStateNormal];
        self.btnResend.enabled = YES;
    }
}

#pragma mark - Button Action

- (IBAction)btnPreviousClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnNextClicked:(id)sender {
    [self.view endEditing:true];

    NSString *errorMessage = @"";
    
    if([self.txtVerificationCode.text  isEqual: @""]) {
        errorMessage = @"Please enter verification code";
    }
    
    if([errorMessage isEqualToString:@""]) {
        
        [self validateOTPCode];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FavorFox" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:true completion:nil];
    }
}

- (IBAction)btnResendCodeClicked:(id)sender {
    [self sendConfirmationCodeAPI];
}

#pragma mark - Custom Methods

- (void) validateOTPCode {
    NSString *deviceToken = @"";
    NSString *verificationCode = self.txtVerificationCode.text;
    
    if([AppData sharedInstance].deviceToken != nil) {
        deviceToken = [AppData sharedInstance].deviceToken;
    }
    
    NSDictionary *param = @{@"contact_number":self.mobileNumber,@"country_code":self.countryCode,@"sms_mode":SMS_Mode,@"verification_requestID":self.verificationCode_request_id,@"device_token":deviceToken,@"device_type":Device_Type,@"is_testdata":Is_Testdata,@"verification_code":verificationCode};
    
    NSLog(@"%@",param);
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Validating"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [APIUtility servicePostToEndPoint:ValidateOTPCode withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if(isSuccess) {
            
            if(response != nil) {
                
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];

                if([status isEqualToString:@"1"]) {
                    
                    [[AppData sharedInstance] saveUserCountryCode:self.self.countryCode];
                    
                    NSArray *data = [response valueForKey:@"data"];
                    
                    if(data.count > 0) {
                        NSDictionary *dataDict = [data objectAtIndex:0];
                        
                        [[AppData sharedInstance] saveUserData:dataDict];
                        
                        ISCompletedProfileVC *completeProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISCompletedProfileVC"];
                        completeProfileVC.mobileNumber = self.mobileNumber;
                        completeProfileVC.countryCode = self.countryCode;
                        [self.navigationController pushViewController:completeProfileVC animated:true];
                        
//                        [[AppData sharedInstance] verifyUser];
//                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                        [appDelegate setTabBar];
                    }
                }
                else {
                    [AppData displayAlert:message];
                }
            }
        }
        else{
            NSLog(@"%@",error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
    }];
    
}

#pragma mark - SendConfirmationCode API

- (void) sendConfirmationCodeAPI {
    
    NSString *countryCode = self.countryCode;
    NSString *mobileNumber = self.mobileNumber;
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
            mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(startTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
            [mainTimer fire];
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
                //ISVerificationVC *verificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISVerificationVC"];
                
                self.verificationCode_request_id = verificationCode_request_id;
                self.countryCode = countryCode;
                NSLog(@"%@",countryCode);
                self.mobileNumber = mobileNumber;
                //[self.navigationController pushViewController:verificationVC animated:true];
                
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
            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
            if(error != nil) {
                NSLog(@"%@",error.localizedDescription);
            }
        }
    }];
}

@end
