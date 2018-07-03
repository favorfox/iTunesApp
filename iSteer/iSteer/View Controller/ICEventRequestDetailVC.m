//
//  ICEventRequestDetailVC.m
//  iSteer
//
//  Created by EL Capitan on 21/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ICEventRequestDetailVC.h"

@interface ICEventRequestDetailVC ()

@end

/*
 
 eventRequestType = 1 Accept/Reject Request
 eventRequestType = 2 Other User Accepted Request
 eventRequestType = 3 Current User Accepted Request
 eventRequestType = 4 Curent User Posted and Edit Request
 
 */

@implementation ICEventRequestDetailVC


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textViewAcceptMsg.delegate = self;
    
    self.eventDatePIcker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.eventDatePIcker setMinimumDate: [NSDate date]];

    [self setNavigationButton];
    
    [self manageViewByRequestType];
    
    [self setCarpoolRequestData];
    
    [self setCornerRadious];
    
    if(self.isFromNotification) {
        
        self.txtEventTask.text = @"";
        self.txtOtherUserRequestAcceptText.text = @"";
        self.txtCurrentUserRequestAcceptText.text = @"";
        self.lblRequestAcceptedBy.text = @"";
        
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
    [self eventRequestType4];
}

- (IBAction)btnAcceptRequestClicked:(id)sender {
    
    [self acceptRequestInGroupAPICall];

//    [self.navigationController popViewControllerAnimated:true];

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

- (IBAction)btnSaveClicked:(id)sender {
    [self updateRequestInGroupAPICall];
}

- (IBAction)eventDatePickerChanged:(id)sender {
    self.lblSelectTime.text = [self getTimeStringFromDatePicker:self.eventDatePIcker];
}

- (NSString *) getTimeStringFromDatePicker : (UIDatePicker *) datePicker {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd MMM yy, h:mm a"];
    
    return [outputFormatter stringFromDate:datePicker.date];
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
    for (NSDictionary *request in requests) {
        if([[request valueForKey:@"request_type_id"]  isEqual: @2]) {
            self.requestData = [self parseEventRequestDict:request];
        }
    }
    
    if([self.requestData.request_status  isEqual: @"Pending"]) {
        self.eventRequestType = 1;
    }
    else if([self.requestData.request_status  isEqual: @"Accepted"]) {
        self.eventRequestType = 2;
    }
    else if([self.requestData.request_status  isEqual: @"Rejected"]) {
        self.eventRequestType = 1;
    }
    else if(self.requestData.requested_by_id == [[AppData sharedInstance] getUserId]) {
        self.eventRequestType = 4;
    }
    else if([self.requestData.request_accepted_by_id isEqual:[[AppData sharedInstance] getUserId]]) {
        self.eventRequestType = 3;
    }
    
    [self manageViewByRequestType];
    [self setCarpoolRequestData];
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
    
    requestData.created_date_compare = [self getDateFromString:[dict valueForKey:@"created_date"]];
    
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
            
            requestData.due_date.value = [self getDateTimeString:dateTime];
            requestData.due_date.request_detail_id = [request_detail_dic valueForKey:@"request_detail_id"];
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


#pragma mark - Custom Method

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
    if(self.eventRequestType == 1) {
        [self eventRequestType1];
    }
    else if(self.eventRequestType == 2) {
        ///self.navigationItem.title = [NSString stringWithFormat:@"%@ Request",[[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id]];
        
        [self eventRequestType2];
    }
    else if(self.eventRequestType == 3) {
       // self.navigationItem.title = [NSString stringWithFormat:@"%@ Request",[[AppData sharedInstance] fetchContactName:self.requestData.requested_by_id]];
        
        [self eventRequestType3];
    }
    else if(self.eventRequestType == 4) {
        //self.navigationItem.title = @"My Request";
        
        [self eventRequestType4];
    }
}

- (void) eventRequestType1 {
    
    self.textViewAcceptMsg.editable = true;
    
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = false;
    self.btnAccept.hidden = false;
    self.btnReject.hidden = true;
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = true;
    
    self.acceptMsgView.hidden = false;
    self.aceeptMsgViewHeight.constant = 110;
    
    
    if ([self.requestData.requested_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
    {
        [self setRightEditNavigationBarButton];
    }
    
}

- (void) eventRequestType2 {
    self.requestAcceptMessageViewHeight.constant = 40;
    
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = false;
    if ([self.requestData.request_accepted_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
    {
        self.btnAccept.hidden = true;
        self.btnReject.hidden = false;
        
        self.viewOtherUserAcceptText.hidden = true;
        self.viewCurrentUserAcceptText.hidden = false;
    }
    else
    {
        self.btnAccept.hidden = true;
        self.btnReject.hidden = true;
        
        self.viewOtherUserAcceptText.hidden = false;
        self.viewCurrentUserAcceptText.hidden = true;
    }
    
    
   
    
    
//    self.viewOtherUserAcceptText.hidden = false;
//    self.viewCurrentUserAcceptText.hidden = false;
    
    self.acceptMsgView.hidden = true;
    self.aceeptMsgViewHeight.constant = 0;
    self.textViewAcceptMsg.hidden = true;
    
    if ([self.requestData.requested_by_id integerValue] == [[[AppData sharedInstance] getUserId] integerValue])
    {
        [self setRightEditNavigationBarButton];
    }
}

- (void) eventRequestType3 {
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = true;
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = false;
    
    self.acceptMsgView.hidden = true;
    self.aceeptMsgViewHeight.constant = 0;
    self.textViewAcceptMsg.hidden = true;
}

- (void) eventRequestType4 {
    [self setRightEditNavigationBarButton];
    
//    self.requestAcceptMessageViewHeight.constant = 40;
//    
//    self.lblSelectTimeText.hidden = true;
//    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
//    
//    self.viewDatePicker.hidden = true;
//    self.viewAcceptRejectRequest.hidden = true;
//    self.viewOtherUserAcceptText.hidden = false;
//    self.viewCurrentUserAcceptText.hidden = true;
//    
//    self.txtEventTask.editable = false;
//    self.txtEventTask.selectable = false;
//    
//    self.acceptMsgView.hidden = true;
//    self.aceeptMsgViewHeight.constant = 0;
// 
//    self.textViewAcceptMsg.hidden = true;
    
    self.textViewAcceptMsg.editable = true;
    
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectTimeText.hidden = true;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentLeft];
    
    self.viewDatePicker.hidden = true;
    self.viewAcceptRejectRequest.hidden = false;
    self.btnAccept.hidden = false;
    self.btnReject.hidden = true;
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = true;
    
    self.acceptMsgView.hidden = false;
    self.aceeptMsgViewHeight.constant = 110;
    
    if(self.requestData.accepted_user_name != nil) {
        if ([self.requestData.request_accepted_by_id integerValue] != 0)
        {
            self.btnReject.hidden = false;
            self.btnAccept.hidden = true;
            
            self.acceptMsgView.hidden = true;
            self.aceeptMsgViewHeight.constant = 0;
            self.textViewAcceptMsg.hidden = true;
        }
        else
        {
            self.btnReject.hidden = true;
            self.btnAccept.hidden = false;
            self.textViewAcceptMsg.editable = true;
            
            self.acceptMsgView.hidden = false;
            self.aceeptMsgViewHeight.constant = 110;
            
            self.textViewAcceptMsg.delegate = self;
            self.textViewAcceptMsg.text = @"Message text here...";
            self.textViewAcceptMsg.textColor = [UIColor lightGrayColor];
            //self.lblRequestAcceptedBy.text = [NSString stringWithFormat:@"%@ Accepted",self.requestData.accepted_user_name];
        }
    }
}

- (void) editCurrentUserRequest {
    self.navigationItem.rightBarButtonItem = nil;
    
    self.requestAcceptMessageViewHeight.constant = 0;
    
    self.lblSelectTimeText.hidden = false;
    [self.lblSelectTime setTextAlignment:NSTextAlignmentRight];
    
    self.viewDatePicker.hidden = false;
    self.viewAcceptRejectRequest.hidden = true;
    self.viewOtherUserAcceptText.hidden = true;
    self.viewCurrentUserAcceptText.hidden = true;
    
    self.txtEventTask.editable = true;
}

- (void) setCarpoolRequestData {
    if(self.requestData != nil) {
        self.txtEventTask.text = self.requestData.request_text.value;
        
        self.lblSelectTime.text = self.requestData.due_date.value;
        
        if([self.requestData.is_archived  isEqual: @1]) {
            self.viewAcceptRejectRequest.hidden = true;
        }
        else {
            self.viewAcceptRejectRequest.hidden = false;
        }
        
        NSLog(@"%@",self.requestData.request_accepted_by_id);
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
            }
            
        }
        else
        {
            self.lblRequestAcceptedBy.text = @"";
        }
        
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
            
            //
        }
    }
}

- (void) setCornerRadious {
    self.textViewBGView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    self.textViewBGView.layer.cornerRadius = 10;
    self.textViewBGView.layer.borderWidth = 1;
    self.textViewBGView.clipsToBounds = true;
    
    self.textViewContainerView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    self.textViewContainerView.layer.cornerRadius = 10;
    self.textViewContainerView.layer.borderWidth = 1;
    self.textViewContainerView.clipsToBounds = true;
}

- (void) acceptRequestInGroupAPICall {
    
    NSString *requestMsg;
    if ([self.textViewAcceptMsg.text isEqualToString:@"Message text here..."])
    {
        requestMsg = @"";
    }
    else
    {
        requestMsg = self.textViewAcceptMsg.text;
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
                    [self.delegate userManipulateEventRequest];
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
     [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    

    [APIUtility servicePostToEndPoint:RejectRequestInGroup withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        if(isSuccess) {
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    [self.delegate userManipulateEventRequest];
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
    
    
    if([self.txtEventTask.text  isEqual: @""] || [self.txtEventTask.text  isEqual: @"Task"]) {
        [AppData displayAlert:@"Please enter Event Task"];
    }
    else {
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSMutableArray *request_data = [[NSMutableArray alloc] init];
        
        NSString *requestDateTime = [self getDateTimeString:self.lblSelectTime.text];
        
        NSDictionary *request_text = @{@"key":@"request_text",@"value":self.txtEventTask.text,@"request_detail_id" : self.requestData.request_text.request_detail_id};
        
        NSDictionary *due_date = @{@"key":@"due_date",@"value":requestDateTime,@"request_detail_id" : self.requestData.due_date.request_detail_id};
        
        [request_data addObject:request_text];
        [request_data addObject:due_date];
        
        NSDictionary *param = @{@"request_id":self.requestData.request_id,@"requested_user_id":user_id,@"request_data":request_data};
        
        NSLog(@"%@",param);
        
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
                        [self.delegate userManipulateEventRequest];
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
