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
#define T 					50
#define MAX_STROKE_LENGTH	5
#define MIN_STROKE_LENGTH	3
#define CURVATURE_FILTER	0.1
#define BEZIER_INTERPOLATION_COEFFICIENT ((CGFloat)0.7)
#define POINTSTORAGE_CAPACITY ((NSUInteger)1000)

static CGFloat dist(CGPoint p1, CGPoint p2) {
	CGFloat dx=p2.x-p1.x, dy=p2.y-p1.y;
	
	return (CGFloat)sqrt((dx*dx)+(dy*dy));
}
static CGPoint mid(CGPoint p1, CGPoint p2) {
	return CGPointMake((p1.x+p2.x)/2.0, (p1.y+p2.y)/2.0);
}
static void interpolateBezierPathAtNode(CGContextRef ctx, CGPoint *points, NSUInteger  *pointCount, BOOL isEnd) {
	if(ctx==NULL)
		return;
	
	NSUInteger currentCount=*pointCount;
	NSUInteger mID=isEnd==NO?currentCount-3:currentCount-2;
	
	CGPoint p1=points[mID-1], p2=points[mID], p3=points[mID+1], p4;
	CGPoint m1=mid(p1, p2), m2=mid(p2, p3), m3;
	CGFloat l1=dist(p1, p2), l2=dist(p2, p3), l3;
	CGPoint o1=CGPointMake((l1*m2.x+l2*m1.x)/(l1+l2), (l1*m2.y+l2*m1.y)/(l1+l2)), o2;
	CGPoint d1=CGPointMake(p2.x-o1.x, p2.y-o1.y), d2;
	CGPoint c1=CGPointMake(m1.x+d1.x, m1.y+d1.y), c2=CGPointMake(m2.x+d1.x, m2.y+d1.y), c3;
	c1.x+=(1.0-BEZIER_INTERPOLATION_COEFFICIENT)*(p2.x-c1.x);
	c1.y+=(1.0-BEZIER_INTERPOLATION_COEFFICIENT)*(p2.y-c1.y);
	c2.x-=(1.0-BEZIER_INTERPOLATION_COEFFICIENT)*(c2.x-p2.x);
	c2.y-=(1.0-BEZIER_INTERPOLATION_COEFFICIENT)*(c2.y-p2.y);
	
	if(isEnd==NO) {
		p4=points[mID+2];
		m3=mid(p3, p4);
		l3=dist(p3, p4);
		o2=CGPointMake((l2*m3.x+l3*m2.x)/(l2+l3), (l2*m3.y+l3*m2.y)/(l2+l3));
		d2=CGPointMake(p3.x-o2.x, p3.y-o2.y);
		c3=CGPointMake(m2.x+d2.x, m2.y+d2.y);
		c3.x+=(1.0-BEZIER_INTERPOLATION_COEFFICIENT)*(p3.x-c3.x);
		c3.y-=(1.0-BEZIER_INTERPOLATION_COEFFICIENT)*(c3.y-p3.y);
		
		if(mID==1) {
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, p1.x, p1.y);
			CGContextAddCurveToPoint(ctx, p1.x, p1.y, c1.x, c1.y, p2.x, p2.y);
			CGContextAddCurveToPoint(ctx, c2.x, c2.y, c3.x, c3.y, p3.x, p3.y);
			CGContextStrokePath(ctx);
		} else {
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, p2.x, p2.y);
			CGContextAddCurveToPoint(ctx, c2.x, c2.y, c3.x, c3.y, p3.x, p3.y);
			CGContextStrokePath(ctx);
		}
	} else {
		if(mID==1) {
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, p1.x, p1.y);
			CGContextAddCurveToPoint(ctx, p1.x, p1.y, c1.x, c1.y, p2.x, p2.y);
			CGContextAddCurveToPoint(ctx, c2.x, c2.y, p3.x, p3.y, p3.x, p3.y);
			CGContextStrokePath(ctx);
		} else {
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, p2.x, p2.y);
			CGContextAddCurveToPoint(ctx, c2.x, c2.y, p3.x, p3.y, p3.x, p3.y);
			CGContextStrokePath(ctx);
		}
		*pointCount=0;
	}
}
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
@synthesize NEXT,callNEXT,mode;
- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image Radixes:(NSMutableArray *)rad {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		src=[UIImageCVArrConverter CreateIplImageFromUIImage:image];
		radixes=rad;
		resultUIImage=nil;
		
		cRed=cGreen=cBlue=0;
		cAlpha=1;
		wLine=[(NSNumber *)[radixes objectAtIndex:0] floatValue];
		
		CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
		ctx=CGBitmapContextCreate(NULL, src->width, src->height, 8, 4*src->width, cs, kCGImageAlphaPremultipliedLast);//kCGImageAlphaPremultipliedFirst
		CGColorSpaceRelease(cs);
		CGContextSetLineWidth(ctx, wLine);
		CGContextSetLineCap(ctx, kCGLineCapRound);
		CGContextSetRGBStrokeColor(ctx, cRed, cGreen, cBlue, cAlpha);
		
		CGFloat components[] = {1.0, 1.0, 1.0, 1.0};
		CGContextSetFillColorWithColor(ctx, CGColorCreate(cs, components));
		CGContextFillRect(ctx, CGRectMake(0, 0, src->width, src->height));
		
		points=(CGPoint *)malloc(sizeof(CGPoint)*(alloced=POINTSTORAGE_CAPACITY));
		if(points==NULL)
			self=nil;
		pointIndex=0;
		
		enableMdfyNEXT = YES;
		isRANDOM = NO;
		mode=EACH_LAYER;
    }
    return self;
}
#pragma mark -
#pragma mark interface
- (void)calcSobel {
	callNEXT=NO;
	
	// Initialization code
	C_strok = [NSMutableArray array];
	S_strok = [NSMutableArray array];
	dot_Que = [NSMutableArray array];
	
	IplImage *x1, *x2, *y1, *y2;
	x1=RIN_sobel_edge(src, 0, 1);	x2=RIN_sobel_edge(src, 0, -1);	y1=RIN_sobel_edge(src, 1, 1);	y2=RIN_sobel_edge(src, 1, -1);
	dX = cvCloneImage(src);	dY = cvCloneImage(src);
	cvAdd(x1, x2, dX);	cvAdd(y1, y2, dY);
	
	if(mode==EACH_DRAWING){
		enableMdfyNEXT = NO;
		while([radixes count]!=0){
			[self calcLayer];
		}
		
		enableMdfyNEXT = YES;
		
		NEXT=FINALSTAT;
		callNEXT=YES & enableMdfyNEXT;
		return ;
	}
	
	NEXT = CALCLAYER;
	callNEXT=YES & enableMdfyNEXT;
}
- (void)calcLayer {
	callNEXT=NO;
	if([radixes count]==0){
		NEXT=FINALSTAT;
		callNEXT=YES & enableMdfyNEXT;
		return ;
	}
	CGFloat R = [[radixes objectAtIndex:0] floatValue];
	[radixes removeObjectAtIndex:0];
	[self makeStrokeRef:src radix:R]; // 여기서 시간이 좀 걸림.
	[self changeWidth:R]; // 굵기는 Layer에 따라 바뀌는거니 여기서 할당.
	
	if(mode==EACH_LAYER || mode == EACH_DRAWING) {
		enableMdfyNEXT = NO;
		while ([S_strok count]!=0) {
			[self popStroke];
		}
		
		enableMdfyNEXT = YES;
		
		NEXT = CALCLAYER;
		callNEXT=YES & enableMdfyNEXT;
		return ;
	}
	
	NEXT=POPSTROKE;
	callNEXT=YES & enableMdfyNEXT;
}
- (void)popStroke {
	callNEXT=NO;
	if([S_strok count]==0){
		NEXT = CALCLAYER;
		callNEXT=YES & enableMdfyNEXT;
		return ;
	}
	int random = isRANDOM ? arc4random()%[S_strok count] : 0;
	dot_Que = [S_strok objectAtIndex:random];
	[S_strok removeObjectAtIndex:random];
	[self changeColor:[C_strok objectAtIndex:random]];
	[C_strok removeObjectAtIndex:random];
	
	if(mode != EACH_DOT){ // update opt == each stroke or layer or instance
		enableMdfyNEXT = NO;
		while ([dot_Que count]!=0) {
			[self popAndDrawPoint];
		}
		// final draw. equlto touchEnd.
		if(pointIndex==1) {
			// 검은점의 원인이라 생각되기 때문에 점한개짜리는 그냥 무시!
			pointIndex=0;
		} else if(pointIndex==2) {
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, points[0].x, points[0].y);
			CGContextAddLineToPoint(ctx, points[1].x, points[1].y);
			CGContextStrokePath(ctx);
			pointIndex=0;
		} else if(pointIndex>=3)
			interpolateBezierPathAtNode(ctx, points, &pointIndex, YES);
		//*/
		[self setNeedsDisplay];
		
		enableMdfyNEXT = YES;
		
		NEXT = POPSTROKE;
		callNEXT=YES & enableMdfyNEXT;
		return ;
	}
	// update opt == each dot
	NEXT = POPDRWDOT;
	callNEXT =YES & enableMdfyNEXT;
}
- (void)popAndDrawPoint {
	callNEXT=NO;
	if([dot_Que count]==0){
		// final draw. equlto touchEnd.
		if(pointIndex==1) {
			// 검은점의 원인이라 생각되기 때문에 점한개짜리는 그냥 무시!
			pointIndex=0;
		} else if(pointIndex==2) {
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, points[0].x, points[0].y);
			CGContextAddLineToPoint(ctx, points[1].x, points[1].y);
			CGContextStrokePath(ctx);
			pointIndex=0;
		} else if(pointIndex>=3)
			interpolateBezierPathAtNode(ctx, points, &pointIndex, YES);
		//*/
		[self setNeedsDisplay];
		
		NEXT = POPSTROKE;
		callNEXT=YES & enableMdfyNEXT;
		return ;
	}
	theDot = [[dot_Que objectAtIndex:0] CGPointValue];
	[dot_Que removeObjectAtIndex:0];

	// drawing method
	points[pointIndex++]=theDot;
	if(pointIndex==alloced)
		points=(CGPoint *)realloc(points, (alloced+=POINTSTORAGE_CAPACITY));
	if(pointIndex>3) {
		interpolateBezierPathAtNode(ctx, points, &pointIndex, NO);
		[self setNeedsDisplay];
	}
	
	NEXT = POPDRWDOT;
	callNEXT=YES & enableMdfyNEXT;
}
- (UIImage *)image {
	resultUIImage = UIGraphicsGetImageFromImageContext(ctx);
	return resultUIImage;
}
#pragma mark -
#pragma mark innerMethod
- (void)drawRect:(CGRect)rect {
	// Only override drawRect: if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	CGImageRef i=CGBitmapContextCreateImage(ctx);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), [self bounds], i);
	CGImageRelease(i);
}
- (void)makeStrokeRef:(IplImage *)referenceImage radix:(CGFloat)R{
	//procedure paintLayer(canvas,referenceImage, R) {
	//	S := a new set of strokes, initially empty
	iplCanvas = [UIImageCVArrConverter CreateIplImageFromUIImage:[self image]];  // 고치고 싶다.
	//	iplRefImg = [UIImageCVArrConverter CreateIplImageFromUIImage:referenceImage];
	iplRefImg = referenceImage;
	// 두 점의 차이는, 직접 구하기로 했음. 이 부분에서 연산량이 2배가 되지만, 메모리가 모자라서 어쩔 수 없다.
	
	if([S_strok count]!=0 && [C_strok count]!=0) NSLog(@"doh!");
	
	//	grid := fg R
	CGFloat grid = fg*R;
	
	//	for x=0 to imageWidth stepsize grid do
	for(int h = 0 ; h < iplCanvas->height ; h+=grid) {
		//		for y=0 to imageHeight stepsize grid do
		for(int w = 0 ; w < iplCanvas->width ; w+= grid) {
			//			// sum the error near (w,h) w:x h:y
			//			M := the region (x-grid/2..x+grid/2,
			//							 y-grid/2..y+grid/2)
			//			areaError := ∑ D / grid2 i , j∈M i,j
			if(grid==0)// 0일 리는 없지만.
				grid=0.0001f;
			
			int areaError = [self getAreaError:iplCanvas x:w y:h grid:grid]/(grid*grid);// x,y as a start point
			
			//			if (areaError > T) then
			if (areaError > T) {
				// find the largest error point
				//				(x1,y1) := arg max i, j ∈M Di,j
				//				s :=makeStroke(R,x1,y1,referenceImage)
				//				add s to S }
				CGPoint arg = [self getAreaMax:iplCanvas x:w y:h grid:grid];
				[S_strok addObject:[self makeStroke:R point:arg]];
			}
		}
	}
}
- (int)getAreaError:(IplImage *)canvas x:(int)x y:(int)y grid:(CGFloat)grid { // int?
	int areaError=0;
	for (int i =y-grid/2 ; i < y+grid/2 ; i++) {
		if(i<0)	continue;
		if(i>=canvas->height) break;
		for (int j = x-grid/2 ; j < x+grid/2 ; j++) {
			if(j<0) continue;
			if(j>=canvas->width) break;
			CvScalar can, ref;
			
			can = cvGet2D(canvas, i, j); //(256,320)
			ref = cvGet2D(iplRefImg, i, j);
			
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
- (CGPoint)getAreaMax:(IplImage *)canvas x:(int)x y:(int)y grid:(CGFloat)grid {
	float max=0;
	CGPoint point;
	for (int i =y-grid/2 ; i < y+grid/2 ; i++) {
		if(i<0) continue;
		if(i>=canvas->height) break;
		for (int j = x-grid/2 ; j < x+grid/2 ; j++) {
			if(j<0) continue;
			if(j>=canvas->width) break;
			
			CvScalar can, ref;
			can = cvGet2D(canvas, i, j);
			ref = cvGet2D(iplRefImg, i, j);
			
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
- (NSArray *)makeStroke:(CGFloat)R point:(CGPoint)pt {//retrun CGPoint array
	// 여기 코드 줄여야 한다.
//function makeSplineStroke(x0,y0,R,refImage) {
	
	CvScalar strokeColor, RefColor, CanvasColor;
	
	//strokeColor = refImage.color(x0,y0)
		// 바운드 정해야한다.
	// pt는 bound 안에서 생성된 좌표이므로 수정 필요 없음.
	strokeColor = cvGet2D(iplRefImg, (int)pt.y, (int)pt.x);
	
	//K = a new stroke with radius R // R은 바깥에서 처리하고, Color는 동적배열하나 더 쓴다ㅠ
	//	and color strokeColor add point (x0,y0) to K
	NSMutableArray *K = [NSMutableArray array];
	[K addObject:[NSValue valueWithCGPoint:pt]];
	[C_strok addObject:[UIColor colorWithRed:strokeColor.val[0]/255.0f
									   green:strokeColor.val[1]/255.0f
										blue:strokeColor.val[2]/255.0f
									   alpha:strokeColor.val[3]/255.0f]]; // 마지막 값은 1
	// C_strok은 위의 지역 변수인 S_Strok랑 크기가 같아야함.##
	//	(x,y) := (x0,y0) (lastDx,lastDy) := (0,0)
	CGPoint xy = CGPointMake(pt.x, pt.y);
	float lastDx=0, lastDy=0;
	
//	for i=1 to maxStrokeLength do {
	for (int i = 1 ; i<=MAX_STROKE_LENGTH; i++) {
		
		float diffwc=0, diffws=0;
		
			// 바운드 정해야한다.
		RefColor = cvGet2D(iplRefImg, (int)xy.y, (int)xy.x);
		CanvasColor = cvGet2D(iplCanvas, (int)xy.y, (int)xy.x);
		
		diffwc+=(RefColor.val[0]-CanvasColor.val[0])*(RefColor.val[0]-CanvasColor.val[0]);
		diffwc+=(RefColor.val[1]-CanvasColor.val[1])*(RefColor.val[1]-CanvasColor.val[1]);
		diffwc+=(RefColor.val[2]-CanvasColor.val[2])*(RefColor.val[2]-CanvasColor.val[2]);
		diffwc = sqrtf(diffwc);

		diffws+=(RefColor.val[0]-strokeColor.val[0])*(RefColor.val[0]-strokeColor.val[0]);
		diffws+=(RefColor.val[1]-strokeColor.val[1])*(RefColor.val[1]-strokeColor.val[1]);
		diffws+=(RefColor.val[2]-strokeColor.val[2])*(RefColor.val[2]-strokeColor.val[2]);
		diffws = sqrtf(diffws);
		
		//		if (i > minStrokeLength and |refImage.color(x,y)-canvas.color(x,y)|< |refImage.color(x,y)-strokeColor|)
		if(i >= MIN_STROKE_LENGTH && diffwc < diffws )
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
		
		BOOL boundTouch = NO;
		if(xy.x < 0)
			{xy.x = 0;	boundTouch=YES;}
		if(xy.y < 0)
			{xy.y = 0;	boundTouch=YES;}
		if(xy.x >= iplCanvas->width)
			{xy.x = iplCanvas->width-1;		boundTouch=YES;}
		if(xy.y >= iplCanvas->height)
			{xy.y = iplCanvas->height-1;	boundTouch=YES;}
		//		(lastDx,lastDy) := (dx,dy)
		lastDx = dx;			lastDy = dy;
		
		//		add the point (x,y) to K
		[K addObject:[NSValue valueWithCGPoint:xy]];
		if(boundTouch)
			return K;
	}
//	return K
	return K;
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

@end
