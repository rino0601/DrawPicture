//
//  BrushViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "BrushViewController.h"
#import "BrushRadCell.h"
#import "RINAppDelegate.h"

@implementation BrushViewController

- (void)LoadfromDatabase:(id)sender {
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;

	// sqlite3 seems that doesn't support count() in result column
	int i=0;
	sqlite3_prepare_v2(dbo, [@"SELECT radix  FROM BRUSH ORDER BY radix DESC" UTF8String], -1, &localizer, NULL);
	while (sqlite3_step(localizer)==SQLITE_ROW) {
		int kval=sqlite3_column_int(localizer, 0);
		[brushes addObject:[DataBrush dataBrushWithName:[NSString stringWithFormat:@"order%2d",i+1] Value:kval lowerBound:0 upperBound:100]];
		i++;
	}
	[howMany setValue:i];
	[howManyL setText:[NSString stringWithFormat:@"%2d",(int)[howMany value]]];
	sqlite3_finalize(localizer);// terminate
}
- (void)SavetoDatabase:(id)sender {
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	

	
	[[self navigationController] popViewControllerAnimated:YES];
}

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
	
	brushes = [[NSMutableArray alloc] init];
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(SavetoDatabase:)]];
	
	[self LoadfromDatabase:nil];
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
