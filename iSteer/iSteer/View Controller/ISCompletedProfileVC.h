//
//  ISCompletedProfileVC.h
//  iSteer
//
//  Created by EL Capitan on 27/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIUtility.h"
#import "AppData.h"
#import "AppDelegate.h"
#import "ISCurrentUserData.h"

@interface ISCompletedProfileVC : UIViewController <UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePic;

@property (weak, nonatomic) IBOutlet UITextField *txtNickName;

- (IBAction)btnNextClicked:(id)sender;

@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, strong) NSString *countryCode;

@end
