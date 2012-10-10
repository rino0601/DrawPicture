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
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
	[[self navigationController] setToolbarHidden:YES animated:YES];
	[[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark viewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[toolbarNib setHidden:YES];
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(callEditView:)]];
	[[self navigationItem] setTitle:@"DrawPicture"];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:0] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:0] setAction:@selector(callEditView:)];
	
	[self setToolbarItems:toolbarNib.items animated:YES];
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if([[self navigationController] isNavigationBarHidden]) {
		[[self navigationController] setNavigationBarHidden:NO animated:YES];
		[[self navigationController] setToolbarHidden:NO animated:YES];
	} else {
		[[self navigationController] setNavigationBarHidden:YES animated:YES];
		[[self navigationController] setToolbarHidden:YES animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
	[[self navigationController] setToolbarHidden:NO animated:YES];
}

@end
