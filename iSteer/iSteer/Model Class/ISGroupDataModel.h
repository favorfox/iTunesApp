//
//  ISGroupDataModel.h
//  iSteer
//
//  Created by EL Capitan on 24/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISGroupDataModel : NSObject

@property (nonatomic, strong) NSString *group_id;
@property (nonatomic, strong) NSString *group_name;
@property (nonatomic, strong) NSString *group_icon;
@property (nonatomic, strong) NSString *admin_id;
@property (nonatomic, strong) NSString *request_badge;
@property (nonatomic, strong) NSMutableArray *group_members;

@end
