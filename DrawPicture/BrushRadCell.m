//
//  BrushRadCell.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "BrushRadCell.h"

@implementation DataBrush
@synthesize name,value;
+ (id)dataBrushWithName:(NSString *)name Value:(NSInteger)value {
	DataBrush *DBrsh = [[DataBrush alloc] init];
	[DBrsh setName:name];
	[DBrsh setValue:value];
	return DBrsh;
}
- (void)makeLink:(BrushRadCell *)sender {
	target=sender;
}
- (NSInteger)getCurrentValue {
	if(!target)
		NSLog(@"BrushRadCell doesn't exist");
	return [target getCurrentValue];
}
@end



@implementation BrushRadCell
@synthesize cellCtrl,cellName,cellValue;

- (IBAction)ctrlValueChanged:(UISlider *)sender {
	[cellCtrl setValue:(int)[cellCtrl value]];
	if((int)[cellCtrl value] < lowerBound)
		[cellCtrl setValue:lowerBound];
	if((int)[cellCtrl value] > upperBound)
		[cellCtrl setValue:upperBound];
	[cellValue setText:[NSString stringWithFormat:@"%2d",(int)[cellCtrl value]]];
	// need delegate?
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		lowerBound = 1;
		upperBound = 99;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataBrush:(DataBrush *)data {
	[cellName setText:[data name]];
	[cellCtrl setValue:[data value]];
	[cellValue setText:[NSString stringWithFormat:@"%2d",[data value]]];
	lowerBound = 0;
	upperBound = 99;
	[data makeLink:self];
}
- (NSInteger)getCurrentValue{
	return (NSInteger)[cellCtrl value];
}

@end
