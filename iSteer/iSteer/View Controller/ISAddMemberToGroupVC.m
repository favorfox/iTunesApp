//
//  ISAddMemberToGroupVC.m
//  iSteer
//
//  Created by EL Capitan on 26/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISAddMemberToGroupVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface ISAddMemberToGroupVC ()

@end

bool contactListArrayHadRecord = false;

@implementation ISAddMemberToGroupVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.tblContactList.dataSource = self;
    self.tblContactList.delegate = self;
    
    self.collSelectedContactList.dataSource = self;
    self.collSelectedContactList.delegate = self;
    
    self.selectedContactCollectionArray = [[NSMutableArray alloc] init];
    self.coreContactListArray = [[NSMutableArray alloc] init];
    self.contactListArray = [[NSMutableArray alloc] init];
    
    [AppData sharedInstance].appDataDelegate = self;
    
    //[self fetchRecordFromLocal];
    
    [AppData getContactsList];
    
    [self setNavigationButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (void) btnCancelClicked {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) btnAddClicked {
    if(self.selectedContactCollectionArray.count > 0) {
        [self addMemberInGroupAPICall];
    }
}

#pragma mark - AppData contactListFetched


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
                //                NSLog(@"%@", countryCode);
                //                NSLog(@"%@", firstName);
                //                NSLog(@"%@", fullName);
                //                NSLog(@"%@", lastName);
                //                NSLog(@"%@", phone);
                //                NSLog(@"%@", user_id);
                //                NSLog(@"%@", profileImage);
                
                //NSLog(@"2 - %@", group);
            }
            
            
            [self filterContactArrayWithExistingMembers];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [AppData getContactsList];
            });
            
        }
        else
        {
            [AppData getContactsList];
        }
    }
}

- (void)contactListFetched:(NSMutableArray *)array {
    
    self.coreContactListArray  = [NSMutableArray arrayWithArray:array];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *contact in self.coreContactListArray) {
        if(contact.phone != nil) {
            NSString *cCode = @"";
            if (contact.countryCode.length > 0) {
                cCode = [contact.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
            }            NSDictionary *contactDict = @{@"country_code":cCode,@"contact_number":contact.phone};
            [contacts addObject:contactDict];
        }
    }
    
    NSLog(@"%@",contacts);
    [self getContactsDetail:contacts];
    
    //    [self.tblContactList reloadData];
}

#pragma mark - Custom Methods

- (void) setNavigationButton {
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelClicked)];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(btnAddClicked)];
    self.title = @"Add Members";

    self.navigationItem.leftBarButtonItem = cancelBarButton;
    self.navigationItem.rightBarButtonItem = addBarButton;
}

- (void) filterContactArrayWithExistingMembers {
    if(self.groupData != nil) {
        for (ISGroupMemberDataModel *groupMemberData in self.groupData.group_members) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %@",groupMemberData.user_id];
            NSArray *filteredArray = [self.contactListArray filteredArrayUsingPredicate:predicate];
            if(filteredArray.count > 0) {
                ISContactDataModel *contactData = filteredArray.firstObject;
                [self.contactListArray removeObject:contactData];
            }
        }
    }
    
    if(self.contactListArray.count > 0) {
        contactListArrayHadRecord = true;
    }
    
    [self.tblContactList reloadData];
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.contactListArray.count == 0) {
        if(contactListArrayHadRecord) {
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

#pragma mark - GetContactsDetail

- (void) getContactsDetail : (NSMutableArray *) contactsArray {
    
    if(contactsArray.count > 0) {
        
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSDictionary *param = @{@"contacts":contactsArray,@"user_id":user_id};
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [APIUtility getContactDetail:GetContactsDetail withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
            
            [self.contactListArray removeAllObjects];
            
            [SVProgressHUD dismiss];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if(isSuccess) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    NSArray *contacts = [response valueForKey:@"Contacts"];
                    
                    for (NSDictionary *contact in contacts) {
                        NSString *is_app_contact = [contact valueForKey:@"is_app_contact"];
                        
                        if([is_app_contact isEqual:@"1"]) {
                            NSString *user_id = [contact valueForKey:@"user_id"];
                            NSString *contact_number = [contact valueForKey:@"contact_number"];
                            NSString *profile_picture = [contact valueForKey:@"profile_picture"];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phone = %@",contact_number];
                            
                            NSArray *filteredArray = [self.coreContactListArray filteredArrayUsingPredicate:predicate];
                            
                            if(filteredArray.count > 0) {
                                ISContactDataModel *model = [filteredArray objectAtIndex:0];
                                model.user_id = user_id;
                                model.profileImageUrl = profile_picture;
                                [self.contactListArray addObject:model];
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
            
            [self filterContactArrayWithExistingMembers];
            
//            [self.tblContactList reloadData];
        }];
    }
}

#pragma mark - AddMemberInGroup API Call

- (void) addMemberInGroupAPICall {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Adding Member"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSMutableArray *groupMemberIdArray = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *model in self.selectedContactCollectionArray) {
        [groupMemberIdArray addObject:model.user_id];
    }
    
    NSString *groupMembersString  = [groupMemberIdArray componentsJoinedByString:@","];
    
    NSDictionary *param = @{@"user_id":groupMembersString,@"group_id":self.groupData.group_id,@"admin_id":[[AppData sharedInstance] getUserId]};
    
    [APIUtility servicePostToEndPoint:AddMemberInGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(isSuccess) {

            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self.delegate memberAddedToGroup];
                    
                    [self dismissViewControllerAnimated:true completion:nil];
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
#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


@end
