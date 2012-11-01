//
//  RINhertzmann.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINhertzmann.h"

#define fg 1
#define T 1

@implementation RINhertzmann

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image Radixes:(NSArray *)rad {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		src=image;
		radixes=rad;
		resultUIImage=nil;
		
		cRed=cGreen=cBlue=0;
		cAlpha=1;
		wLine=[(NSNumber *)[radixes objectAtIndex:0] floatValue];
		
		CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
		ctx=CGBitmapContextCreate(NULL, frame.size.width, frame.size.height, 8, 4*frame.size.width, cs, kCGImageAlphaPremultipliedFirst); // what is mode doing ?
		CGColorSpaceRelease(cs);
		CGContextSetLineWidth(ctx, wLine);
		CGContextSetLineCap(ctx, kCGLineCapRound);
		CGContextSetRGBStrokeColor(ctx, cRed, cGreen, cBlue, cAlpha);
    }
    return self;
}

#pragma mark -
#pragma mark interface

- (void)beginPaint {
	//for each brush radius Ri, from largest to smallest do
	//	{
	//		// apply Gaussian blur
	//		referenceImage=sourceImage*G(fσ Ri)
	//		// paint a layer
	//		paintLayer(canvas, referenceImage, Ri)
	//
	//	}
	//return canvas
	
	//radixes are desc order
	for (NSNumber *num in radixes) {//	for each brush radius Ri, from largest to smallest do
		// apply Gaussian blur
		CIImage *ciImage = [[CIImage alloc] initWithImage:src];
		CIFilter *testFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
		[testFilter setDefaults];
		[testFilter setValue:ciImage forKey:@"inputImage"];
		[testFilter setValue:num forKey:@"inputRadius"];// pixel로 봐도 무방할 듯.
		CIImage *image = [testFilter outputImage];
		CIContext *context = [CIContext contextWithOptions:nil];
	    cif = [context createCGImage:image fromRect:image.extent];
		// paint a layer
		[self paintLayer:[UIImage imageWithCGImage:cif] radix:[num floatValue]];
	}	
}

- (UIImage *)image {
	// UIImage 병합코드.
	//	CGImageRef tmp = CGImageCreateWithImageInRect( [_uc.image CGImage], CGRectMake(0, 28, 100, 95));
	//	UIImage *_character = [UIImage resizeImage:[UIImage imageWithCGImage:tmp] width:72 height:72];
	//	UIImage *_bg = [UIImage imageNamed:@"characterbox_bg.png"];
	//	//combine background image + character image
	//	UIGraphicsBeginImageContext(_bg.size);
	//	[_bg drawInRect:CGRectMake(0, 0, _bg.size.width, _bg.size.height)];
	//	[_character drawInRect:CGRectMake(0, 0, _character.size.width, _character.size.height)];
	//	UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
	//	UIGraphicsEndImageContext();
	//	return resultImg;
	return resultUIImage;
}

#pragma mark -
#pragma mark innerMethod

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
//	CGImageRef i=CGBitmapContextCreateImage(ctx);
//	CGContextDrawImage(UIGraphicsGetCurrentContext(), [self bounds], i);
//	CGImageRelease(i);
	cif=CGBitmapContextCreateImage(ctx);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), [self bounds], cif);
	CGImageRelease(cif);
}

- (void)changeColor:(UIColor *)color {
	CGFloat tRed=0.0, tGreen=0.0, tBlue=0.0, tAlpha=1.0;
	[color getRed:&tRed green:&tGreen blue:&tBlue alpha:&tAlpha];
	cRed=tRed;
	cGreen=tGreen;
	cBlue=tBlue;
	cAlpha=tAlpha;
	CGContextSetRGBStrokeColor(ctx, cRed, cGreen, cBlue, cAlpha);
}

- (void)changeWidth:(CGFloat)thickness {
	wLine=thickness;
	CGContextSetLineWidth(ctx, wLine);
}

- (void)paintLayer:(UIImage *)referenceImage radix:(CGFloat)R{
//procedure paintLayer(canvas,referenceImage, R) {
//	S := a new set of strokes, initially empty
	NSMutableArray *S_strok=[NSMutableArray array]; // it is 2 dimention CGPoint array
//	// create a pointwise difference image
//	D := difference(canvas,referenceImage)
	NSArray *D = [self difference:[self image] referenceImage:referenceImage];

	//	grid := fg R
	CGFloat grid = fg*R;

//	for x=0 to imageWidth stepsize grid do
	for(int h = 0 ; h < [D count] ; h+=grid) {
//		for y=0 to imageHeight stepsize grid do
		NSArray *col = [D objectAtIndex:h]; // I need [it's count]
		for(int w = 0 ; w < [col count] ; w+= grid) {
//			// sum the error near (w,h) w:x h:y
//			M := the region (x-grid/2..x+grid/2,
//							 y-grid/2..y+grid/2)
//			areaError := ∑ D / grid2 i , j∈M i,j
			int areaError = [self getAreaError:D x:w y:h grid:grid];// x,y as a start point
			
//			if (areaError > T) then 
			if (areaError > T) {
				// find the largest error point
				//				(x1,y1) := arg max i, j ∈M Di,j
				//				s :=makeStroke(R,x1,y1,referenceImage)
				//				add s to S }
				CGPoint arg = [self getAreaMax:D x:w y:h grid:grid];
				[S_strok addObject:[self makeStroke:R point:arg referenceImage:referenceImage]];
			}
		}
	}
//	paint all strokes in S on the canvas, in random order
	//throw S_strok to drawing Method
}

- (int)getAreaError:(NSArray *)binA x:(int)x y:(int)y grid:(CGFloat)grid { 
	int areaError=0;
	for (int i =y-grid/2 ; i < y+grid/2 ; i++) {
		if(i<0) continue;
		for (int j = x-grid/2 ; j < x+grid/2 ; j++) {
			if(j<0) continue;
			NSNumber *num = [[binA objectAtIndex:i] objectAtIndex:j];
			areaError+=[num intValue];
		}
	}
	return areaError;
}

- (CGPoint)getAreaMax:(NSArray *)binA x:(int)x y:(int)y grid:(CGFloat)grid { 
	int max=0;
	CGPoint point;
	for (int i =y-grid/2 ; i < y+grid/2 ; i++) {
		if(i<0) continue;
		for (int j = x-grid/2 ; j < x+grid/2 ; j++) {
			if(j<0) continue;
			NSNumber *num = [[binA objectAtIndex:i] objectAtIndex:j];
			if([num intValue]>max) {
				max=[num intValue];
				point = CGPointMake(j, i);
			}
		}
	}
	return point;
}

-(NSArray *)difference:(UIImage *)canvas referenceImage:(UIImage *)refImg{ // return 2 dimention NSNumber array
	NSArray *canvasArray, *referenceArray;
	canvasArray = [self getRGBAsFromImage:canvas];
	referenceArray = [self getRGBAsFromImage:refImg];
	NSMutableArray *difference =[NSMutableArray array];
	
	for (int i = 0 ; i < [referenceArray count]; i++) {
		NSArray *colr, *colc;
		colc = [canvasArray objectAtIndex:i];
		colr = [referenceArray objectAtIndex:i];
		NSMutableArray *col = [NSMutableArray array];
		for(int j = 0 ; j < [colr count] ; j++) {
			UIColor *can, *ref;
			CGFloat cR,cG,cB,rR,rG,rB;
			CGFloat alpha;
			can=[colc objectAtIndex:j];
			ref=[colr objectAtIndex:j];
			[can getRed:&cR green:&cG blue:&cB alpha:&alpha];
			[ref getRed:&rR green:&rG blue:&rB alpha:&alpha];
			CGFloat diff = 0;
			diff += (cR-rR)*(cR-rR);
			diff += (cG-rG)*(cG-rG);
			diff += (cB-rB)*(cB-rB);
			diff=sqrt(diff);
			[col addObject:[NSNumber numberWithFloat:diff]];
		}
		[difference addObject:col];
	}
	
	return difference;
}

- (NSArray *)getRGBAsFromImage:(UIImage*)image { // return 2 dimention NSColor array
    NSMutableArray *result = [NSMutableArray array];
	
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
	
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = (bytesPerRow * 0) + 0 * bytesPerPixel;
    for (int i = 0 ; i <height ; i++) {
		NSMutableArray *col = [NSMutableArray array];
		for(int j = 0 ; j <width ; j++){
			CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
			CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
			CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
			CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
			byteIndex += 4;
			UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
			[col addObject:acolor];
		}
        [result addObject:col];
    }
	free(rawData);
	return result;
}

- (NSArray *)makeStroke:(CGFloat)R point:(CGPoint)pt referenceImage:(UIImage *)refImage {//retrun CGPoint array
	IplImage input;
	
	// 소벨 엗지가 필요한데....
		// 1. openCV를 적용한다.
			// 이 경우 위에 짜논 코드를 전면 수정해야 할지도 모르나, 성능은 보장되겠지.
		// 2. 내가 직접 만든다 ㅡㅡ
			// openCV적용하는 것 보다 쉬울수도 있고, 아닐 수 도 있음.
			// 성능이 보장되지 않아....
//function makeSplineStroke(x0,y0,R,refImage) {
//	strokeColor = refImage.color(x0,y0) K = a new stroke with radius R
//	and color strokeColor add point (x0,y0) to K
//	(x,y) := (x0,y0) (lastDx,lastDy) := (0,0)
//	for i=1 to maxStrokeLength do {
//		if (i > minStrokeLength and |refImage.color(x,y)-canvas.color(x,y)|< |refImage.color(x,y)-strokeColor|)
//			return K
//			
//		// detect vanishing gradient
//		if (refImage.gradientMag(x,y) == 0)
//			return K
//			
//		// get unit vector of gradient
//		(gx,gy) := refImage.gradientDirection(x,y)
//		// compute a normal direction
//		(dx,dy) := (-gy, gx)
//			
//		// if necessary, reverse direction
//		if (lastDx * dx + lastDy * dy < 0)
//			(dx,dy) := (-dx, -dy)
//			
//		// filter the stroke direction
//		(dx,dy) :=fc*(dx,dy)+(1-fc)*(lastDx,lastDy) (dx,dy) := (dx,dy)/(dx2 + dy2)1/2
//		(x,y) := (x+R*dx, y+R*dy)
//		(lastDx,lastDy) := (dx,dy)
//		add the point (x,y) to K
//	}
//	return K
//}
	return nil;
}
	
@end
