//
//  ISContactsVC.m
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISContactsVC.h"
#import "APIUtility.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/AddressBook.h>
#import <SDWebImage/UIImageView+WebCache.h>
@interface ISContactsVC ()

@end

@implementation ISContactsVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coreContactListArray = [[NSMutableArray alloc]init];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.tblContactList.dataSource = self;
    self.tblContactList.delegate = self;
    
    self.navigationItem.title = @"CONTACTS";

//    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_white"] style:UIBarButtonItemStylePlain target:self action:@selector(addContactButtonClicked)];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addButton addTarget:self action:@selector(addContactButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"ic_add_white"] forState:UIControlStateNormal];
    
    addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    addButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] init];
    rightBarButton.customView = addButton;
    
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.contactIndexTitles = [[NSMutableArray alloc] init];
    
    self.contactListArray = [[NSMutableArray alloc] init];

    [AppData sharedInstance].appDataDelegate = self;
    
    [self fetchRecordFromLocal];
    
    ABAddressBookRef contactsBook = ABAddressBookCreate();
    ABAddressBookRegisterExternalChangeCallback(contactsBook, MyAddressBookChangeCallback, (__bridge void *)(self));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

void MyAddressBookChangeCallback (ABAddressBookRef contactsBook,CFDictionaryRef info,void *context){

    [AppData getContactsList];
}


#pragma mark - Button Action

- (void) addContactButtonClicked {
    CNContactStore *store = [[CNContactStore alloc] init];
        
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
    controller.contactStore = store;
    controller.delegate = self;
    UIView *top = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    [controller.view addSubview:top];
    [top setBackgroundColor:[UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1] ];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
//    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width, 64), false, [UIScreen mainScreen].scale);
//   [[UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1] setFill];
//    UIRectFill(rect);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1];
//    [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - CNContact Delegate

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact {
    [viewController dismissViewControllerAnimated:true completion:nil];
    
    if(contact != nil) {
        [AppData getContactsList];
    }
}

- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property {
    return true;
}

#pragma mark - Custom Methods

- (void) filterArrayByAlpha : (NSMutableArray *) array {
    NSMutableArray *uniqueKeyArray = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *model in array) {
        
        NSString *firstCharacter = [model.fullName substringToIndex:1];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF = %@",firstCharacter];
        
        NSArray *filteredArray = [uniqueKeyArray filteredArrayUsingPredicate:predicate];
        
        if(filteredArray.count == 0) {
            //When character is not found filtedred array
            
            NSRange rangeOfDecimalPoints = [firstCharacter rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
            
            if(rangeOfDecimalPoints.location == NSNotFound) {
                [uniqueKeyArray addObject:firstCharacter];//If decimal charracters found then it will be added to the uniqueArrayKey
            }
            else {
                [uniqueKeyArray addObject:@"#"];
            }
        }
    }
    
    NSArray *sortedArray = [[AppData sharedInstance] shortAlphaNumericArray:uniqueKeyArray];
    
    self.contactListArray = [[NSMutableArray alloc] init];
    self.contactIndexTitles = [NSMutableArray arrayWithArray:sortedArray];
    
    for (NSString *key in sortedArray) {
        
        if([key isEqualToString:@"#"]) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName MATCHES '[0-9].*'"];
            NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
            
            if(filteredArray.count > 0) {
                ISContactDataListModel *dataListModel = [[ISContactDataListModel alloc] init];
                dataListModel.key = key;
                dataListModel.contactArray = [NSMutableArray arrayWithArray:filteredArray];
                
                [self.contactListArray addObject:dataListModel];
                
            }
        }
        else {
            NSString *predicateFormate = [NSString stringWithFormat:@"fullName MATCHES '(%@).*'",key];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormate];
            NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
            
            if(filteredArray.count > 0) {
                ISContactDataListModel *dataListModel = [[ISContactDataListModel alloc] init];
                dataListModel.key = key;
                dataListModel.contactArray = [NSMutableArray arrayWithArray:filteredArray];
                
                [self.contactListArray addObject:dataListModel];
            }
        }
    }
    
    //[self getContactsDetail:self.contactListArray];
    [self.tblContactList reloadData];
}

#pragma mark - AppData contactListFetched

- (void)contactListFetched:(NSMutableArray *)array {
    
    self.coreContactListArray  = [NSMutableArray arrayWithArray:array];
    
   // NSMutableArray *rawContactArray = [NSMutableArray arrayWithArray:array];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    for (ISContactDataModel *contact in self.coreContactListArray)
    {
        if(contact.phone != nil) {
            if(contact.countryCode != nil) {
                if (contact.countryCode.length > 0) {
                    contact.countryCode = [contact.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
                }
                NSDictionary *contactDict = @{@"country_code":contact.countryCode,@"contact_number":contact.phone};
                [contacts addObject:contactDict];
            }
            else {
                NSString *userCountryCode = [[AppData sharedInstance] getUserCountryCode];

                if (userCountryCode.length > 0) {
                    userCountryCode = [userCountryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
                }
                NSDictionary *contactDict = @{@"country_code":userCountryCode,@"contact_number":contact.phone};
                [contacts addObject:contactDict];
            }
        }
    }
    
    [self getContactsDetail:contacts];
    //[self filterArrayByAlpha: rawContactArray];
}

#pragma mark - UITableView Delegate/DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.contactListArray.count == 0) {
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblContactList.frame.size.width, self.tblContactList.frame.size.height)];
        noDataLabel.text = @"You don't have any contact using this app.";
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor blackColor];
        noDataLabel.numberOfLines = 0;
        self.tblContactList.backgroundView = noDataLabel;
        return 0;
    }
    else {
        self.tblContactList.backgroundView = nil;
        return self.contactListArray.count;
    }
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.contactListArray.count;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ISContactDataListModel *dataListModel = [self.contactListArray objectAtIndex:section];

    return dataListModel.key;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    ISContactDataListModel *dataListModel = [self.contactListArray objectAtIndex:section];

    return dataListModel.contactArray.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.contactIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.contactIndexTitles indexOfObject:title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ISContactListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISContactListTableCell" forIndexPath:indexPath];
    
    ISContactDataListModel *dataListModel = [self.contactListArray objectAtIndex:indexPath.section];
    
    ISContactDataModel *contactData = [dataListModel.contactArray objectAtIndex:indexPath.row];
    
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
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

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
            
            [self filterArrayByAlpha:self.contactListArray];
            
            //[self.tblContactList reloadData];
        }];
    }
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
//                NSLog(@"%@", countryCode);
//                NSLog(@"%@", firstName);
//                NSLog(@"%@", fullName);
//                NSLog(@"%@", lastName);
//                NSLog(@"%@", phone);
//                NSLog(@"%@", user_id);
//                NSLog(@"%@", profileImage);
                
                //NSLog(@"2 - %@", group);
            }
            
            
            [self filterArrayByAlpha:self.contactListArray];
            
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
@end
