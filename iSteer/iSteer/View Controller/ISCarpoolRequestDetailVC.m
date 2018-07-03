//
//  ISCarpoolRequestDetailVC.m
//  iSteer
//
//  Created by EL Capitan on 20/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISCarpoolRequestDetailVC.h"

@interface ISCarpoolRequestDetailVC ()

@end

@implementation ISCarpoolRequestDetailVC

/*

 carpoolRequestType = 1 Accept/Reject Request
 carpoolRequestType = 2 Other User Accepted Request
 carpoolRequestType = 3 Current User Accepted Request
 carpoolRequestType = 4 Curent User Posted and Edit Request
 
*/

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.carpoolDatepicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.carpoolDatepicker setMinimumDate: [NSDate date]];
    
    self.viewAcceptMsgContainer.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    self.viewAcceptMsgContainer.layer.cornerRadius = 10;
    self.viewAcceptMsgContainer.layer.borderWidth = 1;
    self.viewAcceptMsgContainer.clipsToBounds = true;
    
    [self setNavigationButton];
    
    [self manageViewByRequestType];
    
    [self setTextFieldPadding];
    
    self.txtCarpoolTo.enabled = false;
    self.txtCarpoolPhoneNumber.enabled  = false;
    self.txtCarpoolWho.enabled = false;
    self.txtCarpoolFrom.enabled = false;
    self.btnWho.enabled = false;
    [self setCarpoolRequestData];
    
    if(self.isFromNotification) {
        self.txtCarpoolTo.text = @"";
        self.txtCarpoolPhoneNumber.text = @"";
        self.txtCarpoolWho.text = @"";
        self.txtCarpoolFrom.text = @"";
        
        [self getRequestDetailAPICall];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (void) backButtonClicked {
    [self.navigationController popViewControllerAnimated:true];
}

- (void) editRequestButtonClicked {
    [self editCurrentUserRequest];
}

- (IBAction)btnSaveEditRequestClicked:(id)sender {
    [self carpoolRequestType4];
}

- (IBAction)btnAcceptRequestClicked:(id)sender {

//    [self.navigationController popViewControllerAnimated:true];

    [self acceptRequestInGroupAPICall];

//    ISRequestTextPopUpVC *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"ISRequestTextPopUpVC"];
//    
//    BIZPopupViewController *popupViewController = [[BIZPopupViewController alloc] initWithContentViewController:cv contentSize:CGSizeMake(280, 250)];
//    popupViewController.showDismissButton = false;
//    [self presentViewController:popupViewController animated:NO completion:nil];
}

- (IBAction)btnRejectRequestClicked:(id)sender {
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FavorFox" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self rejectRequestInGroupAPICall];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
//    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)carpoolDatePickerChanged:(id)sender {
    self.lblSelectTime.text = [self getTimeStringFromDatePicker:self.carpoolDatepicker];
}

- (NSString *) getTimeStringFromDatePicker : (UIDatePicker *) datePicker {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd MMM yy, h:mm a"];
    
    return [outputFormatter stringFromDate:datePicker.date];
}


- (IBAction)btnSaveClicked:(id)sender {
    [self updateRequestInGroupAPICall];
}

- (IBAction)btnWhoClicked:(id)sender {
    ISLocalContactVC *localContactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISLocalContactVC"];
    localContactVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:localContactVC];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - ISLocalContactVCDelegate

//- (void)localContactSelected:(NSString *)number {
//    self.txtCarpoolWho.text = number;
//}

- (void) localContactSelected:(NSString *)number name:(NSString *)name {
    self.selectedName = name;
    self.selectedContactNumber = number;
    
    self.txtCarpoolWho.text = [NSString stringWithFormat:@"%@ - %@",name,number];
}

#pragma mark - Custom Method

- (void) setTextFieldPadding {
    UIView *txtCarpoolTopaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtCarpoolTo.leftView = txtCarpoolTopaddingView;
    self.txtCarpoolTo.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *txtCarpoolWhopaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtCarpoolWho.leftView = txtCarpoolWhopaddingView;
    self.txtCarpoolWho.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *txtCarpoolPhonepaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtCarpoolPhoneNumber.leftView = txtCarpoolPhonepaddingView;
    self.txtCarpoolPhoneNumber.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *txtCarpoolFrompaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.txtCarpoolFrom.leftView = txtCarpoolFrompaddingView;
    self.txtCarpoolFrom.leftViewMode = UITextFieldViewModeAlways;
}

- (void) setNavigationButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 40, 40)];
//    [backButton setBackgroundColor:[UIColor redColor]];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
    
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] init];
    leftBarButton.customView = backButton;
    
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (void) setRightEditNavigationBarButton {
//    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_edit_white"] style:UIBarButtonItemStylePlain target:self action:@selector(editRequestButtonClicked)];
//    
//    self.navigationItem.rightBarButtonItem = addBarButton;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addButton addTarget:self action:@selector(editRequestButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"ic_edit_white"] forState:UIControlStateNormal];
    
    addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    addButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] init];
    rightBarButton.customView = addButton;
    
    self.navigationItem.rightBarButtonItem = rightBarButton;

}


- (void) manageViewByRequestType {
    if(self.carpoolRequestType == 1) {
        
        [self carpoolRequestType1];
    }
    else if(self.carpoolRequestType == 2) {
        //self.navigationItem.title = [NSString stringWithFormat:@"%@ Request",[[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id]];
        
        [self carpoolRequestType2];
    }
    else if(self.carpoolRequestType == 3) {
        //self.navigationItem.title = [NSString stringWithFormat:@"%@ Request",[[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id]];

        [self carpoolRequestType3];
    }
    else if(self.carpoolRequestType == 4) {
        //self.navigationItem.title = @"My Request";

        [self carpoolRequestType4];
    }
}

- (void) carpoolRequestType1 {
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectType.text = @"Type";
    
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = false;
    
    self.btnAceept.hidden = false;
    self.btnReject.hidden = true;
    
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = true;
    
    self.textViewAceeptMsg.editable = true;
    
    self.viewAcceptMsg.hidden = false;
    self.viewAcceptMsgHeight.constant = 110;
    
    self.textViewAceeptMsg.delegate = self;
    self.textViewAceeptMsg.text = @"Message text here...";
    self.textViewAceeptMsg.textColor = [UIColor lightGrayColor];
    
    if ([self.requestData.requested_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
    {
        [self setRightEditNavigationBarButton];
    }
}

- (void) carpoolRequestType2 {
    self.requestAcceptMessageViewHeight.constant = 40;
    
    self.lblSelectType.text = @"Type";
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = false;
    
    if ([self.requestData.request_accepted_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
    {
        self.btnAceept.hidden = true;
        self.btnReject.hidden = false;
        
        self.viewOtherUserAcceptText.hidden = true;
        self.viewCurrentUserAcceptText.hidden = false;
    }
    else
    {
        self.btnAceept.hidden = true;
        self.btnReject.hidden = true;
        
        self.viewOtherUserAcceptText.hidden = false;
        self.viewCurrentUserAcceptText.hidden = true;
    }

    
    self.viewAcceptMsg.hidden = true;
    self.viewAcceptMsgHeight.constant = 0;
    self.textViewAceeptMsg.hidden = true;
    
    if ([self.requestData.requested_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
    {
        [self setRightEditNavigationBarButton];
    }
}

- (void) carpoolRequestType3 {
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectType.text = @"Type";
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = true;
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = false;
    
    self.viewAcceptMsg.hidden = true;
    self.viewAcceptMsgHeight.constant = 0;
    self.textViewAceeptMsg.hidden = true;
}

- (void) carpoolRequestType4 {
    [self setRightEditNavigationBarButton];
    
    //    self.requestAcceptMessageViewHeight.constant = 40;
    //
    //    self.lblSelectType.text = @"Type";
    //    self.lblSelectTimeText.hidden = true;
    //    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    //
    //    self.viewDatePicker.hidden = true;
    //    self.viewAcceptRejectRequest.hidden = false;
    //    self.viewOtherUserAcceptText.hidden = false;
    //    self.viewCurrentUserAcceptText.hidden = true;
    //
    //    self.txtCarpoolTo.enabled = false;
    //    self.txtCarpoolWho.enabled = false;
    //    self.txtCarpoolFrom.enabled = false;
    //
    //    self.viewAcceptMsg.backgroundColor = [UIColor purpleColor];
    //
    //    self.viewAcceptMsg.hidden = true;
    //    self.viewAcceptMsgHeight.constant = 0;
    //    self.textViewAceeptMsg.hidden = true;
    
    
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectType.text = @"Type";
    
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = false;
    
    if(self.requestData.accepted_user_name != nil) {
        if ([self.requestData.request_accepted_by_id integerValue] != 0)
        {
            self.btnReject.hidden = false;
            self.btnAceept.hidden = true;
            
            self.viewAcceptMsg.hidden = true;
            self.viewAcceptMsgHeight.constant = 0;
            self.textViewAceeptMsg.hidden = true;
        }
        else
        {
            self.btnReject.hidden = true;
            self.btnAceept.hidden = false;
            self.textViewAceeptMsg.editable = true;
            
            self.viewAcceptMsg.hidden = false;
            self.viewAcceptMsgHeight.constant = 110;
            
            self.textViewAceeptMsg.delegate = self;
            self.textViewAceeptMsg.text = @"Message text here...";
            self.textViewAceeptMsg.textColor = [UIColor lightGrayColor];
            //self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",self.requestData.accepted_user_name];
        }
        
    }
    //    self.btnAceept.hidden = false;
    //    self.btnReject.hidden = true;
    
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = true;
    
    
    //[self.view layoutIfNeeded];
}

- (void) editCurrentUserRequest {
    self.navigationItem.rightBarButtonItem = nil;
    
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectType.text = @"Type";
    self.lblSelectTimeText.hidden = false;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentRight];
    
    self.viewDatePicker.hidden = false;
    self.viewAcceptRejectRequest.hidden = true;
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = true;
    
    self.btnWho.enabled = true;
    
    self.txtCarpoolTo.enabled = true;
    self.txtCarpoolWho.enabled = true;
    self.txtCarpoolPhoneNumber.enabled = true;
    self.txtCarpoolFrom.enabled = true;
}

- (void) setCarpoolRequestData {
    if(self.requestData != nil) {
        self.txtCarpoolWho.text = self.requestData.request_text.value;
        self.txtCarpoolPhoneNumber.text = self.requestData.contact_number.value;
        self.txtCarpoolFrom.text = self.requestData.source_address.value;
        self.txtCarpoolTo.text = self.requestData.destination_address.value;
        
        self.lblSelectTime.text = self.requestData.due_date.value;
        
        if([self.requestData.is_archived  isEqual: @1]) {
            self.viewAcceptRejectRequest.hidden = true;
        }
        else {
            self.viewAcceptRejectRequest.hidden = false;
        }
        
        if(self.requestData.accepted_user_name != nil) {
            if ([self.requestData.request_accepted_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
            {
                self.lblRequestAcceptedBy.text = @"Accepted by me";
            }
            else
            {
                NSString *name = [[AppData sharedInstance] fetchContactName:self.requestData.request_accepted_by_id];
                if ([name isEqualToString:@""])
                {
                    self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",self.requestData.accepted_user_name];
                }
                else
                {
                    self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",[[AppData sharedInstance] fetchContactName:self.requestData.request_accepted_by_id]];
                }
                
//                self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",[[AppData sharedInstance] fetchContactName:self.requestData.request_accepted_by_id]];
            }
            
        }
        else
        {
            self.lblRequestAcceptedBy.text = @"";
        }
        
//        if(self.requestData.request_accepted_by_id == [[AppData sharedInstance] getUserId]) {
//            self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"Accepted by me"];
//        }
//        else {
//            self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",self.requestData.accepted_user_name];
//        }
        
        if(self.requestData.request_message != nil) {
            self.txtOtherUserRequestAcceptText.text = self.requestData.request_message;
            self.txtCurrentUserRequestAcceptText.text = self.requestData.request_message;
        }
        
        if([self.requestData.requested_by_id isEqual:[[AppData sharedInstance] getUserId]]) {
            self.navigationItem.title = @"My Request";
        }
        else {
            
            NSString *name = [[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id];
            if ([name isEqualToString:@""])
            {
                self.navigationItem.title = [NSString stringWithFormat:@"%@'s Request",self.requestData.requested_user_name];
            }
            else
            {
                self.navigationItem.title = [NSString stringWithFormat:@"%@'s Request",[[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id]];
            }
            
            //self.navigationItem.title = [NSString stringWithFormat:@"%@'s Request",[[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id]];
            //self.navigationItem.title = [NSString stringWithFormat:@"%@'s Request",self.requestData.requested_user_name];
        }
    }
}

#pragma mark - GetRequestDetail API Call

- (void) getRequestDetailAPICall {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *param = @{@"request_id":self.request_id};

    [APIUtility servicePostToEndPoint:GetRequestDetail withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        [SVProgressHUD dismiss];
        
        if(isSuccess) {
            
            NSLog(@"%@",response);
            
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [response valueForKey:@"message"];
            if([status  isEqual: @"1"]) {
                NSArray *requests = [response valueForKey:@"Requests"];
                [self parseRequestsArray:requests];
            }
            else {
                [AppData displayAlert:message];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
            if(error != nil) {
                NSLog(@"%@",error.localizedDescription);
            }
        }
    }];
}

- (void) parseRequestsArray : (NSArray *) requests {
    //    [self.groupRequestArray removeAllObjects];
    for (NSDictionary *request in requests) {
        if([[request valueForKey:@"request_type_id"]  isEqual: @1]) {
            //            NSLog(@"Carpool");
            
            self.requestData = [self parseCarpoolRequestDict:request];
        }
    }
    
    if([self.requestData.request_status  isEqual: @"Pending"]) {
        self.carpoolRequestType = 1;
    }
    else if([self.requestData.request_status  isEqual: @"Accepted"]) {
        self.carpoolRequestType = 2;
    }
    else if([self.requestData.request_status  isEqual: @"Rejected"]) {
        self.carpoolRequestType = 1;
    }
    else if(self.requestData.requested_by_id == [[AppData sharedInstance] getUserId]) {
        self.carpoolRequestType = 4;
    }
    else if([self.requestData.request_accepted_by_id isEqual:[[AppData sharedInstance] getUserId]]) {
        self.carpoolRequestType = 3;
    }
    
    [self manageViewByRequestType];
    [self setCarpoolRequestData];
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
    
    requestData.created_date_compare = [self getDateFromString:[dict valueForKey:@"created_date"]];
    
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

-(NSDate *)getDateFromString :(NSString *)dateTime{
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    utcDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    utcDateFormatter.timeZone = [NSTimeZone localTimeZone];
    
    NSDate *date = [utcDateFormatter dateFromString:dateTime];
    return date;
    
}


#pragma mark - AcceptRequestInGroup API Call

- (void) acceptRequestInGroupAPICall {
    
    NSString *requestMsg;
    if ([self.textViewAceeptMsg.text isEqualToString:@"Message text here..."])
    {
        requestMsg = @"";
    }
    else
    {
        requestMsg = self.textViewAceeptMsg.text;
    }
    
    NSDictionary *param = @{@"request_id":self.requestData.request_id,@"request_accepted_by_id":[[AppData sharedInstance] getUserId],@"group_id":self.requestData.group_id,@"request_message":requestMsg};
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    [APIUtility servicePostToEndPoint:AcceptRequestInGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if(isSuccess) {
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self.delegate userManipulateCarpoolRequest];
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    [AppData displayAlert:message];
                }
            }
        }
        else{
            NSLog(@"%@",error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
    }];
}

- (void) rejectRequestInGroupAPICall {
    
    NSDictionary *param = @{@"request_id":self.requestData.request_id,@"requested_user_id":[[AppData sharedInstance] getUserId],@"group_id":self.requestData.group_id};
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    

    [APIUtility servicePostToEndPoint:RejectRequestInGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        if(isSuccess) {
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self.delegate userManipulateCarpoolRequest];
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    [AppData displayAlert:message];
                }
            }
        }
        else{
            NSLog(@"%@",error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
        }
    }];
}

- (void) updateRequestInGroupAPICall {
    
    if([self.txtCarpoolWho.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter the person name"];
    }
    else if([self.txtCarpoolFrom.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter From location"];
    }
    else if([self.txtCarpoolTo.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter To location"];
    }
    else
    {
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSMutableArray *request_data = [[NSMutableArray alloc] init];
        
//        if(self.selectedName == nil) {
//            self.selectedName = self.requestData.request_text.value;
//        }
//        
//        if(self.selectedContactNumber == nil) {
//            self.selectedContactNumber = self.requestData.contact_number.value;
//        }
        
        NSDictionary *request_text = @{@"key":@"request_text",@"value":self.txtCarpoolWho.text,@"request_detail_id" : self.requestData.request_text.request_detail_id};
        NSDictionary *source_address = @{@"key":@"source_address",@"value":self.txtCarpoolFrom.text,@"request_detail_id" : self.requestData.source_address.request_detail_id};
        NSDictionary *destination_address = @{@"key":@"destination_address",@"value":self.txtCarpoolTo.text,@"request_detail_id" : self.requestData.destination_address.request_detail_id};
        
        NSString *requestDateTime = [self getDateTimeString:self.lblSelectTime.text];
        
        NSDictionary *due_date = @{@"key":@"due_date",@"value":requestDateTime,@"request_detail_id" : self.requestData.due_date.request_detail_id};
        
        NSString *contactNumber = self.txtCarpoolPhoneNumber.text;
        
        NSDictionary *contact_number = @{@"key":@"contact_number",@"value":contactNumber,@"request_detail_id" : self.requestData.contact_number.request_detail_id};
        
        [request_data addObject:request_text];
        [request_data addObject:source_address];
        [request_data addObject:destination_address];
        [request_data addObject:due_date];
        [request_data addObject:contact_number];
        
        NSDictionary *param = @{@"request_id":self.requestData.request_id,@"requested_user_id":user_id,@"request_data":request_data};
        
        NSLog(@"%@",param);
        
        //NSDictionary *param = @{@"request_id":self.requestData.request_id,@"requested_user_id":[[AppData sharedInstance] getUserId],@"group_id":self.requestData.group_id};
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        
        [APIUtility servicePostToEndPoint:UpdateRequestInGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
            [SVProgressHUD dismiss];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if(isSuccess) {
                if(response != nil) {
                    NSLog(@"%@",response);
                    
                    NSString *status = [response valueForKey:@"status"];
                    NSString *message = [response valueForKey:@"message"];
                    
                    if([status isEqualToString:@"1"]) {
                        [self.delegate userManipulateCarpoolRequest];
                        [self.navigationController popViewControllerAnimated:true];
                    }
                    else {
                        [AppData displayAlert:message];
                    }
                }
            }
            else{
                NSLog(@"%@",error.localizedDescription);
                [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
            }
        }];
    }
}


- (NSString *) getDateTimeString : (NSString *) time {
    
    NSDateFormatter *todayDateFormatter = [[NSDateFormatter alloc] init];
    todayDateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSDate *todayDate = [NSDate date];
    
    NSString *todayDateString = [todayDateFormatter stringFromDate:todayDate];
    
    NSString *todayDateTimeString = [NSString stringWithFormat:@"%@",time];
    
    NSLog(@"%@",todayDateTimeString);
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    utcDateFormatter.dateFormat = @"dd MMM yy, h:mm a";
    // utcDateFormatter.dateFormat = @"yyyy-MM-dd h:mm a";
    
    NSDate *dateTime = [utcDateFormatter dateFromString:todayDateTimeString];
    
    utcDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    utcDateFormatter.timeZone = [NSTimeZone localTimeZone];
    NSString *finalDateTimeString = [utcDateFormatter stringFromDate:dateTime];
    
    
    //    NSDate *date = [dateFormatter dateFromString:time];
    
    return finalDateTimeString;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Message text here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Message text here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}


@end
