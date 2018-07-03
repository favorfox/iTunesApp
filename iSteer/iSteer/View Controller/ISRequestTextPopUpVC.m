//
//  ISRequestTextPopUpVC.m
//  iSteer
//
//  Created by EL Capitan on 20/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "ISRequestTextPopUpVC.h"

@interface ISRequestTextPopUpVC ()

@end

@implementation ISRequestTextPopUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:false completion:nil];
}

- (IBAction)btnSendClicked:(id)sender {
    [self dismissViewControllerAnimated:false completion:nil];
}

@end
