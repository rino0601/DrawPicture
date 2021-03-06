//
//  PreferenceViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "PreferenceViewController.h"

#import "BrushViewController.h"
#import "AboutMeViewController.h"
#import "DrawingRullViewController.h"

@implementation PreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark viewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[[self navigationItem] setTitle:@"Preferences"];
	sect1User = [NSArray arrayWithObjects:@"Quick Setting", nil];
	sect2Manual = [NSArray arrayWithObjects:@"Color Jitter",@"Brush size",@"Drawing rull", nil];
	sect3About = [NSArray arrayWithObjects:@"copyright",@"about me", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -

#pragma mark TableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { // Default is 1 if not implemented
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [sect1User count];
			break;
		case 1:
			return [sect2Manual count];
			break;
		case 2:
			return [sect3About count];
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	// Configure the cell...
	switch(indexPath.section)
	{
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:@"USER"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ColorJitter"];
			}
			cell.textLabel.text = [sect1User objectAtIndex:[indexPath row]];
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:@"MANUAL"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrushRad&Layer"];
			}
			cell.textLabel.text = [sect2Manual objectAtIndex:[indexPath row]];
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:@"ABOUT"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrushRad&Layer"];
			}
			cell.textLabel.text = [sect3About objectAtIndex:[indexPath row]];
			break;
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"bookmark";
			break;
		case 1:
			return @"Manual";
		case 2:
			return @"About";
		default:
			return @"";
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"저장 되어있는 설정을 빠르게 적용합니다.";
			break;
		case 1:
			return @"각각의 설정을 직접 설정합니다.";
			break;
		case 2:
			return @"저작권과 개발자 소개 입니다.";
			break;
		default:
			break;
	}
	return @"Warning code 0110";
}
#pragma mark -

#pragma mark TableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==1 && indexPath.row == 1) {
		BrushViewController *viewController;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			viewController = [[BrushViewController alloc] initWithNibName:@"BrushViewController_iPhone" bundle:nil];
		} else {
			viewController = [[BrushViewController alloc] initWithNibName:@"BrushViewController_iPad" bundle:nil];
		}
		[[self navigationController] pushViewController:viewController animated:YES];

		return ;
	} else if(indexPath.section==1 && indexPath.row == 2) {
		DrawingRullViewController *viewController;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			viewController = [[DrawingRullViewController alloc] initWithNibName:@"DrawingRullViewController_iPhone" bundle:nil];
		} else {
			viewController = [[DrawingRullViewController alloc] initWithNibName:@"DrawingRullViewController_iPad" bundle:nil];
		}
		[[self navigationController] pushViewController:viewController animated:YES];
		
		return ;
	} else if (indexPath.section==2 && indexPath.row == 1) {
		AboutMeViewController *viewController;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			viewController = [[AboutMeViewController alloc] initWithNibName:@"AboutMeViewController_iPhone" bundle:nil];
		} else {
			viewController = [[AboutMeViewController alloc] initWithNibName:@"AboutMeViewController_iPad" bundle:nil];
		}
		[[self navigationController] pushViewController:viewController animated:YES];
		
		return ;
	}
	[[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark -
@end
