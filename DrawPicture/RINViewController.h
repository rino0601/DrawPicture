//
//  RINViewController.h
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class RINhertzmann;

@interface RINViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
	IBOutlet UIToolbar *toolbarNib;
	IBOutlet UIImageView *imageView;
	bool	newMedia;
	RINhertzmann *iCanvas;
}

@end
