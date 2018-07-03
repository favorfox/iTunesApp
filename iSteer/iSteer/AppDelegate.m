//
//  AppDelegate.m
//  iSteer
//
//  Created by EL Capitan on 17/10/16.
//  Copyright © 2016 iSteer. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [TestFairy begin:@"ed586e6508d6463bd60bddade8a14ffbfeaeb555"];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [IQKeyboardManager sharedManager].enable = true;
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont systemFontOfSize:16],NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [self setRemoteNotification];
    
    //Temp : Remove before EOD
//    [[AppData sharedInstance] verifyUser];
//    [[NSUserDefaults standardUserDefaults] setValue:@"24" forKey:ISUserId];
    
    if([[AppData sharedInstance] isUserVerified]) {
        [self setTabBar];
    }
    
    //opened from a push notification when the app is closed
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil)
        {
            NSLog(@"userInfo->%@",[userInfo objectForKey:@"aps"]);
        }
    }
    //[AppData getContactsList];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Remote Notification

- (void) setRemoteNotification {
    
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (token != nil || ![token  isEqual: @""]) {
        
        [AppData sharedInstance].deviceToken = token;
        
        if([[AppData sharedInstance] isUserVerified]) {
            if(![[[AppData sharedInstance] getUserDeviceToken] isEqualToString:@""]) {
                
                NSString *deviceToken = [[AppData sharedInstance] getUserDeviceToken];
                
                if(![deviceToken isEqualToString:token]) {
                    [[AppData sharedInstance] saveUserDeviceToken:token];
                    [self updateDeviceTokenAPICall:token];
                }
            }
            else {
                [[AppData sharedInstance] saveUserDeviceToken:token];
                [self updateDeviceTokenAPICall:token];
            }
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error = %@", error.localizedDescription);
}

//"notification_type" = "accept request";
//"notification_type" = “reject request";
//"notification_type" = "group request";

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
    if ( application.applicationState == UIApplicationStateInactive)
    {
//       NSLog(@"userInfo->%@",[userInfo objectForKey:@"aps"]);
        
        NSLog(@"userInfo->%@",userInfo);
        
        if([userInfo objectForKey:@"custom"] != nil) {
            
            NSDictionary *custom = [userInfo valueForKey:@"custom"];
            
            if([custom valueForKey:@"request_type_id"] != nil) {
                [self.tabBarController setSelectedIndex:1];
                
                if ([[custom valueForKey:@"notification_type"] isEqualToString:@"accept request"] || [[custom valueForKey:@"notification_type"] isEqualToString:@"reject request"]) {
                    
                    NSString *request_type_id = [NSString stringWithFormat:@"%@",[custom valueForKey:@"request_type_id"]];
                    
                    NSString *request_id = [custom valueForKey:@"request_id"];
                    
                    if([request_type_id isEqualToString:@"1"]) {
                        
                        ISCarpoolRequestDetailVC *carpoolRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISCarpoolRequestDetailVC"];
                        carpoolRequestDetailVC.isFromNotification = true;
                        carpoolRequestDetailVC.request_id = request_id;
                        [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:carpoolRequestDetailVC animated:YES];
                    }
                    else if([request_type_id isEqualToString:@"2"]) {
                        ICEventRequestDetailVC *eventRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ICEventRequestDetailVC"];
                        eventRequestDetailVC.isFromNotification = true;
                        eventRequestDetailVC.request_id = request_id;
                        //                        UINavigationController *navigationController = self.tabBarController.navigationController;
                        //
                        //                        [navigationController pushViewController:eventRequestDetailVC animated:true];
                        [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventRequestDetailVC animated:YES];
                    }
                }
                else if([[custom valueForKey:@"notification_type"] isEqualToString:@"group request"]) {
                    NSLog(@"Group notification");
                    
                    NSString *group_id = [custom valueForKey:@"group_id"];
                    ISGroupDataModel *groupData = [[ISGroupDataModel alloc] init];
                    groupData.group_id = group_id;
                    groupData.group_name = @"";
                    ISGroupDetailVC *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ISGroupDetailVC"];
                    groupDetail.groupData = groupData;
                    groupDetail.isFromNotification = true;
                    [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:groupDetail animated:YES];
                }
            }
        }
    }
    else if(application.applicationState == UIApplicationStateActive)
    {
        // a push notification when the app is running. So that you can display an alert and push in any view
        
        NSLog(@"userInfo->%@",userInfo);
        
        NSDictionary *aps = [userInfo valueForKey:@"aps"];
        NSDictionary *alert = [aps valueForKey:@"alert"];
        NSString *body = [alert valueForKey:@"body"];
        
        AudioServicesPlaySystemSound(1000);
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@""]
                                                    title:@"FavorFox"
                                                  message:body
                                               isAutoHide:YES
                                                  onTouch:^{
                                                      
                                                      
                                                      /// On touch handle. You can hide notification view or do something
                                                      [HDNotificationView hideNotificationViewOnComplete:nil];
                                                      
                                                      NSDictionary *custom = [userInfo valueForKey:@"custom"];
                                                      
                                                      if([custom valueForKey:@"request_type_id"] != nil) {
                                                          [self.tabBarController setSelectedIndex:1];
                                                          
                                                          if ([[custom valueForKey:@"notification_type"] isEqualToString:@"accept request"] || [[custom valueForKey:@"notification_type"] isEqualToString:@"reject request"]) {
                                                              
                                                              NSString *request_type_id = [NSString stringWithFormat:@"%@",[custom valueForKey:@"request_type_id"]];
                                                              
                                                              NSString *request_id = [custom valueForKey:@"request_id"];
                                                              
                                                              if([request_type_id isEqualToString:@"1"]) {
                                                                  
                                                                  ISCarpoolRequestDetailVC *carpoolRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISCarpoolRequestDetailVC"];
                                                                  carpoolRequestDetailVC.isFromNotification = true;
                                                                  carpoolRequestDetailVC.request_id = request_id;
                                                                  [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:carpoolRequestDetailVC animated:YES];
                                                              }
                                                              else if([request_type_id isEqualToString:@"2"]) {
                                                                  ICEventRequestDetailVC *eventRequestDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ICEventRequestDetailVC"];
                                                                  eventRequestDetailVC.isFromNotification = true;
                                                                  eventRequestDetailVC.request_id = request_id;
                                                                  //                        UINavigationController *navigationController = self.tabBarController.navigationController;
                                                                  //
                                                                  //                        [navigationController pushViewController:eventRequestDetailVC animated:true];
                                                                  [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventRequestDetailVC animated:YES];
                                                              }
                                                          }
                                                          else if([[custom valueForKey:@"notification_type"] isEqualToString:@"group request"]) {
                                                              NSLog(@"Group notification");
                                                              
                                                              NSString *group_id = [custom valueForKey:@"group_id"];
                                                              ISGroupDataModel *groupData = [[ISGroupDataModel alloc] init];
                                                              groupData.group_id = group_id;
                                                              groupData.group_name = @"";
                                                              ISGroupDetailVC *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ISGroupDetailVC"];
                                                              groupDetail.groupData = groupData;
                                                              groupDetail.isFromNotification = true;
                                                              [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:groupDetail animated:YES];
                                                          }
                                                      }
                                                      
                                                  }];
    }
}

#pragma mark - Set Tabbar

- (void) setTabBar {
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.tabBarController = (UITabBarController *) [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:26.0/255.0 green:157.0/255.0 blue:207.0/255.0 alpha:1];
    
    // ContactVC
    ISContactsVC *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISContactsVC"];
    
    UINavigationController *contactNavigationController = [[UINavigationController alloc] initWithRootViewController:contactVC];
    contactNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"ic_contact_grey"] selectedImage:[UIImage imageNamed:@"ic_contact_selected"]];
    contactNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);    
    
    // GroupVC
    ISGroupsVC *groupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISGroupsVC"];
    
    UINavigationController *groupNavigationController = [[UINavigationController alloc] initWithRootViewController:groupVC];
    
    groupNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"ic_group_grey"] selectedImage:[UIImage imageNamed:@"ic_group_selected"]];

    groupNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    // SettingVC
    ISSettingVC *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISSettingVC"];
    
    UINavigationController *settingNavigationController = [[UINavigationController alloc] initWithRootViewController:settingVC];

    settingNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"ic_setting_grey"] selectedImage:[UIImage imageNamed:@"ic_setting_selected"]];
    settingNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    
    self.tabBarController.viewControllers = @[contactNavigationController,groupNavigationController,settingNavigationController];
    
    [self.tabBarController setSelectedIndex:1];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
}

#pragma mark - LogOut

- (void) logOutUser {
    
    ISWelcomeVC *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ISWelcomeVC"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
    navigationController.navigationBarHidden = true;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.demo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iSteerModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iSteerModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - UpdateDeviceToken API Call

- (void) updateDeviceTokenAPICall : (NSString *) token {
    
    NSString *userId = [[AppData sharedInstance] getUserId];
    
    NSDictionary *param = @{@"user_id":userId,@"device_token":token};
    
    [APIUtility servicePostToEndPoint:UpdateDeviceToken withParams:param aResultBlock:^(NSDictionary *response, NSError *error, bool isSuccess) {
        
        if(isSuccess) {
            if(response != nil) {
                NSLog(@"%@",response);
                
                NSString *status = [response valueForKey:@"status"];
                NSString *message = [response valueForKey:@"message"];
                
                if([status isEqualToString:@"1"]) {
                    NSDictionary *dataDict = [response valueForKey:@"data"];
                    
                    [[AppData sharedInstance] saveUserData:dataDict];
                    
                    [[AppData sharedInstance] verifyUser];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate setTabBar];
                }
                else {
                    [AppData displayAlert:message];
                }
            }
        }
        else{
        }
    }];

}
@end
