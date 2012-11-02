//
//  RINAppDelegate.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINAppDelegate.h"

#import "RINViewController.h"

@implementation RINAppDelegate
@synthesize dbo;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    self.viewController = [[RINViewController alloc] initWithNibName:@"RINViewController_iPhone" bundle:nil];
	} else {
	    self.viewController = [[RINViewController alloc] initWithNibName:@"RINViewController_iPad" bundle:nil];
	}
	navi = [[UINavigationController alloc] initWithRootViewController:self.viewController];
	self.window.rootViewController = navi;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.window makeKeyAndVisible];

	
	

	NSFileManager *fm=[NSFileManager defaultManager];
	NSArray *docuDir;
	docuDir= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docuPath = [docuDir objectAtIndex:0]; // fix to shorter method
	if(![fm fileExistsAtPath:[docuPath stringByAppendingPathComponent:@"userSetting.sqlite"]]){
		// mainBundle에서 defaultSetting.sqlite 복사해오기.
		NSError * error;
		[fm copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"defaultSetting.sqlite"] toPath:[docuPath stringByAppendingPathComponent:@"userSetting.sqlite"] error:&error];
		if(error)
			NSLog(@"%@",error);
	}
	sqlite3_open_v2([[docuPath stringByAppendingPathComponent:@"userSetting.sqlite"] UTF8String], &dbo, SQLITE_OPEN_READWRITE, NULL);
	
	
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
