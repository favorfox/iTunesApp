//
//  ISGroupListTableCell.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ISGroupListTableCelllDelegate <NSObject>
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end


@interface ISGroupListTableCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgUserPicture;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *lblBadgeCount;
@property (nonatomic, weak) IBOutlet UIView *myContentView;
@property (weak, nonatomic) IBOutlet UIButton *btnArchive;


@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;

@property (nonatomic, weak) id <ISGroupListTableCelllDelegate> delegate;

- (void)openCell;
@end
