//
//  ISContactListTableCell.m
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISContactListTableCell.h"

@implementation ISContactListTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imgContactProfilePic.layer.cornerRadius = self.imgContactProfilePic.layer.frame.size.width/2;
    self.imgContactProfilePic.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
