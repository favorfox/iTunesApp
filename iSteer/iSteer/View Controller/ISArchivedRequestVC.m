//
//  ISArchivedRequestVC.m
//  iSteer
//
//  Created by EL Capitan on 19/11/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISArchivedRequestVC.h"

@interface ISArchivedRequestVC ()

@end

UIRefreshControl *tblRefreshControl;


@implementation ISArchivedRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self setNavigationBarTitle];
    
    [self setBarButton];
    
    self.groupRequestArray = [[NSMutableArray alloc] init];
    
    self.tblGroupDetailList.delegate = self;
    self.tblGroupDetailList.dataSource = self;
    
    self.tblGroupDetailList.rowHeight = UITableViewAutomaticDimension;
    self.tblGroupDetailList.estimatedRowHeight = 65.0;
    
    self.start_limit = 0;
    
    // Infinite Screen
    
    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    // Set custom indicator
    self.tblGroupDetailList.infiniteScrollIndicatorView = indicator;
    
    // Set custom indicator margin
    self.tblGroupDetailList.infiniteScrollIndicatorMargin = 40;
    
    // Set custom trigger offset
    self.tblGroupDetailList.infiniteScrollTriggerOffset = 700;
    
    [self.tblGroupDetailList addInfiniteScrollWithHandler:^(UITableView * _Nonnull tableView) {
        [self fetchData:^{
            // Finish infinite scroll animations
            [self.tblGroupDetailList finishInfiniteScroll];
        }];
    }];
    
    //Pull to refresh
    
    tblRefreshControl = [[UIRefreshControl alloc] init];
    tblRefreshControl.tintColor = [UIColor grayColor];
    tblRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [tblRefreshControl addTarget:self action:@selector(getAllRequestOfGroup:) forControlEvents:UIControlEventValueChanged];
    [self.tblGroupDetailList addSubview:tblRefreshControl];
    
    [self fetchRecordFromLocal];
    
    if (self.isArchiveRequest)
    {
        self.btnArchives.hidden = YES;
    }
    else
    {
        self.btnArchives.hidden = NO;
    }
    
    if(self.isFromNotification) {
        self.isFromNotification = false;
        [self getGroupDetails];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self fetchRecordFromLocal];
    [self addGroupIcon];
}

#pragma mark - Button Action

- (void) addGroupButtonClicked {
    ISNewRequestVC *newRequestVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISNewRequestVC"];
    newRequestVC.groupData = self.groupData;
    newRequestVC.delegate = self;
    [self.navigationController pushViewController:newRequestVC animated:true];
}

- (void) backButtonClicked {
    [self.navigationController popViewControllerAnimated:true];
}

- (void) groupIconButtonClicked {
    
}

- (void) groupInfoButtonClicked {
    ISGroupInfoVC *groupInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISGroupInfoVC"];
    groupInfoVC.groupData = self.groupData;
    groupInfoVC.delegate = self;
    [self.navigationController pushViewController:groupInfoVC animated:true];
}

#pragma mark - ISGroupInfo Delegate

- (void)updatedGroupObject:(ISGroupDataModel *)groupDataObj {
    if(groupDataObj != nil) {
        self.groupData = groupDataObj;
        
        [self setNavigationBarTitle];
    }
}

#pragma mark - ISNewRequestDelegate

- (void)newEventAdded {
    self.start_limit = 0;
    [self getAllRequestOfGroup:self.start_limit];
}

#pragma mark - Custom Methods

- (void) setNavigationBarTitle {
    
    if(self.groupData != nil) {
        
        NSString *groupName = self.groupData.group_name;
        NSMutableArray *groupMemberNamesArray = [[NSMutableArray alloc] init];
        for (ISGroupMemberDataModel *memberModel in self.groupData.group_members) {
            
            //user_id
            NSString *name = [[AppData sharedInstance] fetchContactName:memberModel.user_id];
            if ([name isEqualToString:@""])
            {
                [groupMemberNamesArray addObject:memberModel.nick_name];
            }
            else
            {
                [groupMemberNamesArray addObject:[[AppData sharedInstance] fetchContactName:memberModel.user_id]];
            }
        }
        
        NSString *groupMemberNames = [groupMemberNamesArray componentsJoinedByString:@","];
        
        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:groupName attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:15],NSFontAttributeName, nil]];
        
        NSMutableAttributedString *subTitleString = [[NSMutableAttributedString alloc] initWithString:groupMemberNames attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont systemFontOfSize:10],NSFontAttributeName, nil]];
        
        CGFloat width;
        
        if (subTitleString.size.width > titleString.size.width)
        {
            width = subTitleString.size.width+10;
        }
        else
        {
            width = titleString.size.width+10;
        }
        
        CGFloat height = 44;
        
        NSLog(@"%f %f",[UIScreen mainScreen].bounds.size.width - 130,width);
        
        if (width > ([UIScreen mainScreen].bounds.size.width - 130))
        {
            width = [UIScreen mainScreen].bounds.size.width - 130;
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, width, 25)];
        titleLabel.attributedText = titleString;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 1;
        
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width, 14)];
        subTitleLabel.attributedText = subTitleString;
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        subTitleLabel.numberOfLines = 1;
        subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        //titleView.backgroundColor = [UIColor redColor];
        [titleView addSubview:titleLabel];
        [titleView addSubview:subTitleLabel];
        
        UIButton *groupInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
        groupInfoButton.backgroundColor = [UIColor clearColor];
        [groupInfoButton addTarget:self action:@selector(groupInfoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [titleView addSubview:groupInfoButton];
        // titleView.backgroundColor = [UIColor grayColor];
        
        self.navigationItem.titleView = titleView;
    }
}

- (void) setBarButton {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    leftView.backgroundColor = [UIColor clearColor];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 40, 40)];
//    [backButton setBackgroundColor:[UIColor redColor]];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
    
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    
    self.groupIcon = [[UIImageView alloc]initWithFrame:CGRectMake(25, 6, 32, 32)];
    self.groupIcon.layer.cornerRadius = self.groupIcon.layer.frame.size.width/2;
    self.groupIcon.clipsToBounds = true;
    
    [self addGroupIcon];
    
    [leftView addSubview:backButton];
    [leftView addSubview:self.groupIcon];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] init];
    leftBarButton.customView = leftView;
    
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    if (!self.isArchiveRequest)
    {
        UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_white"] style:UIBarButtonItemStylePlain target:self action:@selector(addGroupButtonClicked)];
        self.navigationItem.rightBarButtonItem = addBarButton;
    }
}

- (void) addGroupIcon {
    NSString *imageString = [NSString stringWithFormat:@"%@%@",APIBaseImageURL,self.groupData.group_icon];
    
    //[self.groupIcon clearImageCacheForURL:[NSURL URLWithString:imageString]];
    
    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageString]];
    //    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    //    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [self.groupIcon sd_setImageWithURL:[NSURL URLWithString:imageString]
                      placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"]options:SDWebImageRefreshCached];
    
    
    //    [self.groupIcon setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"ic_user_placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
    //        self.groupIcon.image = image;
    //    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
    //        self.groupIcon.image = [UIImage imageNamed:@"ic_user_placeholder"];
    //    }];
}

- (void) parseRequestsArray : (NSArray *) requests {
    //    [self.groupRequestArray removeAllObjects];
    for (NSDictionary *request in requests) {
        if([[request valueForKey:@"request_type_id"]  isEqual: @1]) {
            //            NSLog(@"Carpool");
            
            ISRequestDataModel *requestData = [self parseCarpoolRequestDict:request];
            
            [self.groupRequestArray addObject:requestData];
        }
        else if([[request valueForKey:@"request_type_id"]  isEqual: @2]) {
            //            NSLog(@"Event");
            ISRequestDataModel *requestData = [self parseEventRequestDict:request];
            
            [self.groupRequestArray addObject:requestData];
        }
    }
    
    [self sortData];
}

- (ISRequestDataModel *) parseCarpoolRequestDict : (NSDictionary *) dict {
    
    ISRequestDataModel *requestData = [[ISRequestDataModel alloc] init];
    
    requestData.accepted_user_name = [dict valueForKey:@"accepted_user_name"];
    
    requestData.created_date = [dict valueForKey:@"created_date"];
    
    requestData.group_id = [dict valueForKey:@"group_id"];
    
    requestData.is_archived = [dict valueForKey:@"is_archived"];
    
    requestData.modified_date = [dict valueForKey:@"modified_date"];
    
    requestData.request_accepted_by_id = [dict valueForKey:@"request_accepted_by_id"];
    
    requestData.request_id = [dict valueForKey:@"request_id"];
    
    requestData.request_is_delete = [dict valueForKey:@"request_is_delete"];
    
    requestData.request_message = [dict valueForKey:@"request_message"];
    
    requestData.request_status = [dict valueForKey:@"request_status"];
    
    requestData.request_type = [dict valueForKey:@"request_type"];
    
    requestData.request_type_id = [dict valueForKey:@"request_type_id"];
    
    requestData.requested_by_id = [NSString stringWithFormat:@"%@",[dict valueForKey:@"requested_by_id"]];
    
    requestData.requested_user_name = [dict valueForKey:@"requested_user_name"];
    
//    requestData.created_date_compare = [self getDateFromString:[dict valueForKey:@"created_date"]];
    
    NSArray *request_detail_array = [dict valueForKey:@"request_detail"];
    
    for (NSDictionary *request_detail_dic in request_detail_array) {
        if ([[request_detail_dic valueForKey:@"key"] isEqual:@"request_text"]) {
            requestData.request_text = [[ISRequestTextModelClass alloc] init];
            
            requestData.request_text.key = [request_detail_dic valueForKey:@"key"];
            requestData.request_text.value = [request_detail_dic valueForKey:@"value"];
            requestData.request_text.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
        else if ([[request_detail_dic valueForKey:@"key"] isEqual:@"source_address"]) {
            requestData.source_address = [[ISSourceAddressModel alloc] init];
            
            requestData.source_address.key = [request_detail_dic valueForKey:@"key"];
            requestData.source_address.value = [request_detail_dic valueForKey:@"value"];
            requestData.source_address.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
        else if ([[request_detail_dic valueForKey:@"key"] isEqual:@"destination_address"]) {
            requestData.destination_address = [[ISDestinationAddressModel alloc] init];
            
            requestData.destination_address.key = [request_detail_dic valueForKey:@"key"];
            requestData.destination_address.value = [request_detail_dic valueForKey:@"value"];
            requestData.destination_address.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
        else if ([[request_detail_dic valueForKey:@"key"] isEqual:@"due_date"]) {
            requestData.due_date = [[ISDueDateModel alloc] init];
            
            requestData.due_date.key = [request_detail_dic valueForKey:@"key"];
            
            NSString *dateTime = [request_detail_dic valueForKey:@"value"];
            
            requestData.due_date.value = [self getDateTimeString:dateTime];
            requestData.created_date_compare = [self getDateFromString:dateTime];

            requestData.due_date.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
        else if ([[request_detail_dic valueForKey:@"key"] isEqual:@"contact_number"]) {
            requestData.contact_number = [[ISContactNumberModel alloc] init];
            
            requestData.contact_number.key = [request_detail_dic valueForKey:@"key"];
            requestData.contact_number.value = [request_detail_dic valueForKey:@"value"];
            requestData.contact_number.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
    }
    return requestData;
}

- (ISRequestDataModel *) parseEventRequestDict : (NSDictionary *) dict {
    
    ISRequestDataModel *requestData = [[ISRequestDataModel alloc] init];
    
    requestData.accepted_user_name = [dict valueForKey:@"accepted_user_name"];
    
    requestData.created_date = [dict valueForKey:@"created_date"];
    
    requestData.group_id = [dict valueForKey:@"group_id"];
    
    requestData.is_archived = [dict valueForKey:@"is_archived"];
    
    requestData.modified_date = [dict valueForKey:@"modified_date"];
    
    requestData.request_accepted_by_id = [dict valueForKey:@"request_accepted_by_id"];
    
    requestData.request_id = [dict valueForKey:@"request_id"];
    
    requestData.request_is_delete = [dict valueForKey:@"request_is_delete"];
    
    requestData.request_message = [dict valueForKey:@"request_message"];
    
    requestData.request_status = [dict valueForKey:@"request_status"];
    
    requestData.request_type = [dict valueForKey:@"request_type"];
    
    requestData.request_type_id = [dict valueForKey:@"request_type_id"];
    
    requestData.requested_by_id = [dict valueForKey:@"requested_by_id"];
    
    requestData.requested_user_name = [dict valueForKey:@"requested_user_name"];
    
//    requestData.created_date_compare = [self getDateFromString:[dict valueForKey:@"created_date"]];
    
    NSArray *request_detail_array = [dict valueForKey:@"request_detail"];
    
    for (NSDictionary *request_detail_dic in request_detail_array) {
        if ([[request_detail_dic valueForKey:@"key"] isEqual:@"request_text"]) {
            requestData.request_text = [[ISRequestTextModelClass alloc] init];
            
            requestData.request_text.key = [request_detail_dic valueForKey:@"key"];
            requestData.request_text.value = [request_detail_dic valueForKey:@"value"];
            requestData.request_text.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
        else if ([[request_detail_dic valueForKey:@"key"] isEqual:@"due_date"]) {
            requestData.due_date = [[ISDueDateModel alloc] init];
            
            requestData.due_date.key = [request_detail_dic valueForKey:@"key"];
            
            NSString *dateTime = [request_detail_dic valueForKey:@"value"];
            
            requestData.created_date_compare = [self getDateFromString:dateTime];

            requestData.due_date.value = [self getDateTimeString:dateTime];
            requestData.due_date.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
        }
    }
    
    return requestData;
}

- (NSString *) getDateTimeString : (NSString *) dateTime {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    utcDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate *date = [utcDateFormatter dateFromString:dateTime];
    utcDateFormatter.dateFormat = @"dd MMM yy, h:mm a";
    
    NSString *finalDateTimeString = [utcDateFormatter stringFromDate:date];
    
    return finalDateTimeString;
}

- (NSString *) getTimeFromDateTime : (NSString *) dateTime {
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    utcDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    utcDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSDate *date = [utcDateFormatter dateFromString:dateTime];
    utcDateFormatter.dateFormat = @"h:mm a";
    utcDateFormatter.timeZone = [NSTimeZone localTimeZone];
    
    NSString *finalDateTimeString = [utcDateFormatter stringFromDate:date];
    
    return finalDateTimeString;
}

-(NSDate *)getDateFromString :(NSString *)dateTime{
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    utcDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    utcDateFormatter.timeZone = [NSTimeZone localTimeZone];
    
    NSDate *date = [utcDateFormatter dateFromString:dateTime];
    return date;
    
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.groupRequestArray.count == 0) {
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblGroupDetailList.frame.size.width, self.tblGroupDetailList.frame.size.height)];
        
        if (self.isArchiveRequest)
        {
            noDataLabel.text = @"No Archived messages in group";
        }
        else
        {
            noDataLabel.text = @"You have no active request. Please tap on + button to add new";
        }
        
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor blackColor];
        noDataLabel.numberOfLines = 0;
        self.tblGroupDetailList.backgroundView = noDataLabel;
        return 0;
    }
    else {
        self.tblGroupDetailList.backgroundView = nil;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupRequestArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ISRequestDataModel *requestData = [self.groupRequestArray objectAtIndex:indexPath.row];
    
    if([requestData.request_type_id isEqual:@1]) {
        ISCarpoolGroupTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISCarpoolGroupTableCell" forIndexPath:indexPath];
        
        NSString *name = [[AppData sharedInstance] fetchContactName:requestData.requested_by_id];
        if ([name isEqualToString:@""])
        {
            cell.lblRequesterName.text = requestData.requested_user_name;
        }
        else
        {
            cell.lblRequesterName.text = [[AppData sharedInstance] fetchContactName:requestData.requested_by_id];
        }
        
        //cell.lblRequesterName.text = requestData.requested_user_name;
        //fetchContactName
        
        cell.lblRequestText.text = [NSString stringWithFormat:@"%@ - %@",requestData.request_text.value, requestData.contact_number.value];
        
        cell.lblRequestFrom.text = requestData.source_address.value;
        
        cell.lblRequestTo.text = requestData.destination_address.value;
        
        cell.lblRequestDateTime.text = requestData.due_date.value;
        
        cell.lblRequestAccepterName.hidden = true;
        
        if([requestData.request_status  isEqual: @"Accepted"]){
            if(requestData.request_accepted_by_id == [[AppData sharedInstance] getUserId]) {
                cell.lblRequestAccepterName.text = [NSString stringWithFormat:@"Accepted by me"];
                cell.lblRequestAccepterName.hidden = false;
                cell.imgRequestStatus.hidden = true;
            }
            else if([requestData.request_accepted_by_id  isEqual: @0]) {
                cell.lblRequestAccepterName.hidden = true;
                cell.imgRequestStatus.hidden = true;
            }
            else {
                
                NSString *name = [[AppData sharedInstance] fetchContactName:requestData.request_accepted_by_id];
                if ([name isEqualToString:@""])
                {
                    cell.lblRequestAccepterName.text = requestData.accepted_user_name;
                }
                else
                {
                    cell.lblRequestAccepterName.text = [NSString stringWithFormat:@"%@ Accepted",[[AppData sharedInstance] fetchContactName:requestData.request_accepted_by_id]];
                }
                
                cell.lblRequestAccepterName.hidden = false;
                cell.imgRequestStatus.hidden = true;
            }
        }
        else if([requestData.request_status  isEqual: @"Pending"]){
            if(requestData.requested_by_id != [[AppData sharedInstance] getUserId]) {
                cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_check_green"];
                cell.imgRequestStatus.hidden = false;
            }
            else
            {
                cell.imgRequestStatus.hidden = true;
                cell.lblRequestAccepterName.hidden = true;
            }
        }
        else if([requestData.request_status  isEqual: @"Rejected"]){
            cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_cancel_red"];
            cell.imgRequestStatus.hidden = false;
        }
        else
        {
            cell.imgRequestStatus.hidden = true;
            cell.lblRequestAccepterName.hidden = true;
        }
        //        if(requestData.request_accepted_by_id == [[AppData sharedInstance] getUserId]) {
        //            cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_cancel_red"];
        //            cell.imgRequestStatus.hidden = false;
        //        }
        //        else if([requestData.request_status  isEqual: @"Pending"]){
        //            cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_check_green"];
        //            cell.imgRequestStatus.hidden = false;
        //        }
        //        else {
        //            cell.imgRequestStatus.hidden = true;
        //        }
        
        //        if(requestData.request_accepted_by_id == [[AppData sharedInstance] getUserId]) {
        //
        //            cell.lblRequestAccepterName.text = [NSString stringWithFormat:@"You Accepted"];
        //            cell.lblRequestAccepterName.hidden = false;
        //        }
        //        else if([requestData.request_accepted_by_id  isEqual: @0]) {
        //            cell.lblRequestAccepterName.hidden = true;
        //        }
        //        else {
        //            cell.lblRequestAccepterName.text = [NSString stringWithFormat:@"%@ Accepted",requestData.accepted_user_name];
        //            cell.lblRequestAccepterName.hidden = false;
        //        }
        
        cell.lblRequestTime.text = [self getTimeFromDateTime:requestData.created_date];
        
        return cell;
    }
    else {
        ISEventGroupTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISEventGroupTableCell" forIndexPath:indexPath];
        
        NSString *name = [[AppData sharedInstance] fetchContactName:requestData.requested_by_id];
        if ([name isEqualToString:@""])
        {
            cell.lblRequesterName.text = requestData.requested_user_name;
        }
        else
        {
            cell.lblRequesterName.text = [[AppData sharedInstance] fetchContactName:requestData.requested_by_id];
        }
        
        
        
        //cell.lblRequesterName.text = requestData.requested_user_name;
        cell.lblRequestText.text = requestData.request_text.value;
        
        cell.lblRequestDateTime.text = requestData.due_date.value;
        
        cell.lblRequestTime.text = [self getTimeFromDateTime:requestData.created_date];
        
        cell.lblAcceptedBy.hidden = true;
        
        if([requestData.request_status  isEqual: @"Accepted"]){
            if(requestData.request_accepted_by_id == [[AppData sharedInstance] getUserId]) {
                cell.lblAcceptedBy.text = [NSString stringWithFormat:@"Accepted by me"];
                cell.lblAcceptedBy.hidden = false;
                cell.imgRequestStatus.hidden = true;
            }
            else if([requestData.request_accepted_by_id  isEqual: @0]) {
                cell.lblAcceptedBy.hidden = true;
                cell.imgRequestStatus.hidden = true;
            }
            else {
                
                NSString *name = [[AppData sharedInstance] fetchContactName:requestData.request_accepted_by_id];
                if ([name isEqualToString:@""])
                {
                    cell.lblAcceptedBy.text = requestData.accepted_user_name;
                }
                else
                {
                    cell.lblAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",[[AppData sharedInstance] fetchContactName:requestData.request_accepted_by_id]];
                }
                
                cell.lblAcceptedBy.hidden = false;
                cell.imgRequestStatus.hidden = true;
            }
        }
        else if([requestData.request_status  isEqual: @"Pending"]){
            if(requestData.requested_by_id != [[AppData sharedInstance] getUserId]) {
                cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_check_green"];
                cell.imgRequestStatus.hidden = false;
            }
            else
            {
                cell.imgRequestStatus.hidden = true;
                cell.lblAcceptedBy.hidden = true;
            }
        }
        else if([requestData.request_status  isEqual: @"Rejected"]){
            cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_cancel_red"];
            cell.imgRequestStatus.hidden = false;
        }
        else
        {
            cell.imgRequestStatus.hidden = true;
            cell.lblAcceptedBy.hidden = true;
        }
        
        return cell;
    }
    
    //    if(indexPath.row == 1) {
    //        ISEventGroupTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISEventGroupTableCell" forIndexPath:indexPath];
    //        return cell;
    //    }
    //    else {
    //        ISCarpoolGroupTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISCarpoolGroupTableCell" forIndexPath:indexPath];
    //
    //        if (indexPath.row == 0) {
    //            cell.lblRequesterName.text = @"Martina";
    //            cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_check_green"];
    //            cell.imgRequestStatus.hidden = false;
    //
    //            cell.lblRequestAccepterName.hidden = true;
    //        }
    //        else if(indexPath.row == 2) {
    //            cell.lblRequesterName.text = @"Me";
    //            cell.imgRequestStatus.hidden = true;
    //            cell.lblRequestAccepterName.hidden = false;
    //            cell.lblRequestAccepterName.text = @"Alexey Rybin Accepted";
    //        }
    //        else if(indexPath.row == 3) {
    //            cell.lblRequesterName.text = @"Martina";
    //
    //            cell.imgRequestStatus.hidden = true;
    //            cell.lblRequestAccepterName.hidden = false;
    //            cell.lblRequestAccepterName.text = @"Alexey Rybin Accepted";
    //
    //        }
    //        else if(indexPath.row == 4) {
    //            cell.lblRequesterName.text = @"Martina";
    //            cell.imgRequestStatus.hidden = false;
    //            cell.imgRequestStatus.image = [UIImage imageNamed:@"ic_cancel_red"];
    //            cell.lblRequestAccepterName.hidden = false;
    //            cell.lblRequestAccepterName.text = @"You Accepted";
    //        }
    //
    //        return cell;
    //    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ISRequestDataModel *requestData = [self.groupRequestArray objectAtIndex:indexPath.row];
    
    if([requestData.request_type_id isEqual:@1]) {
        return 100;
    }
    else {
        //        return 65;
        return UITableViewAutomaticDimension;
    }
    
    //    if(indexPath.row == 1) {
    //        return 65;
    //    }
    //    else {
    //        return 100;
    //    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ISRequestDataModel *requestData = [self.groupRequestArray objectAtIndex:indexPath.row];
    
    if([requestData.request_type_id isEqual:@1]) {
        ISCarpoolRequestDetailVC *carpoolRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISCarpoolRequestDetailVC"];
        carpoolRequestDetailVC.requestData = requestData;
        carpoolRequestDetailVC.delegate = self;
        
        if([requestData.request_status  isEqual: @"Pending"]) {
            carpoolRequestDetailVC.carpoolRequestType = 1;
        }
        else if([requestData.request_status  isEqual: @"Accepted"]) {
            carpoolRequestDetailVC.carpoolRequestType = 2;
        }
        else if([requestData.request_status  isEqual: @"Rejected"]) {
            carpoolRequestDetailVC.carpoolRequestType = 1;
        }
        else if([requestData.request_status  isEqual: @"Expired"]){
            carpoolRequestDetailVC.carpoolRequestType = 1;
        }
        else if(requestData.requested_by_id == [[AppData sharedInstance] getUserId]) {
            carpoolRequestDetailVC.carpoolRequestType = 4;
        }
        else if([requestData.request_accepted_by_id isEqual:[[AppData sharedInstance] getUserId]]) {
            carpoolRequestDetailVC.carpoolRequestType = 3;
        }
        
        [self.navigationController pushViewController:carpoolRequestDetailVC animated:true];
    }
    else {
        ICEventRequestDetailVC *eventRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ICEventRequestDetailVC"];
        eventRequestDetailVC.requestData = requestData;
        eventRequestDetailVC.delegate = self;
        if([requestData.request_status  isEqual: @"Pending"]) {
            eventRequestDetailVC.eventRequestType = 1;
        }
        else if([requestData.request_status  isEqual: @"Accepted"]) {
            eventRequestDetailVC.eventRequestType = 2;
        }
        else if([requestData.request_status  isEqual: @"Rejected"]) {
            eventRequestDetailVC.eventRequestType = 1;
        }
        else if([requestData.request_status  isEqual: @"Expired"]){
            eventRequestDetailVC.eventRequestType = 1;
        }
        else if(requestData.requested_by_id == [[AppData sharedInstance] getUserId]) {
            eventRequestDetailVC.eventRequestType = 4;
        }
        else if([requestData.request_accepted_by_id isEqual:[[AppData sharedInstance] getUserId]]) {
            eventRequestDetailVC.eventRequestType = 3;
        }
        
        [self.navigationController pushViewController:eventRequestDetailVC animated:true];
    }
    
    //    if (indexPath.row == 1) {
    //
    //        ICEventRequestDetailVC *eventRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ICEventRequestDetailVC"];
    //        eventRequestDetailVC.eventRequestType = 4;
    //        [self.navigationController pushViewController:eventRequestDetailVC animated:true];
    //    }
    //    else {
    //        ISCarpoolRequestDetailVC *carpoolRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISCarpoolRequestDetailVC"];
    //        if(indexPath.row == 0) {
    //            carpoolRequestDetailVC.carpoolRequestType = 1;
    //        }
    //        else if(indexPath.row == 2) {
    //            carpoolRequestDetailVC.carpoolRequestType = 4;
    //        }
    //        else if(indexPath.row == 3) {
    //            carpoolRequestDetailVC.carpoolRequestType = 2;
    //        }
    //        else if(indexPath.row == 4) {
    //            carpoolRequestDetailVC.carpoolRequestType = 3;
    //        }
    //        [self.navigationController pushViewController:carpoolRequestDetailVC animated:true];
    //    }
}

#pragma mark - ISCarpoolRequestDetailDelegate

- (void)userManipulateCarpoolRequest {
    [self getAllRequestOfGroup:self.start_limit];
}

#pragma mark - ICEventRequestDetailDelegate

- (void)userManipulateEventRequest {
    [self getAllRequestOfGroup:self.start_limit];
}

#pragma mark - GetAllRequestOfGroup API Call

- (void) getAllRequestOfGroup : (NSInteger) start_limit {
    
    NSDictionary *param;
    NSString *endUrl;
    if (self.isArchiveRequest)
    {
        //param = @{@"group_id":@"9"};
        param = @{@"group_id":self.groupData.group_id};
        endUrl = @"GetArchievedRequestOfGroup";
    }
    else
    {
        param = @{@"group_id":self.groupData.group_id,@"start_limit":@"0",@"num_of_records":@"10"};
        endUrl = GetAllRequestOfGroup;
    }
    
    //NSDictionary *param = @{@"group_id":self.groupData.group_id,@"start_limit":@"0",@"num_of_records":@"10"};
    
    if (self.groupRequestArray.count == 0)
    {
        [SVProgressHUD showWithStatus:@"Loading"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    [APIUtility servicePostToEndPoint:endUrl withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if(isSuccess) {
            self.start_limit = 0;
            
            [self.groupRequestArray removeAllObjects];
            
            [tblRefreshControl endRefreshing];
            
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                //                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    if([response valueForKey:@"Requests"] != nil || [response valueForKey:@"ArchivedRequest"] != nil) {
                        self.start_limit = self.start_limit + 10 ;
                        NSArray *requests;
                        
                        [self deleteRecordFromLocal];
                        
                        if (self.isArchiveRequest)
                        {
                            requests = [response valueForKey:@"ArchivedRequest"];
                        }
                        else
                        {
                            requests = [response valueForKey:@"Requests"];
                        }
                        
                        [self saveRequestDataToLocal:requests];
                        [self parseRequestsArray:requests];
                    }
                }
                else if([status isEqualToString:@"2"]) {
                    NSArray *blankArray = [[NSArray alloc] init];
                    [self deleteRecordFromLocal];
                    [self parseRequestsArray:blankArray];
                    //                    [AppData displayAlert:message];
                }
            }
        }
        else{
            NSLog(@"%@",error.localizedDescription);
            //            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
    }];
}

- (void)sortData
{
//    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_date_compare"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.groupRequestArray sortedArrayUsingDescriptors:sortDescriptors];
    
    NSArray *Pending = [sortedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"request_status = %@", @"Pending"]];
    NSArray *Accepted = [sortedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"request_status = %@", @"Accepted"]];
    NSArray *Rejected = [sortedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"request_status = %@", @"Rejected"]];
    NSArray *Expired = [sortedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"request_status = %@", @"Expired"]];
    
    [self.groupRequestArray removeAllObjects];
    
//    [self.groupRequestArray addObjectsFromArray:Pending];
//    [self.groupRequestArray addObjectsFromArray:Accepted];
//    [self.groupRequestArray addObjectsFromArray:Rejected];
//    
//    if(self.isArchiveRequest) {
//        [self.groupRequestArray addObjectsFromArray:Expired];
//    }
    
    
    
    NSMutableArray *tempGroupArray = [[NSMutableArray alloc] init];
    
    [tempGroupArray addObjectsFromArray:Pending];
    [tempGroupArray addObjectsFromArray:Accepted];
    [tempGroupArray addObjectsFromArray:Rejected];
    
    if(self.isArchiveRequest) {
        [tempGroupArray addObjectsFromArray:Expired];
    }
    
    self.groupRequestArray = [NSMutableArray arrayWithArray:[tempGroupArray sortedArrayUsingDescriptors:sortDescriptors]];

    
    //    for (ISRequestDataModel *model in sortedArray)
    //    {
    //        if ([model.request_status isEqualToString:@"Pending"])
    //        {
    //            [tempArray insertObject:model atIndex:0];
    //        }
    //        else
    //        {
    //            [tempArray addObject:model];
    //        }
    //    }
    //
    //[self.groupRequestArray addObjectsFromArray:sortedArray];
    [self.tblGroupDetailList reloadData];
}

-(NSMutableArray *)sortArrayWithKey:(NSString *)sortingKey andArray:(NSMutableArray *)unsortedArray{
    NSSortDescriptor *lastDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:NO selector:@selector(compare:)];
    NSArray *descriptors = [NSArray arrayWithObjects: lastDescriptor, nil];
    return [unsortedArray sortedArrayUsingDescriptors:descriptors].mutableCopy;
}


NSComparisonResult dateSort1(NSString *s1, void *context) {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    utcDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate *date = [utcDateFormatter dateFromString:s1];
    utcDateFormatter.dateFormat = @"dd MMM yy, h:mm a";
    
    
    NSDate *d1 = date;
    NSDate *d2 = [[NSDate alloc]init];
    
    return [d1 compare:d2];
}

- (void)fetchData:(void(^)(void))completion {
    
    NSDictionary *param;
    NSString *endUrl;
    if (self.isArchiveRequest)
    {
        param = @{@"group_id":self.groupData.group_id};
        //param = @{@"group_id":@"9"};
        endUrl = @"GetArchievedRequestOfGroup";
    }
    else
    {
        param = @{@"group_id":self.groupData.group_id,@"start_limit":[NSString stringWithFormat:@"%ld",(long)self.start_limit],@"num_of_records":@"10"};
        endUrl = GetAllRequestOfGroup;
    }
    
    [APIUtility servicePostToEndPoint:endUrl withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        if(isSuccess) {
            if(response != nil) {
                NSLog(@"%@",response);
                
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    if([response valueForKey:@"Requests"] != nil || [response valueForKey:@"ArchivedRequest"] != nil) {
                        self.start_limit = self.start_limit + 10;
                        NSArray *requests = [response valueForKey:@"Requests"];
                        [self parseRequestsArray:requests];
                    }
                }
                else {
                    //                    [AppData displayAlert:message];
                }
            }
        }
        else{
            NSLog(@"%@",error.localizedDescription);
            //            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
        completion();
        
        //[self sortData];
    }];
}

- (IBAction)btnArchivesClicked:(id)sender {
//    ISGroupDetailVC *groupDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISGroupDetailVC"];
//    groupDetailVC.groupData = self.groupData;
//    groupDetailVC.isArchiveRequest = YES;
//    [self.navigationController pushViewController:groupDetailVC animated:YES];
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
    NSFetchRequest *allRequest = [[NSFetchRequest alloc] init];
    
    if (self.isArchiveRequest)
    {
        [allRequest setEntity:[NSEntityDescription entityForName:@"Tbl_ArchivedRequest" inManagedObjectContext:context]];
    }
    else
    {
        [allRequest setEntity:[NSEntityDescription entityForName:@"Tbl_Request" inManagedObjectContext:context]];
    }
    
    allRequest.predicate = [NSPredicate predicateWithFormat:@"group_id == %@", self.groupData.group_id];
    
    [allRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *requests = [context executeFetchRequest:allRequest error:&error];
    //error handling goes here
    for (NSManagedObject *request in requests) {
        [context deleteObject:request];
    }
    NSError *saveError = nil;
    [context save:&saveError];
}

- (void)saveRequestDataToLocal:(NSArray *)Requests
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newRequest;
    if (self.isArchiveRequest)
    {
        newRequest = [NSEntityDescription insertNewObjectForEntityForName:@"Tbl_ArchivedRequest" inManagedObjectContext:context];
        [newRequest setValue:[NSKeyedArchiver archivedDataWithRootObject:Requests] forKey:@"archivedRequest"];
    }
    else
    {
        newRequest = [NSEntityDescription insertNewObjectForEntityForName:@"Tbl_Request" inManagedObjectContext:context];
        [newRequest setValue:[NSKeyedArchiver archivedDataWithRootObject:Requests] forKey:@"request"];
    }
    
    [newRequest setValue:[NSString stringWithFormat:@"%@",self.groupData.group_id] forKey:@"group_id"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)fetchRecordFromLocal
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity;
    if (self.isArchiveRequest)
    {
        entity = [NSEntityDescription entityForName:@"Tbl_ArchivedRequest" inManagedObjectContext:[self managedObjectContext]];
    }
    else
    {
        entity = [NSEntityDescription entityForName:@"Tbl_Request" inManagedObjectContext:[self managedObjectContext]];
    }
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group_id == %@", self.groupData.group_id];
    //fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]];
    
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        //NSLog(@"%@", result);
        if (result.count > 0) {
            //NSMutableArray *tempData = [[NSMutableArray alloc]init];
            for (NSManagedObject *request in result)
            {
                //NSLog(@"1 - %@", group);
                
                if (self.isArchiveRequest)
                {
                    NSArray *Requests = [NSKeyedUnarchiver unarchiveObjectWithData:[request valueForKey:@"archivedRequest"]];
                    [self parseRequestsArray:Requests];
                    //NSDictionary *tempDict = @{@"ArchivedRequest":Requests};
                    //[tempData addObject:Requests];
                    break;
                }
                else
                {
                    NSArray *Requests = [NSKeyedUnarchiver unarchiveObjectWithData:[request valueForKey:@"request"]];
                    [self parseRequestsArray:Requests];
                    // NSDictionary *tempDict = @{@"Requests":Requests};
                    //[tempData addObject:Requests];
                    break;
                }
                
                //NSLog(@"2 - %@", group);
            }
            
            //[self sortData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                //[self getAllGroupAPICall];
                [self getAllRequestOfGroup:self.start_limit];
            });
        }
        else
        {
            //[self getAllGroupAPICall];
            [self getAllRequestOfGroup:self.start_limit];
        }
    }
}

- (void)getGroupDetails {
    
    NSDictionary *param = @{@"group_id":self.groupData.group_id};
    
    [APIUtility servicePostToEndPoint:GetGroupDetails withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        if(isSuccess) {
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                
                if([status isEqualToString:@"1"]) {
                    NSArray *requests = [response valueForKey:@"Group"];
                    [self parseGroupData:requests];
                }
                else {
                    //                    [AppData displayAlert:message];
                }
            }
        }
        else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

- (void)parseGroupData:(NSArray *)groups {
    
    for (NSDictionary *group_dict in groups) {
        
        ISGroupDataModel *groupData = [[ISGroupDataModel alloc] init];
        
        groupData.group_id = [group_dict valueForKey:@"group_id"];
        
        groupData.group_name = [group_dict valueForKey:@"group_name"];
        
        groupData.group_icon = [group_dict valueForKey:@"group_icon"];
        
        groupData.admin_id = [group_dict valueForKey:@"admin_id"];
        
        groupData.request_badge = [NSString stringWithFormat:@"%@",[group_dict valueForKey:@"request_badge"]];
        
        NSArray *grop_members = [group_dict valueForKey:@"grop_members"];
        
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
        
        self.groupData = groupData;
        
        [self setNavigationBarTitle];
    }
}




@end
