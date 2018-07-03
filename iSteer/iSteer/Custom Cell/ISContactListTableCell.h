//
//  ISContactListTableCell.h
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISContactListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblContactFullName;
@property (weak, nonatomic) IBOutlet UIImageView *imgContactProfilePic;
@property (weak, nonatomic) IBOutlet UIButton *btnProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *lblAdmin;

@end
