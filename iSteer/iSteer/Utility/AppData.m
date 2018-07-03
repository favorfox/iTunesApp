//
//  AppData.m
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "AppData.h"
NSUserDefaults *userDefault;

@implementation AppData

+ (AppData *)sharedInstance
{
    static AppData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppData alloc] init];
        userDefault = [NSUserDefaults standardUserDefaults];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (void) getContactsList {
    
    NSMutableArray *contactListArray = [[NSMutableArray alloc] init];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    NSString *userCountryCode = [[AppData sharedInstance] getUserCountryCode];
    
    if([userCountryCode  isEqual: @""]) {
        NSString *countryIdentifier = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
        NSDictionary *countryCode = [self getCountryCodeDictionary];
        userCountryCode = [NSString stringWithFormat:@"+%@",[countryCode objectForKey:countryIdentifier]];
    }

    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //Keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            }
            else {
                NSString *phone = @"";
                NSString *fullName = @"";
                NSString *firstName = @"";
                NSString *lastName = @"";
                UIImage *profileImage;
                NSMutableArray *contactNumbersArray;
                
                //loop through all the contacts that was fetched from the local phone book also
                for (CNContact *contact in cnContacts) {
                    // copy data to my custom Contacts class.
                    
                    
                    
//                    for (CNLabeledValue *label in contact.phoneNumbers) {
////                        phone = [label.value stringValue];
////                        if ([phone length] > 0) {
////                            [contactNumbersArray addObject:phone];
////                        }
//                        
//                        CNPhoneNumber *fulMobNumVar = label.value;
//                        NSString *countryCode = [fulMobNumVar valueForKey:@"countryCode"];
//                        NSString *mobileNumber = [fulMobNumVar valueForKey:@"digits"];
//                        
//                        if(mobileNumber.length == 10) {
//                        
//                        }
//                        else if(mobileNumber.length > 10) {
//                        
//                        }
//                        else {
//                        
//                        }
//                        
//                        NSLog(@"%@",countryCode);
//                        NSLog(@"%@",mobileNumber);
//                    }
                    if (contact.phoneNumbers.count > 1)
                    {
                        NSLog(@"Contact found");
                    }
                    if(contact.phoneNumbers.count > 0)
                    {
//                        CNLabeledValue *label = contact.phoneNumbers.firstObject;
                        
//                        CNPhoneNumber *fulMobNumVar = label.value;
                        NSString *countryCode;
//                         [fulMobNumVar valueForKey:@"countryCode"];
                        NSString *mobileNumber;
//                         [fulMobNumVar valueForKey:@"digits"];
                        NSMutableArray *mobileNum = [[NSMutableArray alloc] init];
                        for (CNLabeledValue *label in contact.phoneNumbers)
                        {
                            
                            ISContactDataModel *contactData = [[ISContactDataModel alloc]init];
                            
                            firstName = contact.givenName;
                            lastName = contact.familyName;
                            if (lastName == nil) {
                                fullName=[NSString stringWithFormat:@"%@",firstName];
                                lastName = @"";
                            }else if (firstName == nil){
                                fullName=[NSString stringWithFormat:@"%@",lastName];
                                firstName = @"";
                            }
                            else{
                                fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                            }
                            UIImage *image = [UIImage imageWithData:contact.imageData];
                            if (image != nil) {
                                profileImage = image;
                            }else{
                                profileImage = [UIImage imageNamed:@"ic_user_placeholder"];
                            }
                            
                            
                            CNPhoneNumber *fulMobNumVar = label.value;
                            countryCode = [fulMobNumVar valueForKey:@"countryCode"];
                            mobileNumber = [fulMobNumVar valueForKey:@"digits"];
                            //[mobileNum addObject:[fulMobNumVar stringValue]];
                            
                            
                            if(mobileNumber.length == 10) {
                                contactData.fullName = fullName;
                                contactData.firstName = firstName;
                                contactData.lastName = lastName;
                                contactData.phone = mobileNumber;
                                contactData.countryCode = userCountryCode;
                                contactData.profileImage = profileImage;
                            }
                            else if(mobileNumber.length > 10)
                            {
                                NSString *onlyMobileNumber = [mobileNumber substringFromIndex: [mobileNumber length] - 10];

                                NSString *onlyCountryCode = [mobileNumber stringByReplacingOccurrencesOfString:onlyMobileNumber withString:@""];
                                
                                NSString *countryCodeWithOutPlus = [onlyCountryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
                                
                                contactData.fullName = fullName;
                                contactData.firstName = firstName;
                                contactData.lastName = lastName;
                                contactData.phone = onlyMobileNumber;
                                contactData.countryCode = countryCodeWithOutPlus;
                                contactData.profileImage = profileImage;
                                //[contactListArray addObject:contactData];
                                
                            }
                            [contactListArray addObject:contactData];
                            

                        }
//                        NSLog(@"%@",countryCode);
//                        NSLog(@"%@",mobileNumber);
//                        
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppData sharedInstance].appDataDelegate contactListFetched:contactListArray];
                });
            }
        }
    }];
}


+ (void) getContactsListWithAllNumber {
    
    NSMutableArray *contactListArray = [[NSMutableArray alloc] init];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    NSString *userCountryCode = [[AppData sharedInstance] getUserCountryCode];
    
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //Keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            }
            else {
                NSString *fullName = @"";
                NSString *firstName = @"";
                NSString *lastName = @"";
                UIImage *profileImage;
                NSMutableArray *contactNumbersArray;
                
                //loop through all the contacts that was fetched from the local phone book
                for (CNContact *contact in cnContacts) {
                    // copy data to my custom Contacts class.

                    if(contact.phoneNumbers.count > 0)
                    {
                        NSString *countryCode;
                        
                        NSString *mobileNumber;
                        
                        ISLocalContactDataModel *contactData = [[ISLocalContactDataModel alloc]init];
                        
                        firstName = contact.givenName;
                        lastName = contact.familyName;
                        if (lastName == nil) {
                            fullName=[NSString stringWithFormat:@"%@",firstName];
                            lastName = @"";
                        }else if (firstName == nil){
                            fullName=[NSString stringWithFormat:@"%@",lastName];
                            firstName = @"";
                        }
                        else{
                            fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                        }
                        
                        UIImage *image = [UIImage imageWithData:contact.imageData];
                        if (image != nil) {
                            profileImage = image;
                        }else{
                            profileImage = [UIImage imageNamed:@"ic_user_placeholder"];
                        }
                        
                        contactData.fullName = fullName;
                        contactData.firstName = firstName;
                        contactData.lastName = lastName;
                        contactData.profileImage = profileImage;
                        contactData.phoneNumbers = [[NSMutableArray alloc] init];
                        
                        for (CNLabeledValue *label in contact.phoneNumbers)
                        {
                            CNPhoneNumber *fulMobNumVar = label.value;
                            countryCode = [fulMobNumVar valueForKey:@"countryCode"];
                            mobileNumber = [fulMobNumVar valueForKey:@"digits"];
                            
                            if (mobileNumber != nil) {
                                
                                if(mobileNumber.length >= 10) {
                                    [contactData.phoneNumbers addObject:mobileNumber];
                                }
                            }
                        }
                        
                        if(contactData.phoneNumbers.count > 0) {
                            [contactListArray addObject:contactData];
                        }

                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppData sharedInstance].appDataDelegate contactListFetchedWithLocalContact:contactListArray];
                });
            }
        }
    }];
}

- (NSArray *) shortAlphaNumericArray : (NSArray *) array {
    
    NSArray *sorted = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        /* NSOrderedAscending, NSOrderedSame, NSOrderedDescending */
        BOOL isPunct1 = [[NSCharacterSet punctuationCharacterSet] characterIsMember:[(NSString*)obj1 characterAtIndex:0]];
        BOOL isPunct2 = [[NSCharacterSet punctuationCharacterSet] characterIsMember:[(NSString*)obj2 characterAtIndex:0]];
        if (isPunct1 && !isPunct2) {
            return NSOrderedAscending;
        }
        else if (!isPunct1 && isPunct2) {
            return NSOrderedDescending;
        }
        return [(NSString*)obj1 compare:obj2 options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
    }];
    
    return sorted;
}

#pragma mark - Alert

+ (void) displayAlert : (NSString *) message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FavorFox" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:true completion:nil];
    
}


+ (NSDictionary *) getCountryCodeDictionary {
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
            @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
            @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
            @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
            @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
            @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
            @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
            @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
            @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
            @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
            @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
            @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
            @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
            @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
            @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
            @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
            @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
            @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
            @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
            @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
            @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
            @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
            @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
            @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
            @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
            @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
            @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
            @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
            @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
            @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
            @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
            @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
            @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
            @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
            @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
            @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
            @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
            @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
            @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
            @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
            @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
            @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
            @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
            @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
            @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
            @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
            @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
            @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
            @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
            @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
            @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
            @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
            @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
            @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
            @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
            @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
            @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
            @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
            @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
            @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
            @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
}


#pragma mark - User Info

- (void) saveUserData : (NSDictionary *) userData {
    
    NSString *contact_number = @"";
    NSString *user_id = @"";
    NSString *nickName = @"";
    NSString *profile_picture = @"";
    
    if([userData objectForKey:@"contact_number"] != nil && [userData valueForKey:@"contact_number"] != [NSNull null]) {
        contact_number = [userData valueForKey:@"contact_number"];
        [userDefault setValue:contact_number forKey:ISUserContactNumber];

    }

    if([userData objectForKey:@"user_id"] != nil && [userData valueForKey:@"user_id"] != [NSNull null]) {
        user_id = [userData valueForKey:@"user_id"];
        [userDefault setValue:user_id forKey:ISUserId];

    }
    
    if([userData objectForKey:@"nick_name"] != nil && [userData valueForKey:@"nick_name"] != [NSNull null]) {
        nickName = [userData valueForKey:@"nick_name"];
        [userDefault setValue:nickName forKey:ISUserNickName];
    }
    
    if([userData objectForKey:@"profile_picture"] != nil && [userData valueForKey:@"profile_picture"] != [NSNull null]) {
        profile_picture = [userData valueForKey:@"profile_picture"];
        [userDefault setValue:profile_picture forKey:ISUserProfilePic];
    }
}

- (void) saveUserCountryCode : (NSString *) code {
    [userDefault setValue:code forKey:ISUserCountryCode];
}

- (void) saveUserDeviceToken : (NSString *) deviceToken {
    [userDefault setValue:deviceToken forKey:ISUserDeviceToken];
}

- (NSString *) getUserDeviceToken {
    if([userDefault objectForKey:ISUserDeviceToken] == nil) {
        return @"";
    }
    else {
        return [userDefault objectForKey:ISUserDeviceToken];
    }
}

- (NSString *) getUserCountryCode {
    if([userDefault objectForKey:ISUserCountryCode] == nil) {
        return @"";
    }
    else {
        return [userDefault objectForKey:ISUserCountryCode];
    }
}

- (bool) isUserVerified {
    return [userDefault boolForKey:ISUserVerified];
}

- (void) verifyUser {
    [userDefault setBool:true forKey:ISUserVerified];
}

- (NSString *) getUserId {
    if([userDefault objectForKey:ISUserId] == nil) {
        return @"";
    }
    else {
        return [userDefault objectForKey:ISUserId] ;
    }
}

- (NSString *) getUserContactNumber {
    if([userDefault objectForKey:ISUserContactNumber] == nil) {
        return @"";
    }
    else {
        return [userDefault objectForKey:ISUserContactNumber];
    }
}

- (void) removeUserData {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaultsDict = [userDefaults dictionaryRepresentation];
    for (id key in userDefaultsDict) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}

- (ISCurrentUserData *) getCurrentUserData {
    ISCurrentUserData *userData = [[ISCurrentUserData alloc] init];
    
    NSString *contact_number = @"";
    NSString *user_id = @"";
    NSString *nickName = @"";
    NSString *profile_picture = @"";
    
    if([userDefault objectForKey:ISUserId] != nil) {
        user_id = [userDefault objectForKey:ISUserId];
    }
    
    if([userDefault objectForKey:ISUserNickName] != nil) {
        nickName = [userDefault objectForKey:ISUserNickName];
    }
    
    if([userDefault objectForKey:ISUserContactNumber] != nil) {
        contact_number = [userDefault objectForKey:ISUserContactNumber];
    }
    
    if([userDefault objectForKey:ISUserProfilePic] != nil) {
        profile_picture = [userDefault objectForKey:ISUserProfilePic];
    }
    
    userData.userId = user_id;
    userData.userNickName = nickName;
    userData.userContactNumber = contact_number;
    userData.userProfilePic = profile_picture;
    
    return userData;
}

- (void) scanAddressBookSample:(NSString *)mobileNo aResultBlock:(void(^)(NSString *name))resultBlock
{
    NSMutableArray *contactListArray = [[NSMutableArray alloc] init];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    NSString *userCountryCode = [[AppData sharedInstance] getUserCountryCode];
    
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //Keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            }
            else {
                NSString *phone = @"";
                NSString *fullName = @"";
                NSString *firstName = @"";
                NSString *lastName = @"";
                UIImage *profileImage;
                NSMutableArray *contactNumbersArray;
                
                //loop through all the contacts that was fetched from the local phone book also
                for (CNContact *contact in cnContacts) {
                    // copy data to my custom Contacts class.
                    
                    
                    
                    //                    for (CNLabeledValue *label in contact.phoneNumbers) {
                    ////                        phone = [label.value stringValue];
                    ////                        if ([phone length] > 0) {
                    ////                            [contactNumbersArray addObject:phone];
                    ////                        }
                    //
                    //                        CNPhoneNumber *fulMobNumVar = label.value;
                    //                        NSString *countryCode = [fulMobNumVar valueForKey:@"countryCode"];
                    //                        NSString *mobileNumber = [fulMobNumVar valueForKey:@"digits"];
                    //
                    //                        if(mobileNumber.length == 10) {
                    //
                    //                        }
                    //                        else if(mobileNumber.length > 10) {
                    //
                    //                        }
                    //                        else {
                    //
                    //                        }
                    //
                    //                        NSLog(@"%@",countryCode);
                    //                        NSLog(@"%@",mobileNumber);
                    //                    }
                    NSString *countryCode;
                    //                         [fulMobNumVar valueForKey:@"countryCode"];
                    NSString *mobileNumber;

                    for (CNLabeledValue *label in contact.phoneNumbers)
                    {
                        
                        ISContactDataModel *contactData = [[ISContactDataModel alloc]init];
                        
                        firstName = contact.givenName;
                        lastName = contact.familyName;
                        if (lastName == nil) {
                            fullName=[NSString stringWithFormat:@"%@",firstName];
                            lastName = @"";
                        }else if (firstName == nil){
                            fullName=[NSString stringWithFormat:@"%@",lastName];
                            firstName = @"";
                        }
                        else{
                            fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                        }
                        UIImage *image = [UIImage imageWithData:contact.imageData];
                        if (image != nil) {
                            profileImage = image;
                        }else{
                            profileImage = [UIImage imageNamed:@"ic_user_placeholder"];
                        }
                        
                        
                        CNPhoneNumber *fulMobNumVar = label.value;
                        countryCode = [fulMobNumVar valueForKey:@"countryCode"];
                        mobileNumber = [fulMobNumVar valueForKey:@"digits"];
                        //                            [mobileNum addObject:countryCode];
                        //                            [mobileNum addObject:mobileNumber];
                        
                        if(mobileNumber.length == 10) {
                            contactData.fullName = fullName;
                            contactData.firstName = firstName;
                            contactData.lastName = lastName;
                            contactData.phone = mobileNumber;
                            contactData.countryCode = userCountryCode;
                            contactData.profileImage = profileImage;
                            [contactListArray addObject:contactData];
                        }
                        else if(mobileNumber.length > 10)
                        {
                            
                            NSString *onlyMobileNumber = [mobileNumber substringFromIndex: [mobileNumber length] - 10];
                            
                            //                                NSString *onlyMobileNumber;
                            //                                NSMutableArray *onlyMobileNum = [[NSMutableArray alloc] init];
                            //                                for (CNLabeledValue *label in contact.phoneNumbers)
                            //                                {
                            //
                            //                                    [onlyMobileNum addObject:onlyMobileNumber];
                            //                                }
                            
                            
                            NSString *onlyCountryCode = [mobileNumber stringByReplacingOccurrencesOfString:onlyMobileNumber withString:@""];
                            
                            NSString *countryCodeWithOutPlus = [onlyCountryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
                            
                            contactData.fullName = fullName;
                            contactData.firstName = firstName;
                            contactData.lastName = lastName;
                            
                            contactData.phone = onlyMobileNumber;
                            contactData.countryCode = countryCodeWithOutPlus;
                            contactData.profileImage = profileImage;
                            [contactListArray addObject:contactData];
                            
                        }
                        
                        if(contact.phoneNumbers.count > 0)
                        {
                            
                            if ([contactData.phone isEqualToString:mobileNo])
                            {
                                if (resultBlock)
                                {
                                    resultBlock(contactData.fullName);
                                    break;
                                }
                                
                            }
                        }
                        
                    }
                    
                }
                
                
            }
        }
    }];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSString *)fetchContactName :(NSString *)requested_by_id
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tbl_Contact" inManagedObjectContext:[self managedObjectContext]];;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user_id == %@", requested_by_id];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        return @"";
    } else {
        if (result.count > 0) {
            for (NSManagedObject *request in result)
            {
                NSLog(@"1 - %@", [request valueForKey:@"fullName"]);
                NSLog(@"2 - %@", request);
                return [request valueForKey:@"fullName"];
                break;
            }
        }
        return @"";
    }
}
@end
