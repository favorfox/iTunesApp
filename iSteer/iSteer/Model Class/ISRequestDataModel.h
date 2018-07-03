//
//  ISRequestDataModel.h
//  iSteer
//
//  Created by EL Capitan on 27/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISRequestTextModelClass.h"
#import "ISDueDateModel.h"
#import "ISDestinationAddressModel.h"
#import "ISSourceAddressModel.h"
#import "ISContactNumberModel.h"

@interface ISRequestDataModel : NSObject

@property (nonatomic, strong) NSString *accepted_user_name;

@property (nonatomic, strong) NSString *created_date;

@property (nonatomic, strong) NSString *group_id;

@property (nonatomic, strong) NSString *is_archived;

@property (nonatomic, strong) NSString *modified_date;

@property (nonatomic, strong) NSString *request_accepted_by_id;

@property (nonatomic, strong) NSString *request_id;

@property (nonatomic, strong) NSString *request_is_delete;

@property (nonatomic, strong) NSString *request_message;

@property (nonatomic, strong) NSString *request_status;

@property (nonatomic, strong) NSString *request_type;

@property (nonatomic, strong) NSNumber *request_type_id;

@property (nonatomic, strong) NSString *requested_by_id;

@property (nonatomic, strong) NSString *requested_user_name;

@property (nonatomic, strong) NSDate *created_date_compare;

@property (nonatomic, strong) ISRequestTextModelClass *request_text;

@property (nonatomic, strong) ISDueDateModel *due_date;

@property (nonatomic, strong) ISSourceAddressModel *source_address;

@property (nonatomic, strong) ISDestinationAddressModel *destination_address;

@property (nonatomic, strong) ISContactNumberModel *contact_number;

@end
