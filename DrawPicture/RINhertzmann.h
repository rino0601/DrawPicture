//
//  RINhertzmann.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface DataHertzmann : NSObject

@end


@interface RINhertzmann : UIView {
	UIImage *src;
	UIImage *resultUIImage;
	NSArray *radixes;
	CGContextRef ctx;
	CGImageRef cif;
	CGFloat cRed, cGreen, cBlue, cAlpha, wLine;
}

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image Radixes:(NSArray *)rad;
- (void)beginPaint;
- (UIImage *)image;

@end
