//
//  RINViewController.m
//  DrawPicture
//
//  Created by Hanjong Ko on 12. 10. 9..
//  Copyright (c) 2012년 lemonApple. All rights reserved.
//

#import "RINViewController.h"
#import "PreferenceViewController.h"

@interface RINViewController ()

@end

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
}

- (void)saveCurrentImageView {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"사진을 저장 했습니다."
						  message: @"카메라 롤에 현재 이미지가 저장되었습니다."\
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	UIImageWriteToSavedPhotosAlbum([imageView image],self,@selector(image:finishedSavingWithError:contextInfo:),nil);
}

#pragma mark -
#pragma mark viewController

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
	[[self navigationItem] setTitle:@"DrawPicture"];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:0] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:0] setAction:@selector(useCamera)];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:1] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:1] setAction:@selector(useCameraRoll)];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:3] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:3] setAction:@selector(refreshImageView)];
	
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:4] setTarget:self];
	[(UIBarButtonItem *)[toolbarNib.items objectAtIndex:4] setAction:@selector(saveCurrentImageView)];
	
	
	[self setToolbarItems:toolbarNib.items animated:YES];
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
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		[imageView setImage:image];
        if (newMedia) {
            UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:finishedSavingWithError:contextInfo:),nil);
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
