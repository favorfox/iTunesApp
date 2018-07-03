//
//  ISLocalContactVC.m
//  iSteer
//
//  Created by EL Capitan on 15/11/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISLocalContactVC.h"

@interface ISLocalContactVC ()

@property CZPickerView *pickerWithImage;
@property NSMutableArray *selectedPhoneArray;

@end

ISLocalContactDataModel *selectedContactData;

@implementation ISLocalContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select Contact";
    self.navigationItem.hidesBackButton = YES;
    
    self.coreContactListArray = [[NSMutableArray alloc]init];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.tblContactList.dataSource = self;
    
    self.tblContactList.delegate = self;
    
    self.contactIndexTitles = [[NSMutableArray alloc] init];
    
    self.contactListArray = [[NSMutableArray alloc] init];
    
//    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel_white"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
//    
//    self.navigationItem.rightBarButtonItem = cancelBarButton;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"ic_cancel_white"] forState:UIControlStateNormal];
    
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] init];
    cancelBarButton.customView = cancelButton;
    
    self.navigationItem.rightBarButtonItem = cancelBarButton;

    
    [AppData sharedInstance].appDataDelegate = self;
    
    [AppData getContactsListWithAllNumber];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (void) cancelButtonClicked {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - AppData Delegate

- (void)contactListFetchedWithLocalContact:(NSMutableArray *)array {
    self.coreContactListArray  = [NSMutableArray arrayWithArray:array];
    [self filterArrayByAlpha:self.coreContactListArray];
}

#pragma mark - UITableView Delegate/DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.contactListArray.count == 0) {
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblContactList.frame.size.width, self.tblContactList.frame.size.height)];
        noDataLabel.text = @"Fetching Contacts";
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
    
    ISLocalContactDataModel *contactData = [dataListModel.contactArray objectAtIndex:indexPath.row];
    
    cell.lblContactFullName.text = contactData.fullName;
    
//    if () {
//        cell.imgContactProfilePic.image = contactData.profileImage;
//    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ISContactDataListModel *dataListModel = [self.contactListArray objectAtIndex:indexPath.section];
    
    ISLocalContactDataModel *contactData = [dataListModel.contactArray objectAtIndex:indexPath.row];
    
    NSLog(@"%@",contactData.phoneNumbers);
    
    if(contactData.phoneNumbers.count > 1) {
        self.selectedPhoneArray = [NSMutableArray arrayWithArray:contactData.phoneNumbers];
        CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Select Number" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
        selectedContactData = contactData;
        picker.headerTitleFont = [UIFont systemFontOfSize: 40];
        picker.delegate = self;
        picker.dataSource = self;
        picker.needFooterView = NO;
        [picker show];
    }
    else {
        [self.delegate localContactSelected:contactData.phoneNumbers[0] name:contactData.fullName];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

#pragma mark - CZPopup


- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return self.selectedPhoneArray[row];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return self.selectedPhoneArray.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    NSLog(@"%@ is chosen!", self.selectedPhoneArray[row]);
    [self.delegate localContactSelected:self.selectedPhoneArray[row] name:selectedContactData.fullName];

    [self.navigationController setNavigationBarHidden:false];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
    for (NSNumber *n in rows) {
        NSInteger row = [n integerValue];
        NSLog(@"%@ is chosen!", self.selectedPhoneArray[row]);
        
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    [self.navigationController setNavigationBarHidden:false];
    NSLog(@"Canceled.");
}


#pragma mark - Custom Methods


- (void) filterArrayByAlpha : (NSMutableArray *) array {
    NSMutableArray *uniqueKeyArray = [[NSMutableArray alloc] init];
    
    for (ISLocalContactDataModel *model in array) {
        
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


@end
