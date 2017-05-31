//
//  ColoredVKListControllerConfig.h
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import "ColoredVKListControllerConfig.h"

#import <UIKit/UIKit.h>
#import "MBProgressHUD/MBProgressHUD.h"
#import <Foundation/Foundation.h>
#import "headers/PSSpecifier.h"
#import "ColoredVKColorPickerViewController.h"

#define tweakPreferencePath @"/private/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.plist"


@implementation ColoredVKListControllerConfig
- (id)specifiers
{
	if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"ColoredVK_Config" target:self];
    }
    return _specifiers;
}


- (id)readPreferenceValue:(PSSpecifier*)specifier
{
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
    if (!tweakSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return tweakSettings[specifier.properties[@"key"]];
}

- (void)showColorPicker:(PSSpecifier *)specifier
{
    ColoredVKColorPickerViewController *picker = [[ColoredVKColorPickerViewController alloc] initWithIdentifier:[specifier identifier]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = 2;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:tweakPreferencePath atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.navigationController.navigationBar.topItem.title = @"General";
}

- (void)chooseImage
{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.permittedArrowDirections = 0;
        picker.popoverPresentationController.sourceView = self.view;
        picker.popoverPresentationController.sourceRect = self.view.bounds;
    }
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    hud.completionBlock = ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *croppedImage = [self imageByCropping:image toRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150)];
        
        NSError *error = nil;
        [UIImagePNGRepresentation(croppedImage) writeToFile:@"/private/var/mobile/Library/Preferences/navBarImage.png" options:NSDataWritingAtomic error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                UIImage *checkmarkImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/ColoredVK.bundle/Checkmark.png"];
                checkmarkImage = [self image:checkmarkImage withTintColor:[UIColor blackColor]];
                
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:checkmarkImage];
                [hud hideAnimated:YES afterDelay:1.5];
            } else {
                hud.detailsLabel.text = error.localizedDescription;
                [hud hideAnimated:YES afterDelay:3.0];
            }
        });
    });
}

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

- (UIImage *)image:(UIImage *)image withTintColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [tintColor setFill];
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
        CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}
@end
