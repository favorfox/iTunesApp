//
//  ISNewRequestVC.h
//  iSteer
//
//  Created by EL Capitan on 18/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "APIUtility.h"
#import "ISGroupDataModel.h"
#import "Constants.h"
#import "ISLocalContactVC.h"
#import "ISNewRequestDateTableCell.h"

@protocol  ISNewRequestDelegate<NSObject>

@required

- (void) newEventAdded;

@end

@interface ISNewRequestVC : UIViewController <UITextViewDelegate,ISLocalContactVCDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *btnCarpool;
@property (weak, nonatomic) IBOutlet UIButton *btnEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnCarpoolRepeatDaily;
@property (weak, nonatomic) IBOutlet UIButton *btnCarpoolRepeatWeekly;
@property (weak, nonatomic) IBOutlet UIButton *btnEventRepeatWeekly;

@property (weak, nonatomic) IBOutlet UIButton *btnEventRepeatDaily;


@property (weak, nonatomic) IBOutlet UIView *textViewBGView;

@property (weak, nonatomic) IBOutlet UIView *eventView;
@property (weak, nonatomic) IBOutlet UIView *carpoolView;

@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolWho;
@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolPhoneNumber;

@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolFrom;
@property (weak, nonatomic) IBOutlet UITextField *txtCarpoolTo;

@property (weak, nonatomic) IBOutlet UITextView *txtEventTask;

@property (weak, nonatomic) IBOutlet UIDatePicker *carpoolDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *carpoolRepeatDatePicker;

@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventRepeatDatePicker;


@property (weak, nonatomic) IBOutlet UILabel *lblCarpoolSelectTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEventSelectTime;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainCarpoolScrollContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainEventScrollContainerView;

@property (weak, nonatomic) IBOutlet UIScrollView *carpoolScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *eventScrollView;


@property (weak, nonatomic) IBOutlet UITableView *tblCarpoolRepeatTable;
@property (weak, nonatomic) IBOutlet UITableView *tblEventRepeatTable;


- (IBAction)btnCarpoolClicked:(id)sender;
- (IBAction)btnEventClicked:(id)sender;
- (IBAction)btnSaveClicked:(id)sender;
- (IBAction)btnWhoClicked:(id)sender;

- (IBAction)btnCarpoolRepeatClicked:(id)sender;
- (IBAction)btnEventRepeatClicked:(id)sender;

- (IBAction)btnCarpoolRepeatDailyClicked:(id)sender;
- (IBAction)btnCarpoolRepeatWeeklyClicked:(id)sender;

- (IBAction)btnEventRepeatDailyClicked:(id)sender;
- (IBAction)btnEventRepeatWeeklyClicked:(id)sender;

#pragma mark - Date Picker Event

- (IBAction)carpoolDatePickerChanged:(id)sender;
- (IBAction)carpoolRepeatDatePickerChanged:(id)sender;
- (IBAction)eventDatePickerChanged:(id)sender;
- (IBAction)eventRepeatDatePickerChanged:(id)sender;


@property (nonatomic, assign) NSInteger request_type_id;

@property (strong, nonatomic) ISGroupDataModel *groupData;

@property (nonatomic, weak) id <ISNewRequestDelegate> delegate;

@property (nonatomic, strong) NSString *selectedName;

@property (nonatomic, strong) NSString *selectedContactNumber;

// Repeat of Carpool Clicked
@property (nonatomic, assign) bool isCarpoolRepeatSelected;

// Weekly and Daily of Carpool
@property (nonatomic, assign) bool isCarpoolDailyRepeatSelected;


// Repeat of Event Clicked

@property (nonatomic, assign) bool isEventRepeatSelected;

// Weekly and Daily of Event
@property (nonatomic, assign) bool isEventDailyRepeatSelected;

@property (nonatomic, strong) NSMutableArray *carpoolRepeatArray;
@property (nonatomic, strong) NSMutableArray *eventRepeatArray;

@end
