//
//  PreferenceViewController.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferenceViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	NSArray *sect1User;
	NSArray *sect2Manual;
	NSArray *sect3About;
}

// T, MIN,MAX,MOD_dot, MOD_stk,MOD_inst,isRand, updateInterval

@end
