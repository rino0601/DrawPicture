//
//  BrushRadCell.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 10..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataBrush : NSObject 

@property (retain, nonatomic) NSString *name;
@property (nonatomic) NSInteger value;
@property (nonatomic) NSInteger lowerBound;
@property (nonatomic) NSInteger upperBound;

+ (id)dataBrushWithName:(NSString *)name Value:(NSInteger)value lowerBound:(NSInteger)lb upperBound:(NSInteger)ub;
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
@end
