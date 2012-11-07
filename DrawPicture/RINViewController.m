//
//  RINViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINViewController.h"
#import "RINhertzmann.h"
#import "RINAppDelegate.h"

#import "UIImageCVArrConverter.h"

#import "PreferenceViewController.h"


@implementation RINViewController

- (void)callEditView:(id)sender {
	PreferenceViewController *viewController;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    viewController = [[PreferenceViewController alloc] initWithNibName:@"PreferenceViewController_iPhone" bundle:nil];
	} else {
	    viewController = [[PreferenceViewController alloc] initWithNibName:@"PreferenceViewController_iPad" bundle:nil];
	}
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
	[[self navigationController] setToolbarHidden:YES animated:YES];
	[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)useCamera {
	[self refreshImageView];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		[imagePicker setDelegate:self];
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [imagePicker setMediaTypes:[NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil]];
		[imagePicker setAllowsEditing:NO];
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = YES;
    } else {
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"카메라가 없습니다."
                              message: @"또는 카메라를 불러오는데 실패하였습니다."\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
	}
} 

- (void)useCameraRoll {
	[self refreshImageView];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		[imagePicker setDelegate:self];
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePicker setMediaTypes:[NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil]];
		[imagePicker setAllowsEditing:NO];
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
    }
} 

- (void)refreshImageView {
	[imageView setImage:nil];
	[imageView setHidden:NO];
	[iCanvas removeFromSuperview];
	iCanvas=nil;
}

- (void)saveCurrentImageView {
	if([iCanvas image]){
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"사진을 저장 했습니다."
							  message: @"카메라 롤에 현재 이미지가 저장되었습니다."\
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		UIImage *scaledImage = [UIImageCVArrConverter scaleAndRotateImageBackCamera:[iCanvas image]];
		UIImageWriteToSavedPhotosAlbum(scaledImage,self,@selector(image:finishedSavingWithError:contextInfo:),nil);
	} else {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"먼저 draw 해야 합니다."
							  message: @"좌측상단의 draw를 눌러주세요."\
							  delegate: nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
	}
}

- (void)drawActionMainAlgorithm { //  paint
	if ([imageView image]==nil) {
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"사진이 필요합니다."
                              message: @"좌측하단의 카메라나 포토앨범 버튼을 눌러 사진을 불러주세요."\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
		return ;
	}
	
	// paint the canvas
	NSMutableArray *Radixes = [NSMutableArray array];
	RINAppDelegate* delegate=(RINAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *dbo = [delegate dbo];
	sqlite3_stmt *localizer=NULL;
	sqlite3_prepare_v2(dbo, [@"SELECT radix  FROM BRUSH ORDER BY radix DESC" UTF8String], -1, &localizer, NULL);
	while (sqlite3_step(localizer)==SQLITE_ROW) {
		int kval=sqlite3_column_int(localizer, 0);
		[Radixes addObject:[NSNumber numberWithInt:kval]];
	}
	sqlite3_finalize(localizer);//Radixes initializing done.
	
	if(iCanvas!=nil){
		[iCanvas removeFromSuperview];
	}
	
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
	[[self navigationController] setToolbarHidden:YES animated:NO];
	iCanvas = [[RINhertzmann alloc] initWithFrame:[imageView frame] Image:[imageView image] Radixes:Radixes];
	[[self navigationController] setNavigationBarHidden:NO animated:NO];
	[[self navigationController] setToolbarHidden:NO animated:NO];
	[[self view] addSubview:iCanvas];
	[imageView setHidden:YES]; // create canvas
	
	// canvas인 iCanvas에게 Radixes를 전달하고 종료. 나머지 알고리즘은 iCanvas에서.
	
	notice = [[UIAlertView alloc]
			  initWithTitle: @"그리기가 시작되었습니다."
			  message: @"그림파일을 분석중입니다. 잠시만 기다려 주세요."\
			  delegate: nil
			  cancelButtonTitle:@"이 팝업은 자동으로 사라집니다."
			  otherButtonTitles:nil];
	[notice show];
	
	[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(canvasINIT) userInfo:nil repeats:NO];

	[[self navigationController] setNavigationBarHidden:YES animated:YES];
	[[self navigationController] setToolbarHidden:YES animated:YES];
}

#pragma mark -
#pragma mark viewController

- (void)canvasINIT {
	OnDrawing=YES;
	
	[iCanvas calcSobel];
	framectrl = [NSTimer scheduledTimerWithTimeInterval:0.025f target:self selector:@selector(process) userInfo:nil repeats:YES];
	
	[notice dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)process {
	if([iCanvas callNEXT]==NO) return;
	switch ([iCanvas NEXT]) {
		case CALCLAYER:
			[iCanvas calcLayer];
			return ;
		case POPSTROKE:
			[iCanvas popStroke];
			return ;
		case POPDRWDOT:
			[iCanvas popAndDrawPoint];
			return ;
		case FINALSTAT:
			[framectrl invalidate];
			OnDrawing=NO;
			[[self navigationController] setNavigationBarHidden:NO animated:YES];
			[[self navigationController] setToolbarHidden:NO animated:YES];
			return ;
	}
	return ;
}

- (void)viewDidAppear:(BOOL)animated {
	[[self navigationController] setNavigationBarHidden:NO animated:YES];
	[[self navigationController] setToolbarHidden:NO animated:YES];
	if ([imageView image]==nil) {
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"사진이 필요합니다."
                              message: @"좌측하단의 카메라나 포토앨범 버튼을 눌러 사진을 불러주세요."\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];

	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[toolbarNib setHidden:YES];
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(callEditView:)]];
	[[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"draw" style:UIBarButtonItemStyleBordered target:self action:@selector(drawActionMainAlgorithm)]];
	[[self navigationItem] setTitle:@"DrawPicture"];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:0] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:0] setAction:@selector(useCamera)];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:1] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:1] setAction:@selector(useCameraRoll)];
	
	// objectAtIndex:2 is flexible space bar item;
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:3] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:3] setAction:@selector(refreshImageView)];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:4] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:4] setAction:@selector(saveCurrentImageView)];
	
	[self setToolbarItems:toolbarNib.items animated:YES];
	
	OnDrawing = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	/*
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
	*/
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(OnDrawing) return;
	if([[self navigationController] isNavigationBarHidden]) {
		[[self navigationController] setNavigationBarHidden:NO animated:YES];
		[[self navigationController] setToolbarHidden:NO animated:YES];
	} else {
		[[self navigationController] setNavigationBarHidden:YES animated:YES];
		[[self navigationController] setToolbarHidden:YES animated:YES];
	}
}
#pragma mark -

#pragma mark imagePicker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
		[[self navigationController] setNavigationBarHidden:YES animated:NO];
		[[self navigationController] setToolbarHidden:YES animated:NO];
		
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		UIImage *scaledImage = [UIImageCVArrConverter scaleAndRotateImageBackCamera:image];
		//ratio
		CGRect bounds = CGRectMake( 0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height );
		if ( [[UIScreen mainScreen] bounds].size.width/[[UIScreen mainScreen] bounds].size.height != [scaledImage size].width/[scaledImage size].height ) {
			CGFloat ratio = [scaledImage size].width/[scaledImage size].height;
			if ( ratio > 1 ) {
				bounds.size.height = bounds.size.width / ratio;
			}
			else {
				bounds.size.width = bounds.size.height * ratio;
			}
		}
		[imageView setFrame:bounds];
		[imageView setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
		[imageView setImage:scaledImage];

		[[self navigationController] setNavigationBarHidden:NO animated:NO];
		[[self navigationController] setToolbarHidden:NO animated:NO];

        if (newMedia) {
            UIImageWriteToSavedPhotosAlbum(scaledImage,self,@selector(image:finishedSavingWithError:contextInfo:),nil);
		}
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}
#pragma mark -
@end
