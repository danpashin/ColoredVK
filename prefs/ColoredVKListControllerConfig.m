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
#import "ColorPickerViewController.h"

#define tweakPreferencePath @"/private/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.plist"


@implementation ColoredVKListControllerConfig
- (id)specifiers
{
	if(!_specifiers) {
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
    ColorPickerViewController *picker = [[ColorPickerViewController alloc] initWithIdentifier:[specifier identifier]];
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
    CRMediaPickerController *mediaPickerController = [[CRMediaPickerController alloc] init];
    mediaPickerController.delegate = self;
    mediaPickerController.mediaType = CRMediaPickerControllerMediaTypeImage;
    mediaPickerController.sourceType = CRMediaPickerControllerSourceTypePhotoLibrary;
    [mediaPickerController show];
}

- (void)CRMediaPickerController:(CRMediaPickerController *)mediaPickerController didFinishPickingAsset:(ALAsset *)asset error:(NSError *)error
{
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    image = [self imageByCropping:image toRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150)];

    BOOL suc = [UIImagePNGRepresentation(image) writeToFile:@"/private/var/mobile/Library/Preferences/navBarImage.png" atomically:YES];
    if (suc) [self success];
}

- (void)success
{
    UIImage *checkmarkImage = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/ColoredVK.bundle/Checkmark.png"];
    checkmarkImage = [self image:checkmarkImage withTintColor:[UIColor whiteColor]];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:checkmarkImage];
    
    [self.navigationController.view addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1.2];
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
