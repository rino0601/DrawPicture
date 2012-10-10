//
//  BrushViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "BrushViewController.h"

@interface BrushViewController ()

@end

@implementation BrushViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark TableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { // Default is 1 if not implemented
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 6;
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	// Configure the cell...
	/*
	switch(indexPath.section)
	{
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:@"USER"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ColorJitter"];
			}
//			cell.textLabel.text = [sect1User objectAtIndex:[indexPath row]];
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:@"MANUAL"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrushRad&Layer"];
			}
//			cell.textLabel.text = [sect2Manual objectAtIndex:[indexPath row]];
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:@"ABOUT"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrushRad&Layer"];
			}
//			cell.textLabel.text = [sect3About objectAtIndex:[indexPath row]];
			break;
	}
	 */
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"individual setting";
			break;
		default:
			return @"";
			break;
	}
}
#pragma mark -

#pragma mark TableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark -

@end
