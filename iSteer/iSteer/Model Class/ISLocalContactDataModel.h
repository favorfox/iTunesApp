//
//  ISLocalContactDataModel.h
//  iSteer
//
//  Created by EL Capitan on 15/11/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISLocalContactDataModel : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
//@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *userImageUrl;


@end
