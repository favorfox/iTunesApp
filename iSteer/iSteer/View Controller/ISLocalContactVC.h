//
//  ISLocalContactVC.h
//  iSteer
//
//  Created by EL Capitan on 15/11/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "ISLocalContactDataModel.h"
#import "ISContactDataListModel.h"
#import "ISContactListTableCell.h"
#import <CZPicker.h>

@protocol ISLocalContactVCDelegate <NSObject>

- (void) localContactSelected : (NSString *) number name : (NSString *) name;

@end

@interface ISLocalContactVC : UIViewController <UITableViewDelegate, UITableViewDataSource,AppDataDelegate,CZPickerViewDataSource, CZPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContactList;

@property (nonatomic, strong) NSMutableArray *contactListArray;
@property (nonatomic, strong) NSMutableArray *contactIndexTitles;
@property (nonatomic, strong) NSMutableArray *coreContactListArray;

@property (nonatomic, weak) id <ISLocalContactVCDelegate> delegate;

@end
