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

enum STATEQ {
	CALCLAYER = 1,
	POPSTROKE = 2,
	POPDRWDOT = 3,
	FINALSTAT = 4
	};

@interface RINhertzmann : UIView {
	UIImage *resultUIImage; //need as output
	NSMutableArray *radixes; // need!! as input
	NSMutableArray *S_strok;
	NSMutableArray *C_strok;
	
	NSMutableArray *dot_Que;
	CGPoint theDot;
	
	IplImage *dX, *dY;
	IplImage *iplCanvas;
	IplImage *iplRefImg;
	IplImage *src;
	
	//from CIHCavas
	BOOL isEnd;
	CGContextRef ctx;
	CGFloat cRed, cGreen, cBlue, cAlpha, wLine;
	CGPoint *points;
	NSUInteger pointIndex, alloced;
}
//for stateInterface
@property (readonly) STATEQ NEXT;
@property (readonly) BOOL callNEXT;

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image Radixes:(NSArray *)rad;
- (UIImage *)image;
- (void)calcSobel;
- (void)calcLayer;
- (void)popStroke;
- (void)popAndDrawPoint;


@end
