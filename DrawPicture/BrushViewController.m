//
//  BrushViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "BrushViewController.h"
#import "BrushRadCell.h"

@interface BrushViewController ()

@end

@implementation BrushViewController

- (IBAction)howManyValueChanged:(UISlider *)sender {
	[howMany setValue:(int)[howMany value]];
	if((int)[howMany value] < 4)
		[howMany setValue:4];
	[howManyL setText:[NSString stringWithFormat:@"%2d",(int)[howMany value]]];
}

- (IBAction)howManyTouchEnd:(UISlider *)sender {
	
	[brushes removeAllObjects];
	int k = (100/(int)[howMany value]);
	int n = [howMany value];
	for (int i=0 ; i<(int)[howMany value]; i++) {
		[brushes addObject:[DataBrush dataBrushWithName:[NSString stringWithFormat:@"order%2d",i+1] Value:k*(2*n-2*i-1)/2 lowerBound:k*(n-1-i) upperBound:k*(n-i)]];
	}
	
	[table beginUpdates];
	[table deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[table insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	[table endUpdates];
}

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
	[howManyL setText:[NSString stringWithFormat:@"%2d",(int)[howMany value]]];
	brushes = [[NSMutableArray alloc] init];
	int k = (100/(int)[howMany value]);
	int n = [howMany value];
	for (int i=0 ; i<(int)[howMany value]; i++) {
		[brushes addObject:[DataBrush dataBrushWithName:[NSString stringWithFormat:@"order%2d",i+1] Value:k*(2*n-2*i-1)/2 lowerBound:k*(n-1-i) upperBound:k*(n-i)]];
	}
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
			return (NSInteger)[howMany value];
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BrushRadCell *cell = [[BrushRadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"indiBRUSH"];
	// Configure the cell...

	switch(indexPath.section)
	{
		case 0:
			cell = (BrushRadCell *)[tableView dequeueReusableCellWithIdentifier:@"BRUSH"];
			if(cell == nil)
			{ 
				NSArray *style = [[NSBundle mainBundle] loadNibNamed:@"BrushRadCell" owner:nil options:nil];
				cell = [style objectAtIndex:0];
			}
			// individual init;
			[cell setDataBrush:[brushes objectAtIndex:[indexPath row]]];
			break;
	}
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
