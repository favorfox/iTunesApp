//
//  AppData.h
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>
#import "ISContactDataModel.h"
#import "Constants.h"
#import "ISCurrentUserData.h"
#import <AddressBook/AddressBook.h>
#import "ISLocalContactDataModel.h"

@protocol AppDataDelegate <NSObject>

@optional

//Delegate method to invoke After Contact fetched successfully
-(void)contactListFetched:(NSMutableArray *)array;

-(void)contactListFetchedWithLocalContact:(NSMutableArray *)array;

@end

@interface AppData : NSObject

@property (nonatomic, weak) id <AppDataDelegate> appDataDelegate;

@property (nonatomic, strong) NSString *deviceToken;
+ (AppData *)sharedInstance;

+ (void) getContactsList;
+ (void) getContactsListWithAllNumber;

+ (void) displayAlert : (NSString *) message;

- (NSArray *) shortAlphaNumericArray : (NSArray *) array;

- (void) saveUserData : (NSDictionary *) userData;
- (void) saveUserCountryCode : (NSString *) code;
- (void) saveUserDeviceToken : (NSString *) code;
- (NSString *) getUserDeviceToken;
- (NSString *) getUserCountryCode;
- (NSString *) getUserId;
- (NSString *) getUserContactNumber;
- (bool) isUserVerified;
- (void) verifyUser;
- (void) removeUserData;
- (ISCurrentUserData *) getCurrentUserData;
- (void) scanAddressBookSample:(NSString *)mobileNo aResultBlock:(void(^)(NSString *name))resultBlock;
- (NSString *)fetchContactName :(NSString *)requested_by_id;
@end
