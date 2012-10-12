//
//  RINhertzmann.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 12..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataHertzmann : NSObject

@end


@interface RINhertzmann : UIView {
	UIImage *src;
}

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image;

@end
