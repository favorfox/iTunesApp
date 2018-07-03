//
//  ISCurrentUserData.h
//  iSteer
//
//  Created by EL Capitan on 21/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISCurrentUserData : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userContactNumber;
@property (strong, nonatomic) NSString *userNickName;
@property (strong, nonatomic) NSString *userProfilePic;

@end
