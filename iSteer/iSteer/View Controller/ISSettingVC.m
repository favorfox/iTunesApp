//
//  ISSettingVC.m
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISSettingVC.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface ISSettingVC ()
{
    NSMutableArray *coreDataTables;
}
@end

#pragma mark -  Variable

ISCurrentUserData *currentUser;
UIBarButtonItem *editBarButton;
UITapGestureRecognizer *imageTapGesture;
UIImagePickerController *imagePicker;
bool isProfilePicUpdated = false;

@implementation ISSettingVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    
    if (self.isFromGroupInfo)
    {
        self.navigationItem.title = @"Profile";
        self.btnLogout.hidden = YES;
        self.notificationView.hidden = YES;
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 40, 40)];
        [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
        
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
        
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] init];
        leftBarButton.customView = backButton;
        
        self.navigationItem.leftBarButtonItem = leftBarButton;
    }
    else
    {
        self.navigationItem.title = @"SETTING";
        
        editBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_edit_white"] style:UIBarButtonItemStylePlain target:self action:@selector(editProfileButtonClicked)];
        self.navigationItem.rightBarButtonItem = editBarButton;
        self.btnLogout.hidden = NO;
        self.notificationView.hidden = NO;
    }

    self.imgUserProfilePic.layer.cornerRadius = self.imgUserProfilePic.layer.frame.size.width/2;
    self.imgUserProfilePic.clipsToBounds = true;
    
    imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatePic)];
    imageTapGesture.delegate = self;
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    coreDataTables = [[NSMutableArray alloc]initWithObjects:@"Tbl_ArchivedRequest",@"Tbl_Contact",@"Tbl_groups",@"Tbl_Request",  nil];
    [self setProfileData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) backButtonClicked {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Button Action

- (void) editProfileButtonClicked {
    editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfileButtonClicked)];
    self.navigationItem.rightBarButtonItem = editBarButton;
    
    [self.imgUserProfilePic addGestureRecognizer:imageTapGesture];
    self.imgUserProfilePic.userInteractionEnabled = YES;

    self.txtNickName.enabled = true;
}

- (void) saveProfileButtonClicked {
    
    if([self.txtNickName.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter Nick Name"];
    }
    else {
        [self updateProfileAPICall];
        editBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_edit_white"] style:UIBarButtonItemStylePlain target:self action:@selector(editProfileButtonClicked)];
        self.navigationItem.rightBarButtonItem = editBarButton;
        
        [self.imgUserProfilePic removeGestureRecognizer:imageTapGesture];
        
        self.txtNickName.enabled = false;
    }
}

- (IBAction)btnLogOutClicked:(id)sender {
//    [[AppData sharedInstance] removeUserData];
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate logOutUser];\
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logOutAPICall];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void) updatePic {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
    }];
    
    UIAlertAction *galleryActionAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelActionAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:galleryActionAction];
    [alert addAction:cancelActionAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - Custom Methods

- (void) setProfileData {
    
    if (self.isFromGroupInfo)
    {
        
        self.txtNickName.text = self.profileInfo.nick_name;
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,self.profileInfo.profile_picture];
        [self.imgUserProfilePic sd_setImageWithURL:[NSURL URLWithString:imageString]
                                  placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]options:SDWebImageRefreshCached];
    }
    else
    {
        currentUser = [[AppData sharedInstance] getCurrentUserData];
        self.txtNickName.text = currentUser.userNickName;
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,currentUser.userProfilePic];
        [self.imgUserProfilePic sd_setImageWithURL:[NSURL URLWithString:imageString]
                                  placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]options:SDWebImageRefreshCached];
    }
    
    
//    [self.imgUserProfilePic ]
    
    //[self.imgUserProfilePic clearImageCacheForURL:[NSURL URLWithString:imageString]];
    
    //    [self.imgGroupIcon clearImageCacheForURL:[NSURL URLWithString:imageString]];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageString]];
//    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    
    
//    [self.imgUserProfilePic setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//        self.imgUserProfilePic.image = image;
//    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//        self.imgUserProfilePic.image = [UIImage imageNamed:@"ic_user_placeholder"];
//    }];

}

#pragma mark - UIPickerControll Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    isProfilePicUpdated = true;
    
    self.imgUserProfilePic.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Update Profile API Call

- (void) updateProfileAPICall {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Updating"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    

    NSString *user_id = [[AppData sharedInstance] getUserId];
    NSString *nickName = self.txtNickName.text;
    
    if(isProfilePicUpdated) {
        
        UIImage *image = self.imgUserProfilePic.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(200,200));//Beign image context
        [image drawInRect:CGRectMake(0, 0, 200, 200)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.1);
        
        NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
            NSDictionary *param = @{@"user_id":user_id,@"nick_name":nickName,@"profile_picture":imageString};
            
            [APIUtility servicePostToEndPoint:UpdateProfile withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
                [SVProgressHUD dismiss];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                if(isSuccess) {
                    
                    if(response != nil) {
                        NSLog(@"%@",response);
                        
                        NSString *status = [response valueForKey:@"status"];
                        NSString *message = [response valueForKey:@"message"];
                        
                        if([status isEqualToString:@"1"]) {
                            NSArray *data = [response valueForKey:@"User"];
                            
                            if(data.count > 0) {
                                NSDictionary *dataDict = [data objectAtIndex:0];
                                
                                [[AppData sharedInstance] saveUserData:dataDict];
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
    else {
        
        NSDictionary *param = @{@"user_id":user_id,@"nick_name":nickName};
        [APIUtility servicePostToEndPoint:UpdateProfile withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
            
            [SVProgressHUD dismiss];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if(isSuccess) {
               
                if(response != nil) {
                    NSLog(@"%@",response);
                    
                    NSString *status = [response valueForKey:@"status"];
                    NSString *message = [response valueForKey:@"message"];
                    
                    if([status isEqualToString:@"1"]) {
                        NSArray *data = [response valueForKey:@"User"];
                        
                        if(data.count > 0) {
                            NSDictionary *dataDict = [data objectAtIndex:0];
                            
                            [[AppData sharedInstance] saveUserData:dataDict];
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
}

#pragma mark - Logout

- (void) logOutAPICall {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging Out.."];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    NSString *user_id = [[AppData sharedInstance] getUserId];
    NSDictionary *param = @{@"user_id":user_id};
    
    [APIUtility servicePostToEndPoint:Logout withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(isSuccess) {
            
            
            
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [[AppData sharedInstance] removeUserData];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate logOutUser];
                    [self deleteRecordFromLocal];
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

- (NSString *)imageToNSString:(UIImage *)image
{
    NSData* imageData = UIImageJPEGRepresentation(image, 0.5);
//    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)deleteRecordFromLocal
{
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSString *tableName in coreDataTables)
    {
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:tableName inManagedObjectContext:context]];
        [allContacts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSError *error = nil;
        NSArray *Contacts = [context executeFetchRequest:allContacts error:&error];
        //error handling goes here
        for (NSManagedObject *Contact in Contacts) {
            [context deleteObject:Contact];
        }
        NSError *saveError = nil;
        [context save:&saveError];
    }
   
}


@end