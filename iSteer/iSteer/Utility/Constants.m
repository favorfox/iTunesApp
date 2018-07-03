//
//  Constants.m
//  iSteer
//
//  Created by EL Capitan on 21/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "Constants.h"

@implementation Constants

//API URL
//NSString *const APIBaseImageURL          = @"http://clientapp.narola.online/pg/iSteer/ws";
//NSString *const APIBaseURL              = @"http://clientapp.narola.online/pg/iSteer/ws/iSteerWebservice.php?Service=";

//Production

NSString *const APIBaseImageURL          = @"http://54.203.15.120/ws";
NSString *const APIBaseURL              = @"http://54.203.15.120/ws/iSteerWebservice.php?Service=";


NSString *const SendConfirmationCode    = @"SendConfirmationCode";
NSString *const ValidateOTPCode         = @"ValidateOTPCode";
NSString *const UpdateProfile           = @"UpdateProfile";
NSString *const CreateGroup             = @"CreateGroup";
NSString *const GetAllGroups            = @"GetAllGroups";
NSString *const GetContactsDetail       = @"GetContactsDetail";
NSString *const ChangeGroupName         = @"ChangeGroupName";
NSString *const ChangeGroupIcon         = @"ChangeGroupIcon";
NSString *const RemoveMemberFromGroup   = @"RemoveMemberFromGroup";
NSString *const AddMemberInGroup        = @"AddMemberInGroup";
NSString *const GetGroupMemebrs         = @"GetGroupMemebrs";
NSString *const Register                = @"Register";
NSString *const SendRequestInGroup      = @"SendRequestInGroup";
NSString *const SendRequestInGroupRecurrence = @"SendRequestInGroupRecurrence";
NSString *const GetAllRequestOfGroup    = @"GetAllRequestOfGroup";
NSString *const AcceptRequestInGroup    = @"AcceptRequestInGroup";
NSString *const RejectRequestInGroup    = @"RejectRequestInGroup";
NSString *const Logout                  = @"Logout";
NSString *const GetArchievedRequestOfGroup = @"GetArchievedRequestOfGroup";
NSString *const UpdateRequestInGroup    = @"UpdateRequestInGroup";
NSString *const GetRequestDetail        = @"GetRequestDetail";
NSString *const UpdateDeviceToken       = @"UpdateDeviceToken";
NSString *const GetGroupDetails         = @"GetGroupDetails";
NSString *const DeleteGroup             = @"DeleteGroup";

// Variable
NSString *const SMS_Mode                = @"Nexmo";
NSString *const Device_Type             = @"1";
NSString *const Is_Testdata             = @"yes";

NSString *const ISUserId                  = @"UserId";
NSString *const ISUserContactNumber       = @"UserContactNumber";
NSString *const ISUserNickName            = @"UserName";
NSString *const ISUserProfilePic          = @"UserProfilePic";
NSString *const ISUserCountryCode         = @"UserCountryCode";
NSString *const ISUserVerified            = @"UserVerified";
NSString *const ISUserDeviceToken         = @"ISUserDeviceToken";
@end
