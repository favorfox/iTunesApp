//
//  ISContactsVC.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISContactListTableCell.h"
#import "AppData.h"
#import "ISContactDataListModel.h"
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>

@interface ISContactsVC : UIViewController <UITableViewDelegate, UITableViewDataSource, AppDataDelegate, CNContactViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContactList;

@property (nonatomic, strong) NSMutableArray *contactListArray;
@property (nonatomic, strong) NSMutableArray *contactIndexTitles;
@property (nonatomic, strong) NSMutableArray *coreContactListArray;
@end
