//
//  ISNewGroupVC.m
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISNewGroupVC.h"

#import <AddressBook/ABAddressBook.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <SDWebImage/UIImageView+WebCache.h>
@interface ISNewGroupVC ()

@end

@implementation ISNewGroupVC

#pragma mark - Variables

UIImagePickerController *picker;
bool isGroupPicSelected = false;
bool contactListArrayHadRecords = false;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"NEW GROUP";
    
    [self setNavigationButton];
    
    [self setTextFieldPadding];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.tblContactList.dataSource = self;
    self.tblContactList.delegate = self;
    
    self.collSelectedContactList.dataSource = self;
    self.collSelectedContactList.delegate = self;
    
    self.selectedContactCollectionArray = [[NSMutableArray alloc] init];
    self.coreContactListArray = [[NSMutableArray alloc] init];
    self.contactListArray = [[NSMutableArray alloc] init];
    
    [AppData sharedInstance].appDataDelegate = self;
    
    
    [self fetchRecordFromLocal];
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    ABAddressBookRef ntificationaddressbook = ABAddressBookCreate();
    ABAddressBookRegisterExternalChangeCallback(ntificationaddressbook, MyAddressBookExternalChangeCallback, (__bridge void *)(self));
}

void MyAddressBookExternalChangeCallback (ABAddressBookRef ntificationaddressbook,CFDictionaryRef info,void *context)
{
    NSLog(@"Helloo Contacts modified");
    [AppData getContactsList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CNContactStoreDidChangeNotification object:nil];
}

//void addressBookChanged(ABAddressBookRef reference,
//                        CFDictionaryRef dictionary,
//                        void *context)
//{
//    ISNewGroupVC *viewController = (__bridge ISNewGroupVC*)context;
//    [viewController addressBookChanged];
//}

#pragma mark - Button Action

- (void) backButtonClicked {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnGroupImageClicked:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }];
    
    UIAlertAction *galleryActionAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelActionAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:galleryActionAction];
    [alert addAction:cancelActionAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)btnSaveNewGroupClicked:(id)sender {

    if([self.txtGroupName.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter Group Name"];
    }
//    else if([self.selectedContactCollectionArray count] == 0) {
//        [AppData displayAlert:@"Please select contact you want to add in group"];
//    }
//    else if(!isGroupPicSelected) {
//        [AppData displayAlert:@"Please select Group Icon"];
//    }
    else {
        [self createGroupAPICall];
    }
}

#pragma mark - AppData contactListFetched

- (void)contactListFetched:(NSMutableArray *)array {
    
    self.coreContactListArray  = [NSMutableArray arrayWithArray:array];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *contact in self.coreContactListArray) {
        NSString *cCode = @"";
        if (contact.countryCode.length > 0) {
            cCode = [contact.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
        }
        NSDictionary *contactDict = @{@"country_code":cCode,@"contact_number":contact.phone};
        [contacts addObject:contactDict];
    }
    
    [self getContactsDetail:contacts];
    
//    [self.tblContactList reloadData];
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
}

- (void) setTextFieldPadding {
    UIView *txtGroupNamepaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtGroupName.leftView = txtGroupNamepaddingView;
    self.txtGroupName.leftViewMode = UITextFieldViewModeAlways;
}

- (void) setCornerRadious {
    self.btnGroupImage.layer.cornerRadius = self.btnGroupImage.layer.frame.size.width/2;
    self.btnGroupImage.clipsToBounds = true;
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.contactListArray.count == 0) {
        if(contactListArrayHadRecords) {
            self.tblContactList.backgroundView = nil;
        }
        else {
            UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblContactList.frame.size.width, self.tblContactList.frame.size.height)];
            noDataLabel.text = @"You have no contacts that are registered with FavorFox App";
            noDataLabel.textAlignment = NSTextAlignmentCenter;
            noDataLabel.textColor = [UIColor blackColor];
            noDataLabel.numberOfLines = 0;
            self.tblContactList.backgroundView = noDataLabel;
        }
        return 0;
    }
    else {
        self.tblContactList.backgroundView = nil;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ISContactListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISContactListTableCell" forIndexPath:indexPath];
    
    ISContactDataModel *contactData = [self.contactListArray objectAtIndex:indexPath.row];
    
    cell.lblContactFullName.text = contactData.fullName;
    
    if ([contactData.profileImageUrl isEqualToString:@""] || contactData.profileImageUrl.length == 0 || contactData.profileImageUrl == (id)[NSNull null])
    {
        cell.imgContactProfilePic.image = contactData.profileImage;
    }
    else
    {
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,contactData.profileImageUrl];
        [cell.imgContactProfilePic sd_setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]];
    }
    //cell.imgContactProfilePic.image = contactData.profileImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ISContactDataModel *contactData = [self.contactListArray objectAtIndex:indexPath.row];
    
    [self.selectedContactCollectionArray addObject:contactData];
    
    [self.contactListArray removeObject:contactData];
    
    [self.tblContactList reloadData];
    
    [self.collSelectedContactList reloadData];
}

#pragma mark - GetContactsDetail

- (void) getContactsDetail : (NSMutableArray *) contactsArray {
    
    if(contactsArray.count > 0) {
        
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSDictionary *param = @{@"contacts":contactsArray,@"user_id":user_id};
        
        NSLog(@"GetContactsDetail Param = %@",param);
        
        if (self.contactListArray.count == 0)
        {
            [SVProgressHUD show];
        }
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD showWithStatus:@"Fetching..."];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [APIUtility getContactDetail:GetContactsDetail withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
            
            [self.contactListArray removeAllObjects];
            
            [SVProgressHUD dismiss];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            
            if(isSuccess) {
                
                NSLog(@"GetContactsDetail Response = %@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self deleteRecordFromLocal];
                    NSArray *contacts = [response valueForKey:@"Contacts"];
                    
                    for (NSDictionary *contact in contacts) {
                        NSString *is_app_contact = [contact valueForKey:@"is_app_contact"];

                        if([is_app_contact isEqual:@"1"]) {
                            NSString *user_id = [contact valueForKey:@"user_id"];
                            NSString *contact_number = [contact valueForKey:@"contact_number"];
                           NSString *profile_picture = [contact valueForKey:@"profile_picture"];
                            NSLog(@"%@",self.coreContactListArray);
                            
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phone = %@",contact_number];
                            NSArray *filteredArray = [self.coreContactListArray filteredArrayUsingPredicate:predicate];
                            
                             NSLog(@"%@",filteredArray);
                            
                            if(filteredArray.count > 0) {
                                ISContactDataModel *model = [filteredArray objectAtIndex:0];
                                model.user_id = user_id;
                                model.profileImageUrl = profile_picture;
                                [self.contactListArray addObject:model];
                                [self saveContactDataToLocal:model];
                            }
                        }
                    }
                }
                else {
                    [AppData displayAlert:message];
                }
                
            }
            else {
                NSLog(@"%@",error.localizedDescription);
                [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
            }
            
            if(self.contactListArray.count > 0) {
                contactListArrayHadRecords = true;
            }
            
            [self.tblContactList reloadData];
        }];
    }
}

#pragma mark - CreateGroup API Call

- (void) createGroupAPICall {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Creating Group"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSString *imageString = @"";
    
    if(isGroupPicSelected) {
        UIImage *image = self.btnGroupImage.imageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(200,200));//Beign image context
        [image drawInRect:CGRectMake(0, 0, 200, 200)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.1);
        imageString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }

    NSString *user_id = [[AppData sharedInstance] getUserId];
    
    NSMutableArray *groupMemberIdArray = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *model in self.selectedContactCollectionArray) {
        [groupMemberIdArray addObject:model.user_id];
    }
    
    NSString *groupMembersString  = [groupMemberIdArray componentsJoinedByString:@","];
    
    if(![groupMembersString  isEqual: @""]) {
        groupMembersString = [NSString stringWithFormat:@"%@,%@",groupMembersString,user_id];
    }
    else {
        groupMembersString = [NSString stringWithFormat:@"%@",user_id];
    }
    
    NSDictionary *param = @{@"admin_id":user_id,@"group_name":self.txtGroupName.text,@"group_member":groupMembersString,@"is_testdata":@"yes",@"group_icon":imageString};
    
    [APIUtility servicePostToEndPoint:CreateGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(isSuccess) {
            
            
            
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self.navigationController popViewControllerAnimated:true];
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

#pragma mark - UICollectionView Delegate/DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedContactCollectionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ISSelectedContactListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ISSelectedContactListCollectionCell" forIndexPath:indexPath];
    
    ISContactDataModel *contactData = [self.selectedContactCollectionArray objectAtIndex:indexPath.row];
    
    NSString *name = @"";
    
    if([contactData.firstName isEqualToString:@""]) {
        name = contactData.lastName;
    }
    else {
        name = contactData.firstName;
    }
    
    cell.lblContactFirstName.text = name;
    
    
    if ([contactData.profileImageUrl isEqualToString:@""] || contactData.profileImageUrl.length == 0 || contactData.profileImageUrl == (id)[NSNull null])
    {
        cell.imgContactProfilePic.image = contactData.profileImage;
    }
    else
    {
        NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,contactData.profileImageUrl];
        [cell.imgContactProfilePic sd_setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]];
    }

    //cell.imgContactProfilePic.image = contactData.profileImage;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ISContactDataModel *contactData = [self.selectedContactCollectionArray objectAtIndex:indexPath.row];
    
    [self.contactListArray addObject:contactData];
    
    [self.selectedContactCollectionArray removeObject:contactData];
    
    [self.tblContactList reloadData];
    
    [self.collSelectedContactList reloadData];
}

#pragma mark - UIPickerControll Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    isGroupPicSelected = true;
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self setCornerRadious];
    
    [self.btnGroupImage setImage:chosenImage forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)imageToNSString:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
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
    NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Tbl_Contact" inManagedObjectContext:context]];
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

- (void)saveContactDataToLocal:(ISContactDataModel *)model
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Tbl_Contact" inManagedObjectContext:context];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.countryCode] forKey:@"countryCode"];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.firstName] forKey:@"firstName"];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.fullName] forKey:@"fullName"];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.lastName] forKey:@"lastName"];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.phone] forKey:@"phone"];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.profileImageUrl] forKey:@"profileImageUrl"];
    NSData *imgData =  UIImagePNGRepresentation(model.profileImage);
    [newContact setValue:imgData forKey:@"profileImage"];
    [newContact setValue:[NSString stringWithFormat:@"%@",model.user_id] forKey:@"user_id"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

- (void)fetchRecordFromLocal
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tbl_Contact" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        //NSLog(@"%@", result);
        if (result.count > 0) {
            [self.contactListArray removeAllObjects];
            
            for (NSManagedObject *group in result)
            {
                //NSLog(@"1 - %@", group);
                
                NSString *countryCode = [group valueForKey:@"countryCode"];
                NSString *firstName = [group valueForKey:@"firstName"];
                NSString *fullName = [group valueForKey:@"fullName"];
                NSString *lastName = [group valueForKey:@"lastName"];
                NSString *phone = [group valueForKey:@"phone"];
                NSString *user_id = [group valueForKey:@"user_id"];
                NSData *profileImage = [group valueForKey:@"profileImage"];
                NSString *profileImageUrl = [group valueForKey:@"profileImageUrl"];
                
                ISContactDataModel *model = [[ISContactDataModel alloc]init];
                model.countryCode = countryCode;
                model.firstName = firstName;
                model.fullName = fullName;
                model.lastName = lastName;
                model.phone = phone;
                model.user_id = user_id;
                model.profileImageUrl = profileImageUrl;
                model.profileImage = [UIImage imageWithData:profileImage];
                
                [self.contactListArray addObject:model];
                NSLog(@"%@", countryCode);
                NSLog(@"%@", firstName);
                NSLog(@"%@", fullName);
                NSLog(@"%@", lastName);
                NSLog(@"%@", phone);
                NSLog(@"%@", user_id);
                NSLog(@"%@", profileImage);
                
                //NSLog(@"2 - %@", group);
            }

            if(self.contactListArray.count > 0) {
                contactListArrayHadRecords = true;
            }
            
            [self.tblContactList reloadData];
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                [AppData getContactsList];
//            });
            
        }
        else
        {
            [AppData getContactsList];
        }
    }
}

@end
