//
//  ISSettingVC.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "ISWelcomeVC.h"
#import "ISCurrentUserData.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface ISSettingVC : UIViewController <UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtNickName;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfilePic;
@property (strong,nonatomic) ISGroupMemberDataModel *profileInfo;

@property (nonatomic, assign) BOOL isFromGroupInfo;
- (IBAction)btnLogOutClicked:(id)sender;

@end
