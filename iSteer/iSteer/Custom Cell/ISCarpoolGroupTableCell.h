//
//  ISCarpoolGroupTableCell.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCarpoolGroupTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgRequestStatus;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestAccepterName;

@property (weak, nonatomic) IBOutlet UILabel *lblRequesterName;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestText;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestTo;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestFrom;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestDateTime;

@property (weak, nonatomic) IBOutlet UILabel *lblRequestTime;

@end
