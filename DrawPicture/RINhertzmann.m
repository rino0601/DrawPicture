//
//  RINhertzmann.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINhertzmann.h"

@implementation RINhertzmann

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image
{
    self = [super initWithFrame:frame];
	src=image;
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CIImage *ciImage = [[CIImage alloc] initWithImage:src];
	
	CIFilter *testFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[testFilter setDefaults];
	[testFilter setValue:ciImage forKey:@"inputImage"];
	[testFilter setValue:[NSNumber numberWithDouble:2.0] forKey:@"inputRadius"];// pixel로 봐도 무방할 듯.
	
	CIImage *image = [testFilter outputImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [context createCGImage:image fromRect:image.extent];
	
	resultUIImage = [UIImage imageWithCGImage:cgImage];
	
	[resultUIImage drawInRect:[[UIScreen mainScreen] bounds]];

}

- (UIImage *)image {
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
@end
