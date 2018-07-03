//
//  ISGroupsVC.m
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISGroupsVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AddressBook/AddressBook.h>
@interface ISGroupsVC ()

@end

NSArray *groupUserName;

@implementation ISGroupsVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppData sharedInstance].appDataDelegate = self;
    
    self.navigationItem.title = @"GROUPS";
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
//    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_white"] style:UIBarButtonItemStylePlain target:self action:@selector(addGroupButtonClicked)];
//    
//    self.navigationItem.rightBarButtonItem = addBarButton;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addButton addTarget:self action:@selector(addGroupButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"ic_add_white"] forState:UIControlStateNormal];
    
    addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    addButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] init];
    rightBarButton.customView = addButton;
    
    self.navigationItem.rightBarButtonItem = rightBarButton;

    
    self.cellsCurrentlyEditing = [NSMutableArray array];

    groupUserName = @[@"St Xaviers",@"RTPI Tuitions",@"Wallyball",@"Club Rola"];
    
    self.groupListDataArray = [[NSMutableArray alloc] init];
    
    self.tblGroupList.delegate = self;
    self.tblGroupList.dataSource = self;
    
//    [[AppData sharedInstance] scanAddressBookSample:@"9723407064" aResultBlock:^(NSString *name) {
//        NSLog(@"%@",name);
//    }];
    
    [self fetchContactFromLocal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (void) addGroupButtonClicked  {
    ISNewGroupVC *newGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISNewGroupVC"];
    [self.navigationController pushViewController:newGroupVC animated:true];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.cellsCurrentlyEditing = [NSMutableArray array];
    
    self.navigationItem.title = @"GROUPS";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self fetchRecordFromLocal];
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.tblGroupList reloadData];
}

#pragma mark - AppData contactListFetched

- (void)contactListFetched:(NSMutableArray *)array {
    self.coreContactListArray  = [NSMutableArray arrayWithArray:array];
    
    // NSMutableArray *rawContactArray = [NSMutableArray arrayWithArray:array];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *contact in self.coreContactListArray) {
        if(contact.phone != nil) {
            NSString *cCode = @"";
            if (contact.countryCode.length > 0) {
                cCode = [contact.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
            }
            NSDictionary *contactDict = @{@"country_code":cCode,@"contact_number":contact.phone};
            [contacts addObject:contactDict];
        }
    }
    
    [self getContactsDetail:contacts];
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.groupListDataArray.count == 0) {
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblGroupList.frame.size.width, self.tblGroupList.frame.size.height)];
        noDataLabel.text = @"You have no groups. Please tap on + button to add new.";
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor blackColor];
        noDataLabel.numberOfLines = 0;
        self.tblGroupList.backgroundView = noDataLabel;
        return 0;
    }
    else {
        self.tblGroupList.backgroundView = nil;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupListDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ISGroupListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISGroupListTableCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [cell openCell];
    }
    
    ISGroupDataModel *groupData = [self.groupListDataArray objectAtIndex:indexPath.row];
    
    cell.lblUserName.text = groupData.group_name;

    cell.btnArchive.tag = indexPath.row;
    
    [cell.btnArchive addTarget:self action:@selector(btnArchiveClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,groupData.group_icon];
    
    [cell.imgUserPicture clearImageCacheForURL:[NSURL URLWithString:imageString]];
    
//    [self.imgGroupIcon clearImageCacheForURL:[NSURL URLWithString:imageString]];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageString]];
//    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [cell.imgUserPicture sd_setImageWithURL:[NSURL URLWithString:imageString]
                         placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]options:SDWebImageRefreshCached];
    
    
//    [cell.imgUserPicture setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//        cell.imgUserPicture.image = image;
//    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//        cell.imgUserPicture.image = [UIImage imageNamed:@"ic_user_placeholder"];
//    }];
    
//    [cell.imgUserPicture setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]];

    if([groupData.request_badge  isEqual: @"0"]) {
        cell.badgeView.hidden = true;
        cell.lblBadgeCount.text = @"0";
    }
    else {
        cell.badgeView.hidden = false;
        cell.lblBadgeCount.text = groupData.request_badge;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ISGroupDataModel *groupData = [self.groupListDataArray objectAtIndex:indexPath.row];
    
    ISGroupDetailVC *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ISGroupDetailVC"];
    groupDetail.groupData = groupData;
    [self.navigationController pushViewController:groupDetail animated:true];

//    ICEventRequestDetailVC *carpoolRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ICEventRequestDetailVC"];
//    carpoolRequestDetailVC.isFromNotification = true;
//    carpoolRequestDetailVC.request_id = @"47";
//    [self.navigationController pushViewController:carpoolRequestDetailVC animated:true];
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else {
//        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
//    }
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ISGroupDataModel *groupData = [self.groupListDataArray objectAtIndex:indexPath.row];

        [self deleteGroupAPICall:groupData.group_id];
        [self.groupListDataArray removeObject:groupData];
        [self.tblGroupList reloadData];
    }
}

#pragma mark Cell Button Click

- (void) btnArchiveClicked {

}

#pragma mark Cell Delegate

- (void)cellDidOpen:(UITableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tblGroupList indexPathForCell:cell];
    
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tblGroupList indexPathForCell:cell]];
}

#pragma mark - GetAllGroups

- (void) getAllGroupAPICall {
    NSString *user_id = [[AppData sharedInstance] getUserId];
    
    NSDictionary *param = @{@"user_id":user_id};
    
//    NSDictionary *param = @{@"user_id":@"1"};

    if (self.groupListDataArray.count == 0)
    {
        [SVProgressHUD showWithStatus:@"Loading"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    [APIUtility servicePostToEndPoint:GetAllGroups withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (isSuccess) {
            [self.groupListDataArray removeAllObjects];
            [self deleteRecordFromLocal];
            if(response != nil) {
                NSString *status = [response valueForKey:@"status"];
                
                if([status isEqualToString:@"1"]) {
                    NSArray *groups = [response valueForKey:@"Group"];
                    [self parseGroupData:groups saveToLocal:true];
                }
                else if([status isEqualToString:@"2"]) {
                    
                }
            }
        }
        else {
            NSLog(@"%@",error.localizedDescription);
//            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"GroupDataNotification" object:nil];
        [self.tblGroupList reloadData];
    }];
}

- (void)parseGroupData:(NSArray *)groups saveToLocal:(BOOL) saveToLocal
{
    [self.groupListDataArray removeAllObjects];
    
    for (NSDictionary *group_dict in groups) {
        
        ISGroupDataModel *groupData = [[ISGroupDataModel alloc] init];
        
        groupData.group_id = [group_dict valueForKey:@"group_id"];
        
        groupData.group_name = [group_dict valueForKey:@"group_name"];
        
        groupData.group_icon = [group_dict valueForKey:@"group_icon"];
        
        groupData.admin_id = [group_dict valueForKey:@"admin_id"];
        
        groupData.request_badge = [NSString stringWithFormat:@"%@",[group_dict valueForKey:@"request_badge"]];
        
        NSArray *grop_members = [group_dict valueForKey:@"group_members"];
        
        NSMutableArray *groupMembersArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *group_member in grop_members) {
            
            ISGroupMemberDataModel *groupMemberData = [[ISGroupMemberDataModel alloc] init];
            
            groupMemberData.user_id = [group_member valueForKey:@"user_id"];
            
            groupMemberData.nick_name = @"";
            if([group_member objectForKey:@"nick_name"] != nil && [group_member valueForKey:@"nick_name"] != [NSNull null]) {
                groupMemberData.nick_name = [group_member valueForKey:@"nick_name"];
            }
            
            groupMemberData.profile_picture = [group_member valueForKey:@"profile_picture"];
            [groupMembersArray addObject:groupMemberData];
        }
        
        groupData.group_members = [NSMutableArray arrayWithArray:groupMembersArray];
        
        if(saveToLocal) {
            [self saveGroupDataToLocal:groupData groupMembers:grop_members];
        }
        
        [self.groupListDataArray addObject:groupData];
    }
    
    [self.tblGroupList reloadData];
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
//    NSFetchRequest *allGroups = [[NSFetchRequest alloc] init];
//    [allGroups setEntity:[NSEntityDescription entityForName:@"Tbl_groups" inManagedObjectContext:context]];
//    [allGroups setIncludesPropertyValues:NO]; //only fetch the managedObjectID
//    
//    NSError *error = nil;
//    NSArray *groups = [context executeFetchRequest:allGroups error:&error];
//    //error handling goes here
//    for (NSManagedObject *group in groups) {
//        [context deleteObject:group];
//    }
//    NSError *saveError = nil;
//    [context save:&saveError];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tbl_groups"];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [context deleteObject:object];
    }
    
    error = nil;
    [context save:&error];
}

- (void)saveGroupDataToLocal:(ISGroupDataModel *)model groupMembers : (NSArray *)members
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Tbl_groups" inManagedObjectContext:context];
    
    [newGroup setValue:[NSString stringWithFormat:@"%@",model.admin_id] forKey:@"admin_id"];
    [newGroup setValue:[NSString stringWithFormat:@"%@",model.group_icon] forKey:@"group_icon"];
    [newGroup setValue:[NSString stringWithFormat:@"%@",model.group_id] forKey:@"group_id"];
    [newGroup setValue:[NSKeyedArchiver archivedDataWithRootObject:members] forKey:@"group_members"];
    [newGroup setValue:[NSString stringWithFormat:@"%@",model.group_name] forKey:@"group_name"];
    [newGroup setValue:[NSString stringWithFormat:@"%@",model.request_badge] forKey:@"request_badge"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)fetchRecordFromLocal
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tbl_groups" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        //NSLog(@"%@", result);
        if (result.count > 0) {
            NSMutableArray *tempData = [[NSMutableArray alloc]init];
            for (NSManagedObject *group in result)
            {
                //NSLog(@"1 - %@", group);
                
                NSString *admin_id = [group valueForKey:@"admin_id"];
                NSString *group_icon = [group valueForKey:@"group_icon"];
                NSString *group_id = [group valueForKey:@"group_id"];
                NSString *group_name = [group valueForKey:@"group_name"];
                NSString *request_badge = [group valueForKey:@"request_badge"];
                NSArray *group_members = [NSKeyedUnarchiver unarchiveObjectWithData:[group valueForKey:@"group_members"]];
                
                NSDictionary *tempDict = @{@"admin_id":admin_id,@"group_icon":group_icon,@"group_id":group_id,@"group_name":group_name,@"request_badge":request_badge,@"group_members":group_members};
                [tempData addObject:tempDict];
                
                
//                NSLog(@"%@", [group valueForKey:@"admin_id"]);
//                NSLog(@"%@", [group valueForKey:@"group_icon"]);
//                NSLog(@"%@", [group valueForKey:@"group_id"]);
//                NSLog(@"%@", [group valueForKey:@"group_members"]);
//                NSLog(@"%@",  group_members);
//                NSLog(@"%@", [group valueForKey:@"group_name"]);
//                NSLog(@"%@", [group valueForKey:@"request_badge"]);
                
                //NSLog(@"2 - %@", group);
            }
            
            [self parseGroupData:tempData saveToLocal:false];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getAllGroupAPICall];
            });
        }
        else
        {
            [self getAllGroupAPICall];
        }
    }
}

- (void)fetchContactFromLocal
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

        }
        else
        {
            [AppData getContactsList];
        }
    }
}

#pragma mark - DeleteGroup

- (void) deleteGroupAPICall : (NSString *) group_id {
    
    NSDictionary *param = @{@"group_id":group_id};
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Deleting Group"];
    
    [APIUtility servicePostToEndPoint:DeleteGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        if (isSuccess) {
            if(response != nil) {
                NSString *status = [response valueForKey:@"status"];
                
                if([status isEqualToString:@"1"]) {
                    [self getAllGroupAPICall];
                }
                else if([status isEqualToString:@"2"]) {
                    
                }
            }
        }
        else {
            NSLog(@"%@",error.localizedDescription);
            //            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"GroupDataNotification" object:nil];
        [self.tblGroupList reloadData];
    }];
}



#pragma mark - GetContactsDetail

- (void) getContactsDetail : (NSMutableArray *) contactsArray {
    
    if(contactsArray.count > 0) {
        
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSDictionary *param = @{@"contacts":contactsArray,@"user_id":user_id};
        
        NSLog(@"GetContactsDetail Param = %@",param);
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [APIUtility getContactDetail:GetContactsDetail withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
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
        }];
    }
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
@end
