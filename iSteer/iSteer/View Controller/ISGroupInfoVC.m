//
//  ISGroupInfoVC.m
//  iSteer
//
//  Created by EL Capitan on 25/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISGroupInfoVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ISSettingVC.h"
@interface ISGroupInfoVC ()

@end

UIBarButtonItem *groupEditBarButton;
UITapGestureRecognizer *groupIconTapGesture;


@implementation ISGroupInfoVC

#pragma mark - Variables

UIImagePickerController *imagePickerObj;
bool isGroupPicSelectedForUpdate = false;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"GROUP INFO";
    
    [self setNavigationButton];
    
    [self setTextFieldPadding];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.tblContactList.dataSource = self;
    self.tblContactList.delegate = self;
    
    self.coreContactListArray = [[NSMutableArray alloc] init];
    self.groupMemberListArray = [[NSMutableArray alloc] init];
    
    imagePickerObj = [[UIImagePickerController alloc] init];
    imagePickerObj.delegate = self;
    imagePickerObj.allowsEditing = YES;
    
    groupIconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatePic)];
    groupIconTapGesture.delegate = self;

    
    self.isGroupDataUpdated = false;
    
    [self setGroupInfoData];
    [self setCornerRadious];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (void) backButtonClicked {
    if(self.isGroupDataUpdated == true) {
        
        [self.delegate updatedGroupObject:self.groupData];
    }
    
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnGroupImageClicked:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera]) {
            imagePickerObj.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerObj animated:YES completion:NULL];
        }
    }];
    
    UIAlertAction *galleryActionAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerObj.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerObj animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelActionAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:galleryActionAction];
    [alert addAction:cancelActionAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void) updatePic {
    [self.view endEditing:true];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera]) {
            imagePickerObj.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerObj animated:YES completion:NULL];
        }
    }];
    
    UIAlertAction *galleryActionAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerObj.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerObj animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelActionAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:galleryActionAction];
    [alert addAction:cancelActionAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void) editGroupButtonClicked {
    groupEditBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveGroupButtonClicked)];
    self.navigationItem.rightBarButtonItem = groupEditBarButton;
    
    [self.imgGroupIcon addGestureRecognizer:groupIconTapGesture];
    self.imgGroupIcon.userInteractionEnabled = YES;
    
    self.txtGroupName.enabled = true;
}

- (void) saveGroupButtonClicked {
    if([self.txtGroupName.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter Group Name"];
    }
    else {
        if([self.txtGroupName.text isEqual:self.groupData.group_name] && !isGroupPicSelectedForUpdate) {
            [self changeSaveGroupButton];
        }
        else if(![self.txtGroupName.text isEqual:self.groupData.group_name]) {
            [self changeGroupNameAPI:self.txtGroupName.text];
        }
        
        if(isGroupPicSelectedForUpdate) {
            [self changeGroupIcon:self.imgGroupIcon.image];
        }
    }
}

#pragma mark - Custom Methods

- (void) setNavigationButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 40, 40)];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
    
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] init];
    leftBarButton.customView = backButton;
    
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    groupEditBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_edit_white"] style:UIBarButtonItemStylePlain target:self action:@selector(editGroupButtonClicked)];
    self.navigationItem.rightBarButtonItem = groupEditBarButton;
}

- (void) setTextFieldPadding {
    UIView *txtGroupNamepaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtGroupName.leftView = txtGroupNamepaddingView;
    self.txtGroupName.leftViewMode = UITextFieldViewModeAlways;
}

- (void) setCornerRadious {
    self.imgGroupIcon.layer.cornerRadius = self.imgGroupIcon.layer.frame.size.width/2;
    self.imgGroupIcon.clipsToBounds = true;
}

- (void) setGroupInfoData {
    
    if(self.groupData != nil) {
        self.groupMemberListArray = [NSMutableArray arrayWithArray:self.groupData.group_members];
        self.txtGroupName.text = self.groupData.group_name;
        
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,self.groupData.group_icon];
        
//        [self.imgGroupIcon setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]];

//        [self.imgGroupIcon clearImageCacheForURL:[NSURL URLWithString:imageString]];
//        
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageString]];
//        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
        [self.imgGroupIcon sd_setImageWithURL:[NSURL URLWithString:imageString]
                          placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]options:SDWebImageRefreshCached];
        
        
//        [self.imgGroupIcon setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//            self.imgGroupIcon.image = image;
//        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//            self.imgGroupIcon.image = [UIImage imageNamed:@"ic_user_placeholder"];
//        }];
    }
    
    self.txtGroupName.enabled = false;
    [self.tblContactList reloadData];
}

- (void) changeSaveGroupButton {
    groupEditBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_edit_white"] style:UIBarButtonItemStylePlain target:self action:@selector(editGroupButtonClicked)];
    self.navigationItem.rightBarButtonItem = groupEditBarButton;
    [self.imgGroupIcon removeGestureRecognizer:groupIconTapGesture];
    self.txtGroupName.enabled = false;
}

- (bool) isAdmin {
    NSString *admin_id = self.groupData.admin_id;
    NSString *current_user_id = [[AppData sharedInstance] getUserId];
    
    long admin_id_long = [admin_id longLongValue];
    long current_user_id_long = [current_user_id longLongValue];
    
    if(admin_id_long == current_user_id_long) {
        return true;
    }
    else {
        return false;

    }
}

#pragma mark - UIPickerControll Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    isGroupPicSelectedForUpdate = true;
    
    self.imgGroupIcon.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self isAdmin]) {
        return self.groupMemberListArray.count + 1;
    }
    
    return self.groupMemberListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0 && [self isAdmin]) {
    
        ISAddMemberTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISAddMemberTableCell" forIndexPath:indexPath];
        return cell;
    }
    else {
        ISContactListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISContactListTableCell" forIndexPath:indexPath];
        
        NSInteger index = 0;
        
        if([self isAdmin]) {
            index = indexPath.row - 1;
        }
        else {
            index = indexPath.row;
        }
        
        ISGroupMemberDataModel *member = [self.groupMemberListArray objectAtIndex:index];
        
        
        NSString *name = [[AppData sharedInstance] fetchContactName:member.user_id];;
        if ([name isEqualToString:@""])
        {
            cell.lblContactFullName.text = member.nick_name;
        }
        else
        {
            cell.lblContactFullName.text = [[AppData sharedInstance] fetchContactName:member.user_id];;
        }
        
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,member.profile_picture];
        
        [cell.imgContactProfilePic setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]];
        
        NSString *admin_id = self.groupData.admin_id;
        NSString *current_user_id = member.user_id;
        
        long admin_id_long = [admin_id longLongValue];
        long current_user_id_long = [current_user_id longLongValue];
        
        if(admin_id_long == current_user_id_long) {
            cell.lblAdmin.hidden = false;
        }
        else {
            cell.lblAdmin.hidden = true;
        }

        
        cell.btnProfileImage.tag = indexPath.row;
        [cell.btnProfileImage addTarget:self action:@selector(btnProfileImageTapped:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0 && [self isAdmin]) {
        ISAddMemberToGroupVC *addMembersToGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISAddMemberToGroupVC"];
        addMembersToGroupVC.groupData = self.groupData;
        addMembersToGroupVC.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addMembersToGroupVC];
        [self presentViewController:navigationController animated:true completion:nil];
    }
    else {
        
        if([self isAdmin]) {
            
            ISGroupMemberDataModel *member = [self.groupMemberListArray objectAtIndex:indexPath.row - 1];
            
            if(member.user_id != [[AppData sharedInstance] getUserId]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove user" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Remove %@",member.nick_name] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self removeMemberFromGroupAPI:member];
                }];
                
                UIAlertAction *cancelActionAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alert addAction:deleteAction];
                [alert addAction:cancelActionAction];
                
                [self presentViewController:alert animated:true completion:nil];
            }
        }
    }
}


- (IBAction)btnProfileImageTapped:(UIButton *)sender
{
    NSInteger index = 0;
    if([self.groupData.admin_id isEqual:[[AppData sharedInstance] getUserId]]) {
        index = sender.tag - 1;
    }
    else {
        index = sender.tag;
    }
    
    ISGroupMemberDataModel *member = [self.groupMemberListArray objectAtIndex:index];
    ISSettingVC *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"ISSettingVC"];
    settings.isFromGroupInfo = YES;
    settings.profileInfo = member;
    settings.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settings animated:true];
    
    
}

#pragma mark - ISAddMemberToGroup Delegate

- (void)memberAddedToGroup {
    [self getGroupMemebrsAPICall];
}

#pragma mark - ChangeGroupName API Call

- (void) changeGroupNameAPI : (NSString *) newGroupName {
    NSDictionary *param = @{@"group_id":self.groupData.group_id,@"group_name":newGroupName,@"user_id":[[AppData sharedInstance] getUserId]};
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Changing Group Name"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    [APIUtility servicePostToEndPoint:ChangeGroupName withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(isSuccess) {
            
            
            NSLog(@"%@",response);
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [response valueForKey:@"message"];
            if([status  isEqual: @"1"]) {
                self.groupData.group_name = self.txtGroupName.text;
                [self changeSaveGroupButton];
                self.isGroupDataUpdated = true;
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

#pragma mark - ChangeGroupIcon API Call

- (void) changeGroupIcon : (UIImage *) newGroupIcon {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Changing Group Icon"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    UIGraphicsBeginImageContext(CGSizeMake(200,200));//Beign image context
    [newGroupIcon drawInRect:CGRectMake(0, 0, 200, 200)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.1);
    
    NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *user_id = [[AppData sharedInstance] getUserId];
    
    NSDictionary *param = @{@"user_id":user_id,@"group_id":self.groupData.group_id,@"group_icon":imageString,@"user_id":[[AppData sharedInstance] getUserId]};
    
    [APIUtility servicePostToEndPoint:ChangeGroupIcon withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        if(isSuccess) {
            
            
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self changeSaveGroupButton];
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

#pragma mark - RemoveMemberFromGroup

- (void) removeMemberFromGroupAPI : (ISGroupMemberDataModel *) member {
    NSDictionary *param = @{@"group_id":self.groupData.group_id,@"user_id":member.user_id,@"admin_id":[[AppData sharedInstance] getUserId]};
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    [APIUtility servicePostToEndPoint:RemoveMemberFromGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(isSuccess) {
           
            
            NSLog(@"%@",response);
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [response valueForKey:@"message"];
            if([status  isEqual: @"1"]) {
                [self.groupMemberListArray removeObject:member];
                self.groupData.group_members = self.groupMemberListArray;
                self.isGroupDataUpdated = true;
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
        
        [self.tblContactList reloadData];
    }];
}

#pragma mark - GetGroupMemebrs API

- (void) getGroupMemebrsAPICall {
    NSDictionary *param = @{@"group_id":self.groupData.group_id};
    
    [APIUtility servicePostToEndPoint:GetGroupMemebrs withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        if(isSuccess) {
            [SVProgressHUD dismiss];
            NSLog(@"%@",response);
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [response valueForKey:@"message"];
            if([status  isEqual: @"1"]) {
                
                NSArray *group = [response valueForKey:@"Group"];
                
                if(group.count > 0) {
                    
                    NSDictionary *grop_dict = [group objectAtIndex:0];
                    
                    NSArray *group_members = [grop_dict valueForKey:@"grop_members"];
                    
                    NSMutableArray *groupMembersArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *group_member in group_members) {
                        
                        ISGroupMemberDataModel *groupMemberData = [[ISGroupMemberDataModel alloc] init];
                        
                        groupMemberData.user_id = [group_member valueForKey:@"user_id"];
                        
                        //groupMemberData.nick_name = [[AppData sharedInstance] fetchContactName:[group_member valueForKey:@"user_id"]];
                        
                        groupMemberData.nick_name = @"";
                        
                        if([group_member valueForKey:@"nick_name"] != nil && [group_member valueForKey:@"nick_name"] != [NSNull null]) {
                            groupMemberData.nick_name = [group_member valueForKey:@"nick_name"];
                            
                        }
                        
                        groupMemberData.profile_picture = [group_member valueForKey:@"profile_picture"];
                        
                        [groupMembersArray addObject:groupMemberData];
                    }
                    
                    self.groupData.group_members = [NSMutableArray arrayWithArray:groupMembersArray];
                    self.groupMemberListArray = [NSMutableArray arrayWithArray:groupMembersArray];
                    self.isGroupDataUpdated = true;
                }
                
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
        
        [self.tblContactList reloadData];
    }];
    
}


@end
