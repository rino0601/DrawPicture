//
//  RINViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINViewController.h"

@interface RINViewController ()

@end

@implementation RINViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	/*
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
	*/
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
