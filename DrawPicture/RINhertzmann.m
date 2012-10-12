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
	
	CIImage *image = [testFilter outputImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CGRect debug = image.extent;
	CGImageRef cgImage = [context createCGImage:image fromRect:image.extent];
	
	UIImage *resultUIImage = [UIImage imageWithCGImage:cgImage];
	
	[resultUIImage drawInRect:[[UIScreen mainScreen] bounds]];

}

@end
