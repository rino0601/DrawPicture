//
//  DrawingRullViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 11. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "DrawingRullViewController.h"
#import "RINAppDelegate.h"

@implementation DrawingRullViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	
	sqlite3_prepare_v2(dbo, [@"SELECT value FROM DRAWRULL WHERE key='each'" UTF8String], -1, &localizer, NULL);
	if(sqlite3_step(localizer)==SQLITE_ROW){
		int kval=sqlite3_column_int(localizer, 0);
		[EACH setSelectedSegmentIndex:kval];
	}
	sqlite3_finalize(localizer);//EACH_@ setting
	
	sqlite3_prepare_v2(dbo, [@"SELECT value  FROM DRAWRULL WHERE key='many'" UTF8String], -1, &localizer, NULL);
	if (sqlite3_step(localizer)==SQLITE_ROW) {
		int kval=sqlite3_column_int(localizer, 0);
		[setMany setValue:kval];
		[howMany setText:[NSString stringWithFormat:@"%d",kval]];
	}
	sqlite3_finalize(localizer);//DRAW_ONCE setting
	
	sqlite3_prepare_v2(dbo, [@"SELECT value  FROM DRAWRULL WHERE key='random'" UTF8String], -1, &localizer, NULL);
	if (sqlite3_step(localizer)==SQLITE_ROW) {
		int kval=sqlite3_column_int(localizer, 0);
		[randomOnOff setOn:(kval==0?NO:YES) animated:NO];
	}
	sqlite3_finalize(localizer);//isRANDOM
	
	sqlite3_prepare_v2(dbo, [@"SELECT value  FROM DRAWRULL WHERE key='resolution'" UTF8String], -1, &localizer, NULL);
	if (sqlite3_step(localizer)==SQLITE_ROW) {
		int kval=sqlite3_column_int(localizer, 0);
		[resolution setSelectedSegmentIndex:kval];
	}
	sqlite3_finalize(localizer);//resolution type
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)changeMany:(UISlider *)sender {
	[setMany setValue:(int)[setMany value]];
	[howMany setText:[NSString stringWithFormat:@"%2d",(int)[setMany value]]];
	
	int kval = (int)[setMany value];
	//update
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	sqlite3_prepare_v2(dbo, [[NSString stringWithFormat:@"UPDATE DRAWRULL SET value=%d WHERE key='many'",kval] UTF8String], -1, &localizer, NULL);
	sqlite3_step(localizer); // return SQLITE_DONE (101)
	sqlite3_finalize(localizer);//EACH_@ setting
}
- (IBAction)changeEACH:(UISegmentedControl *)sender {
	int kval = [EACH selectedSegmentIndex];
	
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	sqlite3_prepare_v2(dbo, [[NSString stringWithFormat:@"UPDATE DRAWRULL SET value=%d WHERE key='each'",kval] UTF8String], -1, &localizer, NULL);
	sqlite3_step(localizer); // return SQLITE_DONE (101)
	sqlite3_finalize(localizer);//EACH_@ setting
}
- (IBAction)changeResolution:(UISegmentedControl *)sender {
	int kval = [resolution selectedSegmentIndex];
	
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	sqlite3_prepare_v2(dbo, [[NSString stringWithFormat:@"UPDATE DRAWRULL SET value=%d WHERE key='resolution'",kval] UTF8String], -1, &localizer, NULL);
	sqlite3_step(localizer); // return SQLITE_DONE (101)
	sqlite3_finalize(localizer);//EACH_@ setting
}
- (IBAction)changeRandom:(UISwitch *)sender {
	int kval = [randomOnOff isOn]?1:0;
	
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	sqlite3_prepare_v2(dbo, [[NSString stringWithFormat:@"UPDATE DRAWRULL SET value=%d WHERE key='random'",kval] UTF8String], -1, &localizer, NULL);
	sqlite3_step(localizer); // return SQLITE_DONE (101)
	sqlite3_finalize(localizer);//EACH_@ setting
}


@end
