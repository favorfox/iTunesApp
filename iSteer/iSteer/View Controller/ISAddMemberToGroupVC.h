//
//  ISAddMemberToGroupVC.h
//  iSteer
//
//  Created by EL Capitan on 26/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISContactListTableCell.h"
#import "AppData.h"
#import "ISContactDataListModel.h"
#import "ISSelectedContactListCollectionCell.h"
#import "APIUtility.h"
#import "ISContactDataModel.h"
#import "ISGroupDataModel.h"
#import "ISGroupMemberDataModel.h"

@protocol ISAddMemberToGroupDelegate <NSObject>

@optional

//Delegate method to invoke After Contact fetched successfully
-(void) memberAddedToGroup;

@end


@interface ISAddMemberToGroupVC : UIViewController<UITableViewDelegate, UITableViewDataSource, AppDataDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblContactList;

@property (weak, nonatomic) IBOutlet UICollectionView *collSelectedContactList;

@property (nonatomic, strong) NSMutableArray *contactListArray;

@property (nonatomic, strong) NSMutableArray *coreContactListArray;

@property (nonatomic, strong) NSMutableArray *selectedContactCollectionArray;

@property (strong, nonatomic) ISGroupDataModel *groupData;

@property (nonatomic, weak) id <ISAddMemberToGroupDelegate> delegate;


@end
