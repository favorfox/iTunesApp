//
//  ISCompletedProfileVC.m
//  iSteer
//
//  Created by EL Capitan on 27/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISCompletedProfileVC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ISCompletedProfileVC ()

@end

UITapGestureRecognizer *profileImageTapGesture;
UIImagePickerController *profileImagePicker;
bool isNewProfilePicUpdated = false;

@implementation ISCompletedProfileVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.layer.frame.size.width/2;
    self.imgProfilePic.clipsToBounds = true;
    
    profileImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatePic)];
    profileImageTapGesture.delegate = self;
    
    profileImagePicker = [[UIImagePickerController alloc] init];
    profileImagePicker.delegate = self;
    profileImagePicker.allowsEditing = YES;

    [self.imgProfilePic addGestureRecognizer:profileImageTapGesture];
    self.imgProfilePic.userInteractionEnabled = YES;
    
    isNewProfilePicUpdated = false;
    
    [self setProfileData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillAppear:(BOOL)animated{
   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
#pragma mark - Button Action
- (void) updatePic {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera]) {
            profileImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:profileImagePicker animated:YES completion:NULL];
        }
    }];
    
    UIAlertAction *galleryActionAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        profileImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:profileImagePicker animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelActionAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:galleryActionAction];
    [alert addAction:cancelActionAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)btnNextClicked:(id)sender {
    if([self.txtNickName.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter Nick Name"];
    }
    else {
        [self updateProfileAPICall];
    }
}

#pragma mark - UIPickerControll Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    isNewProfilePicUpdated = true;
    
    self.imgProfilePic.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Custom Methods

- (void) setProfileData {
    ISCurrentUserData *currentUser = [[AppData sharedInstance] getCurrentUserData];
    self.txtNickName.text = currentUser.userNickName;
    NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,currentUser.userProfilePic];
    
    //[self.imgProfilePic clearImageCacheForURL:[NSURL URLWithString:imageString]];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageString]];
//    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [self.imgProfilePic sd_setImageWithURL:[NSURL URLWithString:imageString]
                 placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]
                          options:SDWebImageRefreshCached];
    
//    [self.imgProfilePic setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//        self.imgProfilePic.image = image;
//    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//        self.imgProfilePic.image = [UIImage imageNamed:@"ic_user_placeholder"];
//    }];
}

#pragma mark - Update Profile API Call

- (void) updateProfileAPICall {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Updating"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSString *user_id = [[AppData sharedInstance] getUserId];
    NSString *nickName = self.txtNickName.text;
    NSString *imageString = @"";
    if(isNewProfilePicUpdated) {
        UIImage *image = self.imgProfilePic.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(200,200));//Beign image context
        [image drawInRect:CGRectMake(0, 0, 200, 200)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.1);
        
        imageString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    else
    {
        ISCurrentUserData *currentUser = [[AppData sharedInstance] getCurrentUserData];
        self.txtNickName.text = currentUser.userNickName;
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,currentUser.userProfilePic];
    }
    NSString *deviceToken = @"123456";
    
    if([AppData sharedInstance].deviceToken != nil) {
        deviceToken = [AppData sharedInstance].deviceToken;
    }
    
    NSDictionary *param;
    
    if(isNewProfilePicUpdated) {
        param = @{@"contact_number":self.mobileNumber,@"nick_name":nickName,@"device_token":deviceToken,@"device_type":Device_Type,@"profile_picture":imageString,@"is_testdata":Is_Testdata};
    }
    else {
        param = @{@"contact_number":self.mobileNumber,@"nick_name":nickName,@"device_token":deviceToken,@"device_type":Device_Type,@"is_testdata":Is_Testdata};
    }
    
    NSLog(@"%@",param);
    
    [APIUtility servicePostToEndPoint:Register withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        if(isSuccess) {
            
            
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    NSDictionary *dataDict = [response valueForKey:@"data"];
                    
                    [[AppData sharedInstance] saveUserData:dataDict];
                    
                    [[AppData sharedInstance] verifyUser];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate setTabBar];
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

@end
