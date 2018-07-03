//
//  ISSelectedContactListCollectionCell.m
//  iSteer
//
//  Created by EL Capitan on 19/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISSelectedContactListCollectionCell.h"

@implementation ISSelectedContactListCollectionCell

- (void)awakeFromNib {
    self.imgContactProfilePic.layer.cornerRadius = self.imgContactProfilePic.frame.size.width/2;
    self.imgContactProfilePic.clipsToBounds = true;
}

@end
