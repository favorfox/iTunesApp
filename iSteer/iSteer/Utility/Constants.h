//
//  Constants.h
//  iSteer
//
//  Created by EL Capitan on 21/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

//API URL
FOUNDATION_EXPORT NSString *const APIBaseImageURL;
FOUNDATION_EXPORT NSString *const APIBaseURL;

FOUNDATION_EXPORT NSString *const SendConfirmationCode;
FOUNDATION_EXPORT NSString *const ValidateOTPCode;
FOUNDATION_EXPORT NSString *const UpdateProfile;
FOUNDATION_EXPORT NSString *const CreateGroup;
FOUNDATION_EXPORT NSString *const GetAllGroups;
FOUNDATION_EXPORT NSString *const GetContactsDetail;
FOUNDATION_EXPORT NSString *const ChangeGroupName;
FOUNDATION_EXPORT NSString *const ChangeGroupIcon;
FOUNDATION_EXPORT NSString *const RemoveMemberFromGroup;
FOUNDATION_EXPORT NSString *const AddMemberInGroup;
FOUNDATION_EXPORT NSString *const GetGroupMemebrs;
FOUNDATION_EXPORT NSString *const Register;
FOUNDATION_EXPORT NSString *const SendRequestInGroup;
FOUNDATION_EXPORT NSString *const SendRequestInGroupRecurrence;
FOUNDATION_EXPORT NSString *const GetAllRequestOfGroup;
FOUNDATION_EXPORT NSString *const AcceptRequestInGroup;
FOUNDATION_EXPORT NSString *const RejectRequestInGroup;
FOUNDATION_EXPORT NSString *const Logout;
FOUNDATION_EXPORT NSString *const UpdateRequestInGroup;
FOUNDATION_EXPORT NSString *const GetRequestDetail;
FOUNDATION_EXPORT NSString *const UpdateDeviceToken;
FOUNDATION_EXPORT NSString *const GetGroupDetails;
FOUNDATION_EXPORT NSString *const DeleteGroup;

// Variable
FOUNDATION_EXPORT NSString *const SMS_Mode;
FOUNDATION_EXPORT NSString *const Device_Type;
FOUNDATION_EXPORT NSString *const Is_Testdata;


FOUNDATION_EXPORT NSString *const ISUserId;
FOUNDATION_EXPORT NSString *const ISUserContactNumber;
FOUNDATION_EXPORT NSString *const ISUserNickName;
FOUNDATION_EXPORT NSString *const ISUserProfilePic;
FOUNDATION_EXPORT NSString *const ISUserCountryCode;
FOUNDATION_EXPORT NSString *const ISUserVerified;
FOUNDATION_EXPORT NSString *const ISUserDeviceToken;

@end
