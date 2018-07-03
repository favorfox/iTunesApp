//
//  ISGroupInfoVC.h
//  iSteer
//
//  Created by EL Capitan on 25/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISContactListTableCell.h"
#import "ISGroupDataModel.h"
#import "ISGroupMemberDataModel.h"
#import "UIImageView+AFNetworking.h"
#import "ISContactsVC.h"
#import "AppData.h"
#import "APIUtility.h"
#import "ISAddMemberTableCell.h"
#import "ISAddMemberToGroupVC.h"

@protocol ISGroupInfoDelegate <NSObject>

@optional

//Delegate method to invoke After Contact fetched successfully
-(void)updatedGroupObject:(ISGroupDataModel *) groupDataObj;

@end

@interface ISGroupInfoVC : UIViewController<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate, UITextViewDelegate,ISAddMemberToGroupDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtGroupName;

@property (weak, nonatomic) IBOutlet UITableView *tblContactList;

@property (weak, nonatomic) IBOutlet UIImageView *imgGroupIcon;

#pragma mark - Variables

@property (nonatomic, strong) NSMutableArray *groupMemberListArray;

@property (nonatomic, strong) NSMutableArray *coreContactListArray;

@property (strong, nonatomic) ISGroupDataModel *groupData;

@property (nonatomic, weak) id <ISGroupInfoDelegate> delegate;

@property (nonatomic, assign) bool isGroupDataUpdated;

@end
