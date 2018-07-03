//
//  ISNewRequestVC.m
//  iSteer
//
//  Created by EL Capitan on 18/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

//363 Event view default height
//411 Caropool view default height


#import "ISNewRequestVC.h"

@interface ISNewRequestVC ()

@end

@implementation ISNewRequestVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Request";
    self.navigationItem.hidesBackButton = YES;
    
//    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel_white"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"ic_cancel_white"] forState:UIControlStateNormal];
    
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] init];
    cancelBarButton.customView = cancelButton;
    
    self.navigationItem.rightBarButtonItem = cancelBarButton;

    self.carpoolRepeatArray = [[NSMutableArray alloc] init];
    self.eventRepeatArray = [[NSMutableArray alloc] init];
    
    [self setCornerRadious];
    
    [self setTextFieldPadding];
    
    [self setCurrentTimeToSelectLabel];
    
    self.txtEventTask.delegate = self;
    
    [self.carpoolDatePicker setMinimumDate: [NSDate date]];
    
    NSDate *nextDate =  [self getNextDate:[NSDate date]];
    
    [self.carpoolRepeatDatePicker setMinimumDate: nextDate];
    
    [self.eventDatePicker setMinimumDate: [NSDate date]];
    [self.eventRepeatDatePicker setMinimumDate:nextDate];

    self.request_type_id = 1;
    
    self.isCarpoolRepeatSelected = false;
    
    self.tblCarpoolRepeatTable.delegate = self;
    self.tblCarpoolRepeatTable.dataSource = self;
    
    self.tblEventRepeatTable.delegate = self;
    self.tblEventRepeatTable.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (void) cancelButtonClicked {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnCarpoolClicked:(id)sender {
    [self.btnEvent setImage:[UIImage imageNamed:@"ic_dot_deselected"] forState:UIControlStateNormal];
    [self.btnCarpool setImage:[UIImage imageNamed:@"ic_dot_selected"] forState:UIControlStateNormal];
    
    self.request_type_id = 1;
    
    self.carpoolView.hidden = false;
    self.eventView.hidden = true;
}

- (IBAction)btnEventClicked:(id)sender {
    [self.btnEvent setImage:[UIImage imageNamed:@"ic_dot_selected"] forState:UIControlStateNormal];
    [self.btnCarpool setImage:[UIImage imageNamed:@"ic_dot_deselected"] forState:UIControlStateNormal];
    
    self.request_type_id = 2;

    self.carpoolView.hidden = true;
    self.eventView.hidden = false;
}

- (IBAction)btnSaveClicked:(id)sender {
    
    [self.view endEditing:true];
    
    if(self.request_type_id == 1) {
        [self carpoolRequest];
    }
    else if (self.request_type_id == 2) {
        [self eventRequest];
    }
    //[self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnWhoClicked:(id)sender {
    ISLocalContactVC *localContactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISLocalContactVC"];
    localContactVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:localContactVC];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (IBAction)btnCarpoolRepeatClicked:(id)sender {
    UIButton *button = sender;
    if([sender isSelected]) {
        self.constrainCarpoolScrollContainerView.constant = 463;
        self.carpoolScrollView.contentSize = CGSizeMake(self.carpoolScrollView.frame.size.width, 463);
        button.selected = false;
        [button setImage: [UIImage imageNamed:@"ic_checkbox_empty"] forState:UIControlStateNormal];
        self.isCarpoolRepeatSelected = false;
    }
    else {
        self.constrainCarpoolScrollContainerView.constant = 905;
        self.carpoolScrollView.contentSize = CGSizeMake(self.carpoolScrollView.frame.size.width, 905);
        button.selected = true;
        [button setImage: [UIImage imageNamed:@"ic_checkbox_filled"] forState:UIControlStateNormal];
        self.isCarpoolRepeatSelected = true;
        NSDate *nextDate = [self getNextDate:self.carpoolDatePicker.date];
        [self.carpoolRepeatDatePicker setDate:nextDate];
        [self setCarpoolDailyDays:self.carpoolDatePicker.date endDate:nextDate];
        self.isCarpoolDailyRepeatSelected = true;
    }
}

- (IBAction)btnEventRepeatClicked:(id)sender {
    UIButton *button = sender;
    if([sender isSelected]) {
        self.constrainEventScrollContainerView.constant = 363;
        self.eventScrollView.contentSize = CGSizeMake(self.eventScrollView.frame.size.width, 363);
        button.selected = false;
        [button setImage: [UIImage imageNamed:@"ic_checkbox_empty"] forState:UIControlStateNormal];
        self.isEventRepeatSelected = false;
    }
    else {
        self.constrainEventScrollContainerView.constant = 800;
        self.eventScrollView.contentSize = CGSizeMake(self.eventScrollView.frame.size.width, 800);
        button.selected = true;
        [button setImage: [UIImage imageNamed:@"ic_checkbox_filled"] forState:UIControlStateNormal];
        self.isEventRepeatSelected = true;
        NSDate *nextDate = [self getNextDate:self.eventDatePicker.date];
        [self.eventRepeatDatePicker setDate:nextDate];
        [self setEventDailyDays:self.eventDatePicker.date endDate:nextDate];
        self.isEventDailyRepeatSelected = true;
    }
}

- (IBAction)carpoolDatePickerChanged:(id)sender {
    self.lblCarpoolSelectTime.text = [self getTimeStringFromDatePicker:self.carpoolDatePicker];

    if(self.isCarpoolRepeatSelected) {
        if(self.isCarpoolDailyRepeatSelected) {
            NSLog(@"%@",self.carpoolDatePicker.date);
            NSDate *nextDate = [self getNextDate:self.carpoolDatePicker.date];
            [self.carpoolRepeatDatePicker setMinimumDate: nextDate];
            [self.carpoolRepeatDatePicker setDate:nextDate];
            
            [self setCarpoolDailyDays:self.carpoolDatePicker.date endDate:nextDate];
        }
        else {
            NSDate *nextDate = [self getNextWeekDate:self.carpoolDatePicker.date];
            [self.carpoolRepeatDatePicker setMinimumDate: nextDate];
            [self.carpoolRepeatDatePicker setDate: nextDate];
            
            [self setCarpoolWeeklyDays:self.carpoolDatePicker.date endDate:nextDate];
        }
    }
}

- (IBAction)carpoolRepeatDatePickerChanged:(id)sender {
    
        NSLog(@"%@",self.carpoolRepeatDatePicker.date);
        
        if(self.isCarpoolDailyRepeatSelected) {
            [self setCarpoolDailyDays:self.carpoolDatePicker.date endDate:self.carpoolRepeatDatePicker.date];
        }
        else {
            [self setCarpoolWeeklyDays:self.carpoolDatePicker.date endDate:self.carpoolRepeatDatePicker.date];
        }
}

- (IBAction)eventDatePickerChanged:(id)sender {
    self.lblEventSelectTime.text =  [self getTimeStringFromDatePicker:self.eventDatePicker];
    
    if(self.isEventRepeatSelected) {
        if(self.isEventDailyRepeatSelected) {
            NSLog(@"%@",self.eventDatePicker.date);
            NSDate *nextDate = [self getNextDate:self.eventDatePicker.date];
            [self.eventRepeatDatePicker setMinimumDate: nextDate];
            [self.eventRepeatDatePicker setDate:nextDate];
            
            [self setEventDailyDays :self.eventDatePicker.date endDate:nextDate];
        }
        else {
            NSDate *nextDate = [self getNextWeekDate:self.eventDatePicker.date];
            [self.eventRepeatDatePicker setMinimumDate: nextDate];
            [self.eventRepeatDatePicker setDate: nextDate];
            
            [self setEventWeeklyDays:self.eventDatePicker.date endDate:nextDate];
        }
    }
}

- (IBAction)eventRepeatDatePickerChanged:(id)sender {
    NSLog(@"%@",self.eventRepeatDatePicker.date);
    
    if(self.isEventDailyRepeatSelected) {
        [self setEventDailyDays:self.eventDatePicker.date endDate:self.eventRepeatDatePicker.date];
    }
    else {
        [self setEventWeeklyDays:self.eventDatePicker.date endDate:self.eventRepeatDatePicker.date];
    }

}

- (IBAction)btnCarpoolRepeatDailyClicked:(id)sender {
    self.isCarpoolDailyRepeatSelected = true;

    [self.carpoolRepeatArray removeAllObjects];
    
    [self.tblCarpoolRepeatTable reloadData];
    [self.carpoolDatePicker setMinimumDate: [NSDate date]];
    
    NSDate *nextDate = [self getNextDate:self.carpoolDatePicker.date];;
    
    [self.carpoolRepeatDatePicker setMinimumDate: nextDate];
    [self.carpoolRepeatDatePicker setDate:nextDate];

    [self.btnCarpoolRepeatWeekly setImage:[UIImage imageNamed:@"ic_dot_deselected"] forState:UIControlStateNormal];
    [self.btnCarpoolRepeatDaily setImage:[UIImage imageNamed:@"ic_dot_selected"] forState:UIControlStateNormal];
    
    [self setCarpoolDailyDays:self.carpoolDatePicker.date endDate:nextDate];

}

- (IBAction)btnCarpoolRepeatWeeklyClicked:(id)sender {
    self.isCarpoolDailyRepeatSelected = false;

    [self.carpoolRepeatArray removeAllObjects];
    
    [self.tblCarpoolRepeatTable reloadData];
    
    [self.carpoolDatePicker setMinimumDate: [NSDate date]];
    
    NSDate *nextDate = [self getNextWeekDate:self.carpoolDatePicker.date];
    
    NSLog(@"%@",self.carpoolDatePicker.date);
    NSLog(@"%@",nextDate);

    
    [self.carpoolRepeatDatePicker setMinimumDate: nextDate];
    [self.carpoolRepeatDatePicker setDate: nextDate];
    [self.btnCarpoolRepeatDaily setImage:[UIImage imageNamed:@"ic_dot_deselected"] forState:UIControlStateNormal];
    [self.btnCarpoolRepeatWeekly setImage:[UIImage imageNamed:@"ic_dot_selected"] forState:UIControlStateNormal];
    
    [self setCarpoolWeeklyDays:self.carpoolDatePicker.date endDate:self.carpoolRepeatDatePicker.date];
}

- (IBAction)btnEventRepeatDailyClicked:(id)sender {
    self.isEventDailyRepeatSelected = true;
    
    [self.eventRepeatArray removeAllObjects];
    
    [self.tblEventRepeatTable reloadData];
    [self.eventDatePicker setMinimumDate: [NSDate date]];
    
    NSDate *nextDate = [self getNextDate:self.eventDatePicker.date];;
    
    [self.eventRepeatDatePicker setMinimumDate: nextDate];
    [self.eventRepeatDatePicker setDate:nextDate];
    
    [self.btnEventRepeatWeekly setImage:[UIImage imageNamed:@"ic_dot_deselected"] forState:UIControlStateNormal];
    [self.btnEventRepeatDaily setImage:[UIImage imageNamed:@"ic_dot_selected"] forState:UIControlStateNormal];
    
    [self setEventDailyDays:self.eventDatePicker.date endDate:nextDate];
}

- (IBAction)btnEventRepeatWeeklyClicked:(id)sender {
    self.isEventDailyRepeatSelected = false;
    
    [self.eventRepeatArray removeAllObjects];
    
    [self.tblEventRepeatTable reloadData];
    
    [self.eventDatePicker setMinimumDate: [NSDate date]];
    
    NSDate *nextDate = [self getNextWeekDate:self.eventDatePicker.date];
    
    NSLog(@"%@",self.eventDatePicker.date);
    NSLog(@"%@",nextDate);
    
    
    [self.eventRepeatDatePicker setMinimumDate: nextDate];
    [self.eventRepeatDatePicker setDate: nextDate];
    [self.btnEventRepeatDaily setImage:[UIImage imageNamed:@"ic_dot_deselected"] forState:UIControlStateNormal];
    [self.btnEventRepeatWeekly setImage:[UIImage imageNamed:@"ic_dot_selected"] forState:UIControlStateNormal];
    
    [self setEventWeeklyDays:self.carpoolDatePicker.date endDate:self.carpoolRepeatDatePicker.date];

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

#pragma mark - Custom Methods

- (void) setCurrentTimeToSelectLabel {
    
    self.lblCarpoolSelectTime.text = [self getTimeStringFromDatePicker:self.carpoolDatePicker];
    
    self.lblEventSelectTime.text = [self getTimeStringFromDatePicker:self.eventDatePicker];
}

- (void) setCornerRadious {
    self.btnSave.layer.cornerRadius = 5;
    self.btnSave.clipsToBounds = true;

    self.textViewBGView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
    self.textViewBGView.layer.cornerRadius = 10;
    self.textViewBGView.layer.borderWidth = 1;
    self.textViewBGView.clipsToBounds = true;
}

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

- (NSString *) getTimeStringFromDatePicker : (UIDatePicker *) datePicker {

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd MMM yy, h:mm a"];
    
    return [outputFormatter stringFromDate:datePicker.date];
}

- (NSString *) getDateTimeStringFromDate : (NSDate *) date {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd MMM yy, h:mm a"];
    
    return [outputFormatter stringFromDate:date];
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

- (void) carpoolRequest {
    if([self.txtCarpoolWho.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter the person name"];
    }
    else if([self.txtCarpoolFrom.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter From location"];
    }
    else if([self.txtCarpoolTo.text  isEqual: @""]) {
        [AppData displayAlert:@"Please enter To location"];
    }
    else {
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSMutableArray *request_data = [[NSMutableArray alloc] init];
        
        NSDictionary *request_text = @{@"key":@"request_text",@"value":self.txtCarpoolWho.text};
        NSDictionary *source_address = @{@"key":@"source_address",@"value":self.txtCarpoolFrom.text};
        NSDictionary *destination_address = @{@"key":@"destination_address",@"value":self.txtCarpoolTo.text};

        NSString *requestDateTime = [self getDateTimeString:self.lblCarpoolSelectTime.text];
        
        NSDictionary *due_date = @{@"key":@"due_date",@"value":requestDateTime};

//        NSString *contactNumber = self.selectedContactNumber;
        
        NSDictionary *contact_number = @{@"key":@"contact_number",@"value":self.txtCarpoolPhoneNumber.text};
        
        NSMutableArray *recur_date_array = [[NSMutableArray alloc] init];
        
        if(self.isCarpoolRepeatSelected) {
            for (NSString *dateString in self.carpoolRepeatArray) {
                NSString *serverDateTime = [self getDateTimeString:dateString];
                [recur_date_array addObject:serverDateTime];
            }
        }
        else {
            [recur_date_array addObject:requestDateTime];
        }
        
        [request_data addObject:request_text];
        [request_data addObject:source_address];
        [request_data addObject:destination_address];
        [request_data addObject:due_date];
        [request_data addObject:contact_number];
        
        NSDictionary *param = @{@"group_id":self.groupData.group_id,@"request_type_id":@"1",@"requested_user_id":user_id,@"is_testdata":Is_Testdata,@"request_data":request_data,@"recur_date_array":recur_date_array};
        
        NSLog(@"%@",param);
        
        [self sendRequestInGroup:param];
    }
}

- (void) eventRequest {
    if([self.txtEventTask.text  isEqual: @""] || [self.txtEventTask.text  isEqual: @"Task"]) {
        [AppData displayAlert:@"Please enter Event Task"];
    }
    else {
        NSString *user_id = [[AppData sharedInstance] getUserId];
        
        NSMutableArray *request_data = [[NSMutableArray alloc] init];

        NSString *requestDateTime = [self getDateTimeString:self.lblEventSelectTime.text];
        
        NSDictionary *request_text = @{@"key":@"request_text",@"value":self.txtEventTask.text};
        
        NSDictionary *due_date = @{@"key":@"due_date",@"value":requestDateTime};
        
        NSMutableArray *recur_date_array = [[NSMutableArray alloc] init];
        
        if(self.isEventRepeatSelected) {
            for (NSString *dateString in self.eventRepeatArray) {
                NSString *serverDateTime = [self getDateTimeString:dateString];
                [recur_date_array addObject:serverDateTime];
            }
        }
        else {
            [recur_date_array addObject:requestDateTime];
        }
        
        [request_data addObject:request_text];
        [request_data addObject:due_date];

        NSDictionary *param = @{@"group_id":self.groupData.group_id,@"request_type_id":@"2",@"requested_user_id":user_id,@"is_testdata":Is_Testdata,@"request_data":request_data,@"recur_date_array":recur_date_array};

        NSLog(@"%@",param);
        
        [self sendRequestInGroup:param];
    }
}

#pragma mark - Date Maniputaliton

- (NSDate *) getNextDate : (NSDate *) date {
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:date options:0];
    return nextDate;
}

- (NSDate *) getNextWeekDate : (NSDate *) date {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 7;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:date options:0];
    return nextDate;
}

#pragma mark - Event

- (void) setCarpoolDailyDays : (NSDate *) startDate endDate: (NSDate *) endDate {
    
    [self.carpoolRepeatArray removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    
    NSString *dateString = [self getTimeStringFromDatePicker:self.carpoolDatePicker];
    
    [self.carpoolRepeatArray addObject:dateString];
    
    NSLog(@"%ld",(long)[components day]);
    
    NSInteger days = [components day];
    
    NSDate *nextDate = [self getNextDate:self.carpoolDatePicker.date];
    
    if (days > 0) {
        NSInteger i = 0;
        NSInteger repeatDaysCount = 0;

        while (i < days) {
            if(![calendar isDateInWeekend:nextDate]) {
                i++;
                repeatDaysCount++;
                
                if(repeatDaysCount == 5) {
                    break;
                }
                
                unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
                NSDateComponents* comp1 = [calendar components:unitFlags fromDate:nextDate];
                NSDateComponents* comp2 = [calendar components:unitFlags fromDate:self.carpoolRepeatDatePicker.date];
                
                NSDate *date1 = [calendar dateFromComponents:comp1];
                NSDate *date2 = [calendar dateFromComponents:comp2];
                
                NSComparisonResult result = [date1 compare:date2];
                if (result == NSOrderedAscending) {
                    NSLog(@"NSOrderedAscending");
                } else if (result == NSOrderedDescending) {
                    NSLog(@"NSOrderedDescending");
                    break;
                }
                
                NSString *dateString = [self getDateTimeStringFromDate:nextDate];
                
                [self.carpoolRepeatArray addObject:dateString];
                
                nextDate = [self getNextDate:nextDate];
                
            }
            else {
                nextDate = [self getNextDate:nextDate];
            }
        }
    }
    
    NSLog(@"%@",self.carpoolRepeatArray);
    
    [self.tblCarpoolRepeatTable reloadData];
}

- (void) setCarpoolWeeklyDays : (NSDate *) startDate endDate: (NSDate *) endDate {
    [self.carpoolRepeatArray removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:startDate
                                                 toDate:endDate
                                                options:0];
    
    NSInteger weeksDiffCount = (((NSInteger)[components day])/7);
    
    NSLog(@"%ld",weeksDiffCount);
    NSLog(@"%ld",[components day]);

    NSString *dateString = [self getDateTimeStringFromDate:self.carpoolDatePicker.date];
    
    [self.carpoolRepeatArray addObject:dateString];
    
    if (weeksDiffCount > 0) {
        NSDate *nextDate = [self getNextWeekDate:self.carpoolDatePicker.date];
        
            NSInteger i = 0;
            NSInteger repeatDaysCount = 0;
            
            while (i < weeksDiffCount) {
                i++;
                repeatDaysCount++;
                
                if(repeatDaysCount == 5) {
                    break;
                }
                
                unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
                NSDateComponents* comp1 = [calendar components:unitFlags fromDate:nextDate];
                NSDateComponents* comp2 = [calendar components:unitFlags fromDate:self.carpoolRepeatDatePicker.date];
                
                NSDate *date1 = [calendar dateFromComponents:comp1];
                NSDate *date2 = [calendar dateFromComponents:comp2];
                
                NSComparisonResult result = [date1 compare:date2];
                if (result == NSOrderedAscending) {
                    NSLog(@"NSOrderedAscending");
                } else if (result == NSOrderedDescending) {
                    NSLog(@"NSOrderedDescending");
                    break;
                }

                
                NSString *dateString = [self getDateTimeStringFromDate:nextDate];
                
                [self.carpoolRepeatArray addObject:dateString];
                
                nextDate = [self getNextWeekDate:nextDate];

            }
        

    }
    
    NSLog(@"%@",self.carpoolRepeatArray);

    
    [self.tblCarpoolRepeatTable reloadData];
}

#pragma mark - Event

- (void) setEventDailyDays : (NSDate *) startDate endDate: (NSDate *) endDate {
    
    [self.eventRepeatArray removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:startDate
                                                 toDate:endDate
                                                options:0];
    
    NSString *dateString = [self getTimeStringFromDatePicker:self.eventDatePicker];
    
    [self.eventRepeatArray addObject:dateString];
    
    NSLog(@"%ld",(long)[components day]);
    
    NSInteger days = [components day];
    
    NSDate *nextDate = [self getNextDate:self.eventDatePicker.date];
    
    if (days > 0) {
        NSInteger i = 0;
        NSInteger repeatDaysCount = 0;
        
        while (i < days) {
            if(![calendar isDateInWeekend:nextDate]) {
                i++;
                repeatDaysCount++;
                
                if(repeatDaysCount == 5) {
                    break;
                }

                unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
                NSDateComponents* comp1 = [calendar components:unitFlags fromDate:nextDate];
                NSDateComponents* comp2 = [calendar components:unitFlags fromDate:self.eventRepeatDatePicker.date];
                
                NSDate *date1 = [calendar dateFromComponents:comp1];
                NSDate *date2 = [calendar dateFromComponents:comp2];
                
                NSComparisonResult result = [date1 compare:date2];
                if (result == NSOrderedAscending) {
                    NSLog(@"NSOrderedAscending");
                } else if (result == NSOrderedDescending) {
                    NSLog(@"NSOrderedDescending");
                    break;
                }
                
//                if(nextDate > self.eventRepeatDatePicker.date) {
//                    break;
//                }
                
                NSString *dateString = [self getDateTimeStringFromDate:nextDate];
                
                [self.eventRepeatArray addObject:dateString];
                
                nextDate = [self getNextDate:nextDate];
                
                
            }
            else {
                nextDate = [self getNextDate:nextDate];
            }
        }
    }
    
    NSLog(@"%@",self.eventRepeatArray);
    
    [self.tblEventRepeatTable reloadData];
}

- (void) setEventWeeklyDays : (NSDate *) startDate endDate: (NSDate *) endDate {
    [self.eventRepeatArray removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:startDate
                                                 toDate:endDate
                                                options:0];
    
    NSInteger weeksDiffCount = (((NSInteger)[components day])/7);
    
    NSLog(@"%ld",weeksDiffCount);
    NSLog(@"%ld",[components day]);
    
    NSString *dateString = [self getDateTimeStringFromDate:self.eventDatePicker.date];
    
    [self.eventRepeatArray addObject:dateString];
    
    if (weeksDiffCount > 0) {
        NSDate *nextDate = [self getNextWeekDate:self.eventDatePicker.date];
        
        NSInteger i = 0;
        NSInteger repeatDaysCount = 0;
        
        while (i < weeksDiffCount) {
            i++;
            repeatDaysCount++;
            
            if(repeatDaysCount == 5) {
                break;
            }
            
            unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
            NSDateComponents* comp1 = [calendar components:unitFlags fromDate:nextDate];
            NSDateComponents* comp2 = [calendar components:unitFlags fromDate:self.eventRepeatDatePicker.date];
            
            NSDate *date1 = [calendar dateFromComponents:comp1];
            NSDate *date2 = [calendar dateFromComponents:comp2];
            
            NSComparisonResult result = [date1 compare:date2];
            if (result == NSOrderedAscending) {
                NSLog(@"NSOrderedAscending");
            } else if (result == NSOrderedDescending) {
                NSLog(@"NSOrderedDescending");
                break;
            }

            
            NSString *dateString = [self getDateTimeStringFromDate:nextDate];
            
            [self.eventRepeatArray addObject:dateString];
            
            nextDate = [self getNextWeekDate:nextDate];
        }
        
        
    }
    
    NSLog(@"%@",self.eventRepeatArray);
    
    [self.tblEventRepeatTable reloadData];
}


#pragma mark - SendRequestInGroup API Call

- (void) sendRequestInGroup : (NSDictionary *) param {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Creating Request"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [APIUtility servicePostToEndPoint:SendRequestInGroupRecurrence withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if(isSuccess) {
            
            NSLog(@"%@",response);
            
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [response valueForKey:@"message"];
            if([status  isEqual: @"1"]) {
                
                [self.delegate newEventAdded];
                [self.navigationController popViewControllerAnimated:true];
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FavorFox" message:@"Request added successfully" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//
//                }];
//                [alert addAction:okAction];
//                
//                [self presentViewController:alert animated:true completion:nil];
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

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Task"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Task";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}


#pragma mark - UITableView Delegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tblCarpoolRepeatTable) {
        return self.carpoolRepeatArray.count;
    }
    else {
        return self.eventRepeatArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.tblCarpoolRepeatTable) {
        ISNewRequestDateTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISNewRequestDateTableCell" forIndexPath:indexPath];
        cell.lblSelectedDate.text = [self.carpoolRepeatArray objectAtIndex:indexPath.row];
        
        return cell;
    }
    else {
        ISNewRequestDateTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ISNewRequestDateTableCell" forIndexPath:indexPath];
        cell.lblSelectedDate.text = [self.eventRepeatArray objectAtIndex:indexPath.row];
        return cell;
    }
}

@end
