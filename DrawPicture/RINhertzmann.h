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
	UIImage *resultUIImage; //need as output
	NSArray *radixes; // need!! as input
	NSMutableArray *C_strok;
	IplImage *dX, *dY;
	IplImage *iplCanvas, *iplRefImg; // iplRef잘 쓰면 변수 아낄 수 있다.
	IplImage *src;
	
	//from CIHCavas
	BOOL isEnd;
	CGContextRef ctx;
	CGFloat cRed, cGreen, cBlue, cAlpha, wLine;
	CGPoint *points;
	NSUInteger pointIndex, alloced;
}

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image Radixes:(NSArray *)rad;
- (void)beginPaint;
- (UIImage *)image;

@end
