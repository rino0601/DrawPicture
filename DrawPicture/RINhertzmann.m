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
#define T 					200
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
		
		IplImage *dump = [UIImageCVArrConverter CreateIplImageFromUIImage:src];
		IplImage *x1, *x2, *y1, *y2;
		x1=RIN_sobel_edge(dump, 0, 1);	x2=RIN_sobel_edge(dump, 0, -1);	y1=RIN_sobel_edge(dump, 1, 1);	y2=RIN_sobel_edge(dump, 1, -1);
		dX = cvCloneImage(dump);	dY = cvCloneImage(dump);
		cvAdd(x1, x2, dX);	cvAdd(y1, y2, dY);
		
		CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
		ctx=CGBitmapContextCreate(NULL, dump->width, dump->height, 8, 4*dump->width, cs, kCGImageAlphaPremultipliedFirst); 
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
	debug_layer=0;
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
		
		// paint a layer
//		[self paintLayer:[UIImage imageWithCGImage:cif] radix:[num floatValue]]; //with gausian blurr
		[self paintLayer:src radix:[num floatValue]]; //no gausian blurr
		NSLog(@"%dth paintLayer Done",++debug_layer);
	}
	NSLog(@"app calculate is done.");
}

- (UIImage *)image {
	resultUIImage = UIGraphicsGetImageFromImageContext(ctx);
	
	NSString *fileName = @"layer";
	NSFileManager *fm = [NSFileManager defaultManager];
	int i=0;
	while([fm fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]]==YES){
		fileName = [NSString stringWithFormat:@"layer%d",i];
		i++;
	}
	[UIImagePNGRepresentation(resultUIImage) writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[fileName stringByAppendingString:@".png"]]atomically:NO]; // alpha 값이 0으로 들어가서 아마 아무것도 안나올 가능성이 큼.
	[UIImageJPEGRepresentation(resultUIImage, 1.0) writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[fileName stringByAppendingString:@".jpg"]] atomically:NO]; // 실제로 어쩐지 알기 위함
	// for science.
	
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
//	D := difference(canvas,referenceImage) // 메모리 문제로 폐기. 320*480 이 860MB 이상 필요한데, 아이폰 전체 메모리가 512MB인걸....
//	NSArray *D = [self difference:[self image] referenceImage:referenceImage];
	IplImage *iplCanvas = [UIImageCVArrConverter CreateIplImageFromUIImage:[self image]];
	IplImage *iplRefimg = [UIImageCVArrConverter CreateIplImageFromUIImage:referenceImage];
	
	//	grid := fg R
	CGFloat grid = fg*R;

//	for x=0 to imageWidth stepsize grid do
	debug_stroke=0;
	for(int h = 0 ; h < iplCanvas->height ; h+=grid) {
//		for y=0 to imageHeight stepsize grid do
		for(int w = 0 ; w < iplCanvas->width ; w+= grid) {
//			// sum the error near (w,h) w:x h:y
//			M := the region (x-grid/2..x+grid/2,
//							 y-grid/2..y+grid/2)
//			areaError := ∑ D / grid2 i , j∈M i,j
			if(grid==0)// 0일 리는 없지만.
				grid=0.0001f;
			
			int areaError = [self getAreaError:iplCanvas reference:iplRefimg x:w y:h grid:grid]/(grid*grid);// x,y as a start point
			
//			if (areaError > T) then 
			if (areaError > T) {
				// find the largest error point
				//				(x1,y1) := arg max i, j ∈M Di,j
				//				s :=makeStroke(R,x1,y1,referenceImage)
				//				add s to S }
				CGPoint arg = [self getAreaMax:iplCanvas reference:iplRefimg x:w y:h grid:grid];
				[S_strok addObject:[self makeStroke:R point:arg referenceImage:referenceImage]];
				NSLog(@"%dth makeStroke is done",++debug_stroke);
			}
		}
	}
//	paint all strokes in S on the canvas, in random order
	//throw S_strok to drawing Method
	[self changeWidth:R];
}

- (int)getAreaError:(IplImage *)canvas reference:(IplImage *)refImg x:(int)x y:(int)y grid:(CGFloat)grid { // int?
	int areaError=0;
	for (int i =y-grid/2 ; i < y+grid/2 ; i++) {
		if(i<0)	continue;
		if(i>=canvas->height)	continue;
		for (int j = x-grid/2 ; j < x+grid/2 ; j++) {
			if(j<0) continue;
			if(j>=canvas->width)	continue;
			CvScalar can, ref;
			
			can = cvGet2D(canvas, i, j); //(256,320)
			ref = cvGet2D(refImg, i, j);
			
			float diff=0;
			diff+= (can.val[0]-ref.val[0])*(can.val[0]-ref.val[0]);
			diff+= (can.val[1]-ref.val[1])*(can.val[1]-ref.val[1]);
			diff+= (can.val[2]-ref.val[2])*(can.val[2]-ref.val[2]);
			diff=sqrt(diff);
			
			areaError+=diff;
		}
	}
	return areaError;
}

- (CGPoint)getAreaMax:(IplImage *)canvas reference:(IplImage *)refImg x:(int)x y:(int)y grid:(CGFloat)grid {
	float max=0;
	CGPoint point;
	for (int i =y-grid/2 ; i < y+grid/2 ; i++) {
		if(i<0) continue;
		if(i>=canvas->height)	continue;
		for (int j = x-grid/2 ; j < x+grid/2 ; j++) {
			if(j<0) continue;
			if(j>=canvas->width)	continue;
			
			CvScalar can, ref;
			can = cvGet2D(canvas, i, j);
			ref = cvGet2D(refImg, i, j);
			
			float diff=0;
			diff+= (can.val[0]-ref.val[0])*(can.val[0]-ref.val[0]);
			diff+= (can.val[1]-ref.val[1])*(can.val[1]-ref.val[1]);
			diff+= (can.val[2]-ref.val[2])*(can.val[2]-ref.val[2]);
			diff=sqrt(diff);
			
			if(diff>max) {
				max=diff;
				point = CGPointMake(j, i);
			}
			
		}
	}
	return point;
}

- (NSArray *)makeStroke:(CGFloat)R point:(CGPoint)pt referenceImage:(UIImage *)refImage {//retrun CGPoint array
	// 여기 코드 줄여야 한다.
//function makeSplineStroke(x0,y0,R,refImage) {
	IplImage *iRefImage = [UIImageCVArrConverter CreateIplImageFromUIImage:refImage];
	IplImage *iCanvas   = [UIImageCVArrConverter CreateIplImageFromUIImage:[self image]];
	
	CvScalar strokeColor, RefColor, CanvasColor;
	
	//strokeColor = refImage.color(x0,y0)
		// 바운드 정해야한다.
	// pt는 bound 안에서 생성된 좌표이므로 수정 필요 없음.
	strokeColor = cvGet2D(iRefImage, (int)pt.y, (int)pt.x);
	
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
		
			// 바운드 정해야한다.
		RefColor = cvGet2D(iRefImage, (int)xy.y, (int)xy.x);
		CanvasColor = cvGet2D(iCanvas, (int)xy.y, (int)xy.x);
		
		diffwc+=(RefColor.val[0]-CanvasColor.val[0])*(RefColor.val[0]-CanvasColor.val[0]);
		diffwc+=(RefColor.val[1]-CanvasColor.val[1])*(RefColor.val[1]-CanvasColor.val[1]);
		diffwc+=(RefColor.val[2]-CanvasColor.val[2])*(RefColor.val[2]-CanvasColor.val[2]);
		diffwc = sqrtf(diffwc);

		diffws+=(RefColor.val[0]-strokeColor.val[0])*(RefColor.val[0]-strokeColor.val[0]);
		diffws+=(RefColor.val[1]-strokeColor.val[1])*(RefColor.val[1]-strokeColor.val[1]);
		diffws+=(RefColor.val[2]-strokeColor.val[2])*(RefColor.val[2]-strokeColor.val[2]);
		diffws = sqrtf(diffws);
		
		//		if (i > minStrokeLength and |refImage.color(x,y)-canvas.color(x,y)|< |refImage.color(x,y)-strokeColor|)
		if(i > MIN_STROKE_LENGTH && diffwc < diffws )
			return K;

		//		// detect vanishing gradient
			// 바운드 정해야한다.
			// 하단에서 처리.
		CvScalar vX=cvGet2D(dX, (int)xy.y, (int)xy.x);
		CvScalar vY=cvGet2D(dY, (int)xy.y, (int)xy.x);
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
		if(size==0)
			size=0.0001f;
		dx=dx/size;		dy=dy/size;
		
		//		(x,y) := (x+R*dx, y+R*dy)
		xy.x = xy.x + R*dx;		xy.y = xy.y + R*dy;
		if(xy.x < 0)	xy.x = 0;
		if(xy.y < 0)	xy.y = 0;
		if(xy.x >= iCanvas->width)	xy.x = iCanvas->width-1;
		if(xy.y >= iCanvas->height)	xy.y = iCanvas->height-1;
		//		(lastDx,lastDy) := (dx,dy)
		lastDx = dx;			lastDy = dy;
		
		//		add the point (x,y) to K
		[K addObject:[NSValue valueWithCGPoint:xy]];
	}
//	return K
	return K;
}
	
@end
