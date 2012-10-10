//
//  BrushViewController.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrushViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UISlider *howMany;
	IBOutlet UILabel  *howManyL;
	IBOutlet UITableView *table;
}
- (IBAction)howManyValueChanged:(UISlider *)sender;
- (IBAction)howManyTouchEnd:(UISlider *)sender;
@end
