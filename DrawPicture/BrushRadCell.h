//
//  BrushRadCell.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrushRadCell;

@interface DataBrush : NSObject {
	BrushRadCell * target;
}

@property (retain, nonatomic) NSString *name;
@property (nonatomic) NSInteger value;

+ (id)dataBrushWithName:(NSString *)name Value:(NSInteger)value;
- (void)makeLink:(BrushRadCell *)sender;
- (NSInteger)getCurrentValue;
@end

@interface BrushRadCell : UITableViewCell {
	int lowerBound;
	int upperBound;
}

@property (retain, nonatomic) IBOutlet UILabel *cellName;
@property (retain, nonatomic) IBOutlet UILabel *cellValue;
@property (retain, nonatomic) IBOutlet UISlider *cellCtrl;

- (IBAction)ctrlValueChanged:(UISlider *)sender;
- (void)setDataBrush:(DataBrush *)data;
- (NSInteger)getCurrentValue;
@end
