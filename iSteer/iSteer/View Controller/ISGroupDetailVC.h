//
//  ISGroupDetailVC.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISEventGroupTableCell.h"
#import "ISCarpoolGroupTableCell.h"
#import "ISNewRequestVC.h"
#import "ISCarpoolRequestDetailVC.h"
#import "ICEventRequestDetailVC.h"
#import "ISGroupDataModel.h"
#import "ISGroupMemberDataModel.h"
#import "ISGroupInfoVC.h"
#import "UIImageView+AFNetworking.h"
#import "ISRequestTextModelClass.h"
#import "ISDueDateModel.h"
#import "ISDestinationAddressModel.h"
#import "ISSourceAddressModel.h"
#import "ISContactNumberModel.h"
#import "ISRequestDataModel.h"
#import <UIScrollView+InfiniteScroll.h>
#import "CustomInfiniteIndicator.h"
#import "Constants.h"
#import "ISNewRequestVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ISArchivedRequestVC.h"

@interface ISGroupDetailVC : UIViewController<UITableViewDelegate, UITableViewDataSource, ISGroupInfoDelegate,ISNewRequestDelegate, ISCarpoolRequestDetailDelegate, ICEventRequestDetailDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblGroupDetailList;

#pragma mark - Variable

@property (strong, nonatomic) ISGroupDataModel *groupData;
@property (strong, nonatomic) UIImageView *groupIcon;
@property (strong, nonatomic) NSMutableArray *groupRequestArray;

@property (nonatomic,assign) NSInteger start_limit;
@property (nonatomic,assign) BOOL isArchiveRequest;
@property (weak, nonatomic) IBOutlet UIButton *btnArchives;

- (IBAction)btnArchivesClicked:(id)sender;

@property (nonatomic, assign) BOOL isFromNotification;

@end
