//
//  ISContactDataModel.h
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ISContactDataModel : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *phone;
//@property (nonatomic, strong) NSArray *phone;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *userImageUrl;
@end
