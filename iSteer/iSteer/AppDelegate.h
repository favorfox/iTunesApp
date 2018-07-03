//
//  AppDelegate.h
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISContactsVC.h"
#import "ISGroupsVC.h"
#import "ISSettingVC.h"
#import "IQKeyboardManager.h"
#import "AFNetworking.h"
#import "AppData.h"
#import "SVProgressHUD.h"
#import "TestFairy.h"
#import "HDNotificationView.h"
#include <AudioToolbox/AudioToolbox.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *storyboard;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) setTabBar;
- (void) logOutUser;
@end

