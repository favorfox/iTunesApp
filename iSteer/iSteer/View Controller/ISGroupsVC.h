//
//  ISGroupsVC.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISGroupListTableCell.h"
#import "ISGroupDetailVC.h"
#import "ISNewGroupVC.h"
#import "ISGroupDataModel.h"
#import "ISGroupMemberDataModel.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"

@interface ISGroupsVC : UIViewController <UITableViewDelegate, UITableViewDataSource, ISGroupListTableCelllDelegate,AppDataDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblGroupList;

@property (nonatomic, strong) NSMutableArray *coreContactListArray;

@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;

@property (nonatomic, strong) NSMutableArray *groupListDataArray;
@end
