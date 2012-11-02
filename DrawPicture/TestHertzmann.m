//
//  RINhertzmann.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "TestHertzmann.h"
#import "UIImageCVArrConverter.h"

#define fg 1
#define T 1

UIImage* tUIGraphicsGetImageFromImageContext (CGContextRef context){
	/*CGImageRef imgRef = CGBitmapContextCreateImage(context);
	 UIImage* img = [UIImage imageWithCGImage:imgRef];
	 CGImageRelease(imgRef);
	 CGContextRelease(context);
	 return img;
	 */
	return [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
}

IplImage *tRIN_sobel_edge(IplImage *src_image, int mode, int dix) {
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

@implementation TestHertzmann

- (UIImage *)coverImage:(UIImage *)image onImage:(UIImage *)background {
	UIGraphicsBeginImageContext(background.size);
	[background drawInRect:CGRectMake(0, 0, background.size.width, background.size.height)];
	[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resultingImage;
}

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
		
		NSLog(@"%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
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
	}	
}

- (UIImage *)image {
	resultUIImage = tUIGraphicsGetImageFromImageContext(ctx);
	NSString *fileName = @"layer.png";
	NSFileManager *fm = [NSFileManager defaultManager];
	int i=0;
	while([fm fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]]==YES){
		fileName = [fileName stringByAppendingFormat:@"layer%d.png",i];
		i++;
	}
	[UIImagePNGRepresentation(resultUIImage) writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]atomically:NO];
	return resultUIImage;
}

#pragma mark -
#pragma mark innerMethod

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
// RGBA Order;
	IplImage *dst = [UIImageCVArrConverter CreateIplImageFromUIImage:[self coverImage:[UIImage imageNamed:@"t1.PNG"] onImage:src]];
	cv::Mat r(dst);
	resultUIImage = [UIImageCVArrConverter UIImageFromCVMat:r];
 	[resultUIImage drawInRect:[[UIScreen mainScreen] bounds]];
}

@end
