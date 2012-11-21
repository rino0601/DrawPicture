//
//  DrawingRullViewController.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 11. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface DrawingRullViewController : UIViewController {
	IBOutlet UILabel *howMany;
	IBOutlet UISlider *setMany;
	IBOutlet UISegmentedControl *EACH;
	IBOutlet UISegmentedControl *resolution;
	IBOutlet UISwitch *randomOnOff;
}

- (IBAction)changeMany:(UISlider *)sender;
- (IBAction)changeEACH:(UISegmentedControl *)sender;
- (IBAction)changeResolution:(UISegmentedControl *)sender;
- (IBAction)changeRandom:(UISwitch *)sender;

@end
