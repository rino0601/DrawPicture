//
//  RINhertzmann.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINhertzmann.h"
#import "UIImageCVArrConverter.h"

#define fg 					1
#define T 					1
#define MAX_STROKE_LENGTH	10
#define MIN_STROKE_LENGTH	3
#define CURVATURE_FILTER	0.5

IplImage *RIN_sobel_edge(IplImage *src_image, int mode, int dix) {
	int mask_height, mask_width, mask_vector;
	double vertical_var, horizontal_var, ret_var;
	
	int height = src_image->height;
	int width = src_image->width;
	mask_vector = dix>0 ? 1 : -1;
	IplImage *dst_image = cvCloneImage(src_image);
	
	mask_height=mask_width=3;
	int vertical_mask[3][3]={{-1,0,1},{-2,0,2},{-1,0,1}};
	int horizontal_mask[3][3]={{-1,-2,-1},{0,0,0},{1,2,1}};
	
	for(int i=0 ; i<height-mask_height+((mask_height-1)/2) ; i++) {
		for(int j=0 ; j<width-mask_width+((mask_width-1)/2) ; j++) {
			vertical_var=horizontal_var=0.0;
			if((i+mask_height > height) || (j+mask_width > width))
				continue;
			for(int m=0; m<mask_height; m++){
				for(int n=0; n<mask_width;n++){
					CvScalar channel = cvGet2D(src_image, i+m, j+n);
					vertical_var +=((channel.val[0]+channel.val[1]+channel.val[2])/3.0)*mask_vector*vertical_mask[m][n];
					horizontal_var +=((channel.val[0]+channel.val[1]+channel.val[2])/3.0)*mask_vector*horizontal_mask[m][n];
				}
			}
			//fabs 생략
			//근데 음수 없다.... 왜?????
			ret_var=vertical_var+horizontal_var;
			CvScalar value;
			value.val[3]=255.0;
			switch (mode) {
				case 0:	value.val[2]=value.val[1]=value.val[0]=vertical_var;	break;
				case 1:	value.val[2]=value.val[1]=value.val[0]=horizontal_var;	break;
				case 2: value.val[2]=value.val[1]=value.val[0]=ret_var;			break;
			}
			cvSet2D(dst_image, i+(mask_height-1)/2, j+(mask_width-1)/2, value);
		}
	}
	return dst_image;
}

UIImage* UIGraphicsGetImageFromImageContext (CGContextRef context){
	/*CGImageRef imgRef = CGBitmapContextCreateImage(context);
	 UIImage* img = [UIImage imageWithCGImage:imgRef];
	 CGImageRelease(imgRef);
	 CGContextRelease(context);
	 return img;
	 */
	return [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
}

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
		
		C_strok = [NSMutableArray array];
		
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
//		// apply Gaussian blur
//		CIImage *ciImage = [[CIImage alloc] initWithImage:src];
//		CIFilter *testFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
//		[testFilter setDefaults];
//		[testFilter setValue:ciImage forKey:@"inputImage"];
//		[testFilter setValue:num forKey:@"inputRadius"];// pixel로 봐도 무방할 듯.
//		CIImage *image = [testFilter outputImage];
//		CIContext *context = [CIContext contextWithOptions:nil];
//	    cif = [context createCGImage:image fromRect:image.extent];
		
		IplImage *dump = [UIImageCVArrConverter CreateIplImageFromUIImage:src];
		IplImage *x1, *x2, *y1, *y2;
		x1=RIN_sobel_edge(dump, 0, 1);	x2=RIN_sobel_edge(dump, 0, -1);	y1=RIN_sobel_edge(dump, 1, 1);	y2=RIN_sobel_edge(dump, 1, -1);
		dX = cvCloneImage(dump);	dY = cvCloneImage(dump);
		cvAdd(x1, x2, dX);	cvAdd(y1, y2, dY);
		
		// paint a layer
		[self paintLayer:[UIImage imageWithCGImage:cif] radix:[num floatValue]];
	}	
}

- (UIImage *)image {
	resultUIImage = UIGraphicsGetImageFromImageContext(ctx);
	NSString *fileName = @"layer.png";
	NSFileManager *fm = [NSFileManager defaultManager];
	int i=0;
	while([fm fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]]==YES){
		fileName = [NSString stringWithFormat:@"layer%d.png",i];
		i++;
	}
	[UIImagePNGRepresentation(resultUIImage) writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]atomically:NO];
	return resultUIImage;

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
	[self changeWidth:R];
	
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

-(NSArray *)difference:(UIImage *)canvas referenceImage:(UIImage *)refImg {
	IplImage *iCanvas = [UIImageCVArrConverter CreateIplImageFromUIImage:canvas];
	IplImage *iRefImg = [UIImageCVArrConverter CreateIplImageFromUIImage:refImg];
	
	NSMutableArray *difference =[NSMutableArray array];
	
	int cR,cG,cB,rR,rG,rB;
	
	for (int i=0 ; i<iCanvas->height ; i++) {
		NSMutableArray *col = [NSMutableArray array];
		for (int j =0 ; j<iCanvas->widthStep ; j++) {
			float diff = 0;
			cR = iCanvas->imageData[(i*iCanvas->widthStep) + j*iCanvas->nChannels + 0];
			cG = iCanvas->imageData[(i*iCanvas->widthStep) + j*iCanvas->nChannels + 1];
			cB = iCanvas->imageData[(i*iCanvas->widthStep) + j*iCanvas->nChannels + 2];
			rR = iRefImg->imageData[(i*iRefImg->widthStep) + j*iRefImg->nChannels + 0];
			rG = iRefImg->imageData[(i*iRefImg->widthStep) + j*iRefImg->nChannels + 1];
			rB = iRefImg->imageData[(i*iRefImg->widthStep) + j*iRefImg->nChannels + 2];
			
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

- (NSArray *)makeStroke:(CGFloat)R point:(CGPoint)pt referenceImage:(UIImage *)refImage {//retrun CGPoint array
//function makeSplineStroke(x0,y0,R,refImage) {
	IplImage *iRefImage = [UIImageCVArrConverter CreateIplImageFromUIImage:refImage];
	IplImage *iCanvas   = [UIImageCVArrConverter CreateIplImageFromUIImage:[self image]];
	
	//strokeColor = refImage.color(x0,y0) iCanvas->imageData[(i*iCanvas->widthStep) + j*3 + 0];
	int strokeColorB = iRefImage->imageData[ (((int)pt.y)*iRefImage->widthStep) + ((int)pt.x)*3 + 0];
	int strokeColorG = iRefImage->imageData[ (((int)pt.y)*iRefImage->widthStep) + ((int)pt.x)*3 + 1];
	int strokeColorR = iRefImage->imageData[ (((int)pt.y)*iRefImage->widthStep) + ((int)pt.x)*3 + 2];
	
	//K = a new stroke with radius R // R은 바깥에서 처리하고, Color는 동적배열하나 더 쓴다ㅠ
	//	and color strokeColor add point (x0,y0) to K
	NSMutableArray *K = [NSMutableArray array];
	[K addObject:[NSValue valueWithCGPoint:pt]];

	//	(x,y) := (x0,y0) (lastDx,lastDy) := (0,0)
	CGPoint xy = CGPointMake(pt.x, pt.y);
	float lastDx=0, lastDy=0;
	
//	for i=1 to maxStrokeLength do {
	for (int i = 1 ; i<MAX_STROKE_LENGTH; i++) {
		
		float diffwc=0, diffws=0;
		
		int RefColorB = iRefImage->imageData[ (((int)xy.y)*iRefImage->widthStep) + ((int)xy.x)*3 + 0];
		int RefColorG = iRefImage->imageData[ (((int)xy.y)*iRefImage->widthStep) + ((int)xy.x)*3 + 1];
		int RefColorR = iRefImage->imageData[ (((int)xy.y)*iRefImage->widthStep) + ((int)xy.x)*3 + 2];
		int CanvasColorB = iCanvas->imageData[ (((int)xy.y)*iCanvas->widthStep) + ((int)xy.x)*3 + 0];
		int CanvasColorG = iCanvas->imageData[ (((int)xy.y)*iCanvas->widthStep) + ((int)xy.x)*3 + 1];
		int CanvasColorR = iCanvas->imageData[ (((int)xy.y)*iCanvas->widthStep) + ((int)xy.x)*3 + 2];
		
		diffwc+=(RefColorB-CanvasColorB)*(RefColorB-CanvasColorB);
		diffwc+=(RefColorG-CanvasColorG)*(RefColorG-CanvasColorG);
		diffwc+=(RefColorR-CanvasColorR)*(RefColorR-CanvasColorR);
		diffwc = sqrtf(diffwc);

		diffws+=(RefColorB-strokeColorB)*(RefColorB-strokeColorB);
		diffws+=(RefColorG-strokeColorG)*(RefColorG-strokeColorG);
		diffws+=(RefColorR-strokeColorR)*(RefColorR-strokeColorR);
		diffws = sqrtf(diffws);
		
		//		if (i > minStrokeLength and |refImage.color(x,y)-canvas.color(x,y)|< |refImage.color(x,y)-strokeColor|)		
		if(i > MIN_STROKE_LENGTH && diffwc < diffws )
			return K;

		//		// detect vanishing gradient
		CvScalar vX=cvGet2D(dX, (int)xy.x, (int)xy.y);
		CvScalar vY=cvGet2D(dY, (int)xy.x, (int)xy.y);
		float ax = vX.val[0]*vX.val[0];
		float ay = vY.val[0]*vY.val[0];
		float mag = sqrtf(ax+ay);
		//		if (refImage.gradientMag(x,y) == 0)
		if(mag==0)
			return K;
		
		//		// get unit vector of gradient
		//		(gx,gy) := refImage.gradientDirection(x,y)
		float gx=vX.val[0], gy=vY.val[0];
		//		// compute a normal direction
		//		(dx,dy) := (-gy, gx)
		float dx=-gy, dy=gx;
		//
		//		// if necessary, reverse direction
		//		if (lastDx * dx + lastDy * dy < 0)
		//			(dx,dy) := (-dx, -dy)
		if(lastDx *dx + lastDy*dy <0){
			dx=-dx; dy=-dy;
		}
		//
		//		// filter the stroke direction
		//		(dx,dy) :=fc*(dx,dy)+(1-fc)*(lastDx,lastDy)
		dx=CURVATURE_FILTER*dx + (1-CURVATURE_FILTER)*lastDx;
		dy=CURVATURE_FILTER*dy + (1-CURVATURE_FILTER)*lastDy;
		
		//		(dx,dy) := (dx,dy)/(dx2 + dy2)1/2
		float size = sqrtf((dx*dx)+(dy*dy));
		dx=dx/size;		dy=dy/size;
		
		//		(x,y) := (x+R*dx, y+R*dy)
		xy.x = xy.x + R*dx;		xy.y = xy.y + R*dy;
		//		(lastDx,lastDy) := (dx,dy)
		lastDx = xy.x;			lastDy = xy.y;
		//		add the point (x,y) to K
		[K addObject:[NSValue valueWithCGPoint:xy]];
	}
//	return K
	return K;
}
	
@end
