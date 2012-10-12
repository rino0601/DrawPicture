//
//  BrushRadCell.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "BrushRadCell.h"

@implementation DataBrush
@synthesize name,value,upperBound,lowerBound;
+ (id)dataBrushWithName:(NSString *)name Value:(NSInteger)value lowerBound:(NSInteger)lb upperBound:(NSInteger)ub {
	DataBrush *DBrsh = [[DataBrush alloc] init];
	[DBrsh setName:name];
	[DBrsh setValue:value];
	[DBrsh setLowerBound:lb];
	[DBrsh setUpperBound:ub];
	return DBrsh;
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
		lowerBound = 0;
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
	lowerBound = [data lowerBound];
	upperBound = [data upperBound];
}

@end
