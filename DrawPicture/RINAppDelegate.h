//
//  RINAppDelegate.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class RINViewController;

@interface RINAppDelegate : UIResponder <UIApplicationDelegate> {
	UINavigationController *navi;
}

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, readonly) sqlite3 *dbo;
@property (strong, nonatomic) RINViewController *viewController;

@end
