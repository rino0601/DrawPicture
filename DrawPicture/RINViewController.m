//
//  RINViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINViewController.h"
#import "PreferenceViewController.h"

@interface RINViewController ()

@end

@implementation RINViewController

- (void)callEditView:(id)sender {
	
	PreferenceViewController *viewController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    viewController = [[PreferenceViewController alloc] initWithNibName:@"PreferenceViewController_iPhone" bundle:nil];
	} else {
	    viewController = [[PreferenceViewController alloc] initWithNibName:@"PreferenceViewController_iPad" bundle:nil];
	}
	[[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark viewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(callEditView:)]];
	[[self navigationItem] setTitle:@"DrawPicture"];
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
