//
//  ISNewGroupVC.h
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISContactListTableCell.h"
#import "AppData.h"
#import "ISContactDataListModel.h"
#import "ISSelectedContactListCollectionCell.h"
#import "APIUtility.h"
#import "ISContactDataModel.h"

@interface ISNewGroupVC : UIViewController<UITableViewDelegate, UITableViewDataSource, AppDataDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnGroupImage;

@property (weak, nonatomic) IBOutlet UITextField *txtGroupName;

@property (weak, nonatomic) IBOutlet UITableView *tblContactList;

@property (weak, nonatomic) IBOutlet UICollectionView *collSelectedContactList;

@property (nonatomic, strong) NSMutableArray *contactListArray;

@property (nonatomic, strong) NSMutableArray *coreContactListArray;

@property (nonatomic, strong) NSMutableArray *selectedContactCollectionArray;


- (IBAction)btnGroupImageClicked:(id)sender;

- (IBAction)btnSaveNewGroupClicked:(id)sender;

@end
