//
//  AppDelegate.m
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "AppDelegate.h"
#import "iOSHierarchyViewer.h"
#import "UserManager.h"
#import "UserModel.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"bd2edd0d-5b00-46ad-9567-b3b6c78f7475"];
    
    library = [[APLibrary alloc] initWithLicenseKey:@"FORSS-QSRWK-OIQEJ-KLQVL-GJKGT-HGVOU-OEROT-RPQTO" dataFolder:nil];
    NSAssert(nil != library, @"AjiPDFLib failed to initialize.");
    
    //TODO:Add proper login screen, and set user based on that
    UserManager *uManager = [UserManager sharedManager];
    
    NSError *error;
    UserModel *uModel = [[UserModel alloc] initWithString:@"{\"pk\": 3, \"username\": \"demo\"}" error:&error];
    uModel.password = @"demo";
    
    uManager.loggedInUser = uModel;
    
    
    TFLog([NSString stringWithFormat:@"%@%@", @"Logged in as: ", uManager.loggedInUser.username]);
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        splitViewController.presentsWithGesture = NO;
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [iOSHierarchyViewer start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
